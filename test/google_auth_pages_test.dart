import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/core/storage/app_storage.dart';
import 'package:mobile_project_doa_ibu/services/google_auth_service.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/login_page.dart';
import 'package:mobile_project_doa_ibu/ui/initial_landing_page.dart';
import 'package:mobile_project_doa_ibu/ui/landing_page.dart';
import 'package:mobile_project_doa_ibu/ui/register_page.dart';

class TestGoogleAuth implements GoogleAuthService {
  int calls = 0;
  final Completer<String?> result = Completer<String?>();

  @override
  Future<String?> authenticateIdToken() {
    calls++;
    return result.future;
  }
}

Future<void> openAuthPage(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => page)),
            child: const Text('test home'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('test home'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Auth widget tests do not test font rendering or use the network. Supply
  // the SDK's local test font through a test-only asset channel instead.
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final root = Platform.environment['FLUTTER_ROOT']!;
    final font = ByteData.sublistView(
      await File(
        '$root/bin/cache/artifacts/material_fonts/roboto-regular.ttf',
      ).readAsBytes(),
    );
    const codec = StandardMessageCodec();
    final manifest = <String, Object>{
      for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold'])
        'test-font/Poppins-$weight.ttf': [
          <String, Object>{'asset': 'test-font/Poppins-$weight.ttf'},
        ],
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final name = utf8.decode(
            message!.buffer.asUint8List(
              message.offsetInBytes,
              message.lengthInBytes,
            ),
          );
          if (name == 'AssetManifest.bin') return codec.encodeMessage(manifest);
          if (name.startsWith('test-font/')) return font;
          final asset = File(name);
          if (await asset.exists()) {
            return ByteData.sublistView(await asset.readAsBytes());
          }
          return null;
        });
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    GoogleFonts.config.allowRuntimeFetching = true;
  });
  setUp(() {
    AppStorage.instance.clear();
    TravelApi.currentUser = null;
  });

  for (final initial in [true, false]) {
    testWidgets(
      '${initial ? 'initial' : 'secondary'} landing registration supplies an authenticated Google callback',
      (tester) async {
        tester.view.physicalSize = const Size(414, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = TravelApi(ApiClient(httpClient: MockClient((_) async =>
          http.Response(jsonEncode({'data': [], 'meta': {'current_page': 1, 'last_page': 1, 'total': 0}}), 200),
        )));
        var authenticated = 0;
        await tester.pumpWidget(MaterialApp(home: initial
          ? InitialLandingPage(api: api, onStart: () {}, onAuthenticated: () => authenticated++)
          : LandingPage(api: api, onContinueAsGuest: () => authenticated++),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Daftar'));
        await tester.pumpAndSettle();
        final register = tester.widget<RegisterPage>(find.byType(RegisterPage));
        expect(register.onGoogleSignInSuccess, isNotNull);
        register.onGoogleSignInSuccess!();
        expect(authenticated, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'login-to-registration keeps injected Google service and authenticated callback',
    (tester) async {
      final google = TestGoogleAuth();
      final api = TravelApi(
        ApiClient(
          httpClient: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'token': 'test-only-session',
                'user': {
                  'id': 7,
                  'name': 'Unit user',
                  'email': 'unit@example.invalid',
                },
              }),
              201,
            ),
          ),
        ),
      );
      var successes = 0;
      await openAuthPage(
        tester,
        LoginPage(
          api: api,
          googleAuth: google,
          onLoginSuccess: () => successes++,
        ),
      );
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();
      final page = tester.widget<RegisterPage>(find.byType(RegisterPage));
      expect(page.googleAuth, same(google));
      expect(page.onGoogleSignInSuccess, isNotNull);
      await tester.tap(find.text('Google'));
      google.result.complete('test-only-google-token');
      await tester.pumpAndSettle();
      expect(successes, 1);
      expect(find.text('test home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final registration in [false, true]) {
    final label = registration ? 'registration' : 'login';

    testWidgets(
      '$label cancellation leaves the form ready without backend calls or error',
      (tester) async {
        final google = TestGoogleAuth();
        var requests = 0;
        final api = TravelApi(
          ApiClient(
            httpClient: MockClient((_) async {
              requests++;
              return http.Response('{}', 500);
            }),
          ),
        );
        await openAuthPage(
          tester,
          registration
              ? RegisterPage(api: api, googleAuth: google)
              : LoginPage(api: api, googleAuth: google),
        );
        await tester.tap(find.text('Google'));
        google.result.complete(null);
        await tester.pumpAndSettle();
        expect(requests, 0);
        expect(find.byType(SnackBar), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Google'), findsOneWidget);
        expect(
          tester
              .widget<InkWell>(
                find.ancestor(
                  of: find.text('Google'),
                  matching: find.byType(InkWell),
                ),
              )
              .onTap,
          isNotNull,
        );
        expect(api.client.token, isNull);
      },
    );

    final errors = <String, Object>{
      'Masuk dengan password Anda. Akun Google belum ditautkan.': ApiException(
        'Masuk dengan password Anda. Akun Google belum ditautkan.',
        statusCode: 409,
      ),
      'Konfigurasi login Google belum sesuai. Hubungi pengelola aplikasi.':
          const GoogleAuthException(
            'Konfigurasi login Google belum sesuai. Hubungi pengelola aplikasi.',
          ),
      'Tidak dapat terhubung ke server.': ApiException(
        'Tidak dapat terhubung ke server.',
      ),
      'Layanan Google tidak tersedia di perangkat ini.':
          const GoogleAuthException(
            'Layanan Google tidak tersedia di perangkat ini.',
          ),
    };
    for (final entry in errors.entries) {
      testWidgets(
        '$label shows safe error and releases loading: ${entry.key}',
        (tester) async {
          final google = TestGoogleAuth();
          var requests = 0;
          final api = TravelApi(
            ApiClient(
              httpClient: MockClient((_) async {
                requests++;
                final error = entry.value as ApiException;
                return http.Response(
                  jsonEncode({'message': error.message}),
                  error.statusCode ?? 503,
                );
              }),
            ),
          );
          await openAuthPage(
            tester,
            registration
                ? RegisterPage(api: api, googleAuth: google)
                : LoginPage(api: api, googleAuth: google),
          );
          await tester.tap(find.text('Google'));
          if (entry.value is GoogleAuthException) {
            google.result.completeError(entry.value);
          } else {
            google.result.complete('test-only-google-token');
          }
          await tester.pumpAndSettle();
          expect(find.text(entry.key), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.text('Google'), findsOneWidget);
          expect(requests, entry.value is GoogleAuthException ? 0 : 1);
          expect(api.client.token, isNull);
          expect(TravelApi.currentUser, isNull);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      '$label disposal during native auth never exchanges the token',
      (tester) async {
        final google = TestGoogleAuth();
        var requests = 0;
        var successes = 0;
        final api = TravelApi(
          ApiClient(
            httpClient: MockClient((_) async {
              requests++;
              return http.Response('{}', 500);
            }),
          ),
        );
        await openAuthPage(
          tester,
          registration
              ? RegisterPage(
                  api: api,
                  googleAuth: google,
                  onGoogleSignInSuccess: () => successes++,
                )
              : LoginPage(
                  api: api,
                  googleAuth: google,
                  onLoginSuccess: () => successes++,
                ),
        );
        await tester.tap(find.text('Google'));
        await tester.pumpWidget(const SizedBox.shrink());
        google.result.complete('test-only-google-token');
        await tester.pumpAndSettle();
        expect(requests, 0);
        expect(successes, 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$label disposal during exchange never invokes UI success', (
      tester,
    ) async {
      final google = TestGoogleAuth();
      final response = Completer<http.Response>();
      var requests = 0;
      var successes = 0;
      final api = TravelApi(
        ApiClient(
          httpClient: MockClient((_) {
            requests++;
            return response.future;
          }),
        ),
      );
      await openAuthPage(
        tester,
        registration
            ? RegisterPage(
                api: api,
                googleAuth: google,
                onGoogleSignInSuccess: () => successes++,
              )
            : LoginPage(
                api: api,
                googleAuth: google,
                onLoginSuccess: () => successes++,
              ),
      );
      await tester.tap(find.text('Google'));
      google.result.complete('test-only-google-token');
      await tester.pump();
      expect(requests, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      response.complete(
        http.Response(
          jsonEncode({
            'token': 'test-only-session',
            'user': {
              'id': 7,
              'name': 'Unit user',
              'email': 'unit@example.invalid',
            },
          }),
          200,
        ),
      );
      await tester.pumpAndSettle();
      expect(successes, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$label uses SDK token exchange, blocks repeated taps, completes authenticated',
      (tester) async {
        final google = TestGoogleAuth();
        var exchanges = 0;
        var successes = 0;
        final client = ApiClient(
          httpClient: MockClient((request) async {
            exchanges++;
            expect(request.url.path, endsWith('/auth/google'));
            expect(
              jsonDecode(request.body)['id_token'],
              'test-only-google-token',
            );
            return http.Response(
              jsonEncode({
                'token': 'test-only-session',
                'user': {
                  'id': 7,
                  'name': 'Unit user',
                  'email': 'unit@example.invalid',
                },
              }),
              registration ? 201 : 200,
            );
          }),
        );
        final api = TravelApi(client);
        await openAuthPage(
          tester,
          registration
              ? RegisterPage(
                  api: api,
                  googleAuth: google,
                  onGoogleSignInSuccess: () => successes++,
                )
              : LoginPage(
                  api: api,
                  googleAuth: google,
                  onLoginSuccess: () => successes++,
                ),
        );
        final googleButton = find.ancestor(
          of: find.text('Google'),
          matching: find.byType(InkWell),
        );
        final originalTap = tester.widget<InkWell>(googleButton).onTap!;
        await tester.tap(googleButton);
        originalTap();
        await tester.pump();
        expect(google.calls, 1);
        expect(exchanges, 0);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(BottomSheet), findsNothing);
        final formButton = find.ancestor(
          of: find.text(registration ? 'DAFTAR' : 'MASUK'),
          matching: find.byType(InkWell),
        );
        expect(tester.widget<InkWell>(formButton).onTap, isNull);
        google.result.complete('test-only-google-token');
        await tester.pumpAndSettle();
        expect(exchanges, 1);
        expect(successes, 1);
        expect(client.token, 'test-only-session');
        expect(TravelApi.currentUser?.id, 7);
        expect(find.text('test home'), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
