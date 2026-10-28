import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_project_doa_ibu/services/google_auth_service.dart';

class TestGoogleSdk implements GoogleAuthSdk {
  int initializeCalls = 0;
  int authenticateCalls = 0;
  int signOutCalls = 0;
  String? serverClientId;
  String? token = 'test-only-google-token';
  bool supported = true;
  Object? error;
  Object? initializationError;
  Completer<void>? initializationGate;
  Completer<String?>? authenticationGate;

  @override
  Future<void> initialize({required String serverClientId}) async {
    initializeCalls++;
    this.serverClientId = serverClientId;
    if (initializationError != null) throw initializationError!;
    await initializationGate?.future;
  }

  @override
  bool supportsAuthenticate() => supported;

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  Future<String?> authenticateIdToken() async {
    authenticateCalls++;
    if (error != null) throw error!;
    if (authenticationGate != null) return authenticationGate!.future;
    return token;
  }
}

void main() {
  for (final token in <String?>[null, '', '   ']) {
    test('rejects missing or empty SDK ID token ($token)', () async {
      final service = GoogleSignInAuthService(
        sdk: TestGoogleSdk()..token = token,
      );
      await expectLater(
        service.authenticateIdToken(),
        throwsA(
          predicate<Object>(
            (e) =>
                e.toString() ==
                'Token Google tidak tersedia. Periksa konfigurasi login Google aplikasi.',
          ),
        ),
      );
    });
  }

  test('user cancellation returns null without an error', () async {
    final sdk = TestGoogleSdk()
      ..error = const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
        description: 'test-only-private-detail',
      );
    expect(
      await GoogleSignInAuthService(sdk: sdk).authenticateIdToken(),
      isNull,
    );
  });

  final failures = <Object, String>{
    const GoogleSignInException(
      code: GoogleSignInExceptionCode.clientConfigurationError,
      description: 'test-only-private-detail',
    ): 'Konfigurasi login Google belum sesuai. Hubungi pengelola aplikasi.',
    const GoogleSignInException(
      code: GoogleSignInExceptionCode.providerConfigurationError,
      description: 'test-only-private-detail',
    ): 'Layanan Google tidak tersedia di perangkat ini. Periksa Google Play Services.',
    const GoogleSignInException(
      code: GoogleSignInExceptionCode.interrupted,
      description: 'test-only-private-detail',
    ): 'Login Google terhenti. Silakan coba lagi.',
    const GoogleSignInException(
      code: GoogleSignInExceptionCode.uiUnavailable,
      description: 'test-only-private-detail',
    ): 'Layanan Google tidak tersedia di perangkat ini. Periksa Google Play Services.',
    MissingPluginException(
      'test-only-private-detail',
    ): 'Layanan Google tidak tersedia di perangkat ini. Periksa Google Play Services.',
    PlatformException(
      code: 'network_error',
      message: 'test-only-private-detail',
    ): 'Tidak dapat terhubung ke Google. Periksa koneksi internet Anda.',
    PlatformException(
      code: 'sign_in_failed',
      message: 'test-only-private-detail',
    ): 'Gagal melakukan autentikasi Google. Silakan coba lagi.',
    StateError('test-only-private-detail'):
        'Gagal melakukan autentikasi Google. Silakan coba lagi.',
  };
  for (final entry in failures.entries) {
    test(
      'SDK failure ${entry.key.runtimeType} has a safe distinct message: ${entry.value}',
      () async {
        final sdk = TestGoogleSdk()..error = entry.key;
        await expectLater(
          GoogleSignInAuthService(sdk: sdk).authenticateIdToken(),
          throwsA(predicate<Object>((e) => e.toString() == entry.value)),
        );
      },
    );
  }

  test('unsupported platform never starts account authentication', () async {
    final sdk = TestGoogleSdk()..supported = false;
    await expectLater(
      GoogleSignInAuthService(sdk: sdk).authenticateIdToken(),
      throwsA(
        predicate<Object>(
          (e) => e.toString() == 'Login Google tidak didukung di platform ini.',
        ),
      ),
    );
    expect(sdk.authenticateCalls, 0);
    expect(sdk.signOutCalls, 0);
  });

  test('failed initialization is not attempted a second time', () async {
    final sdk = TestGoogleSdk()
      ..initializationError = const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      );
    final service = GoogleSignInAuthService(sdk: sdk);
    for (var attempt = 0; attempt < 2; attempt++) {
      await expectLater(
        service.authenticateIdToken(),
        throwsA(
          predicate<Object>(
            (e) =>
                e.toString() ==
                'Konfigurasi login Google belum sesuai. Hubungi pengelola aplikasi.',
          ),
        ),
      );
    }
    expect(sdk.initializeCalls, 1);
    expect(sdk.authenticateCalls, 0);
  });

  test(
    'overlapping calls share initialization and one native account flow',
    () async {
      final sdk = TestGoogleSdk()
        ..initializationGate = Completer<void>()
        ..authenticationGate = Completer<String?>();
      final service = GoogleSignInAuthService(sdk: sdk);
      final first = service.authenticateIdToken();
      final second = service.authenticateIdToken();
      expect(sdk.initializeCalls, 1);
      expect(sdk.authenticateCalls, 0);
      sdk.initializationGate!.complete();
      await Future<void>.delayed(Duration.zero);
      expect(sdk.authenticateCalls, 1);
      sdk.authenticationGate!.complete('test-only-google-token');
      expect(await first, 'test-only-google-token');
      expect(await second, 'test-only-google-token');
    },
  );

  test(
    'initializes once with the web client ID and gets a fresh SDK token',
    () async {
      final sdk = TestGoogleSdk();
      final service = GoogleSignInAuthService(sdk: sdk);
      expect(await service.authenticateIdToken(), 'test-only-google-token');
      expect(await service.authenticateIdToken(), 'test-only-google-token');
      expect(sdk.initializeCalls, 1);
      expect(
        sdk.serverClientId,
        '405719934940-bel9ujgn18jgaiuhpivk17e9und4872a.apps.googleusercontent.com',
      );
      expect(sdk.authenticateCalls, 2);
      expect(sdk.signOutCalls, 2);
    },
  );
}
