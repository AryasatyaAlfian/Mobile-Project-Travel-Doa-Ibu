import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/core/storage/app_storage.dart';
import 'package:mobile_project_doa_ibu/main.dart';
import 'package:mobile_project_doa_ibu/models/models.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/admin_shell_page.dart';
import 'package:mobile_project_doa_ibu/ui/login_page.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif_shell_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_logout_page.dart';

void main() {
  group('AppUser RBAC Model Tests', () {
    test('normalisasi role admin dengan benar', () {
      final user = AppUser.fromJson({
        'id': 1,
        'name': 'Raina',
        'email': 'raina@traveldoaibu.test',
        'is_admin': true,
        'role': 'admin',
        'role_label': 'Admin',
      });

      expect(user.isAdminRole, isTrue);
      expect(user.isJemaah, isFalse);
      expect(user.isMuthawwif, isFalse);
      expect(user.roleLabel, 'Admin');
    });

    test('normalisasi role muthawwif dengan benar', () {
      final user = AppUser.fromJson({
        'id': 2,
        'name': 'Ust. Felix',
        'email': 'felix@traveldoaibu.test',
        'is_admin': false,
        'role': 'muthawwif',
        'role_label': 'Muthawwif',
      });

      expect(user.isMuthawwif, isTrue);
      expect(user.isAdminRole, isFalse);
      expect(user.isJemaah, isFalse);
      expect(user.roleLabel, 'Muthawwif');
    });

    test('normalisasi role jemaah dengan benar', () {
      final user = AppUser.fromJson({
        'id': 3,
        'name': 'Zara',
        'email': 'zara@traveldoaibu.test',
        'is_admin': false,
        'role': 'jemaah',
      });

      expect(user.isJemaah, isTrue);
      expect(user.isAdminRole, isFalse);
      expect(user.isMuthawwif, isFalse);
      expect(user.roleLabel, 'Jemaah');
    });
  });

  group('RBAC Navigation & Landing Page Tests', () {
    tearDown(() {
      TravelApi.currentUser = null;
      AppStorage.instance.clear();
    });

    testWidgets('RootNavigation mengarahkan Admin ke AdminShellPage & AdminProfilePage', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final client = ApiClient(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
        baseUrl: 'http://test',
      );
      client.token = 'test_token';
      final api = TravelApi(client);
      TravelApi.currentUser = AppUser(
        id: 1,
        name: 'Raina Admin',
        email: 'raina@traveldoaibu.test',
        isAdmin: true,
        role: 'admin',
        roleLabel: 'Admin',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RootNavigation(api: api),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdminShellPage), findsOneWidget);

      // Pindah ke tab profil admin untuk melihat panel profil administrator
      await tester.tap(find.byTooltip('Profil Administrator'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Raina Admin'), findsOneWidget);
      expect(find.text('Akun'), findsOneWidget);
      expect(find.text('Informasi Akun'), findsOneWidget);
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Keamanan Akun'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);
      expect(find.text('Digital Payment'), findsNothing);
    });

    testWidgets('RootNavigation mengarahkan Muthawwif ke MuthawwifLandingPage', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final client = ApiClient(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
        baseUrl: 'http://test',
      );
      client.token = 'test_token';
      final api = TravelApi(client);
      TravelApi.currentUser = AppUser(
        id: 2,
        name: 'Ust. Felix Siauw',
        email: 'felix@traveldoaibu.test',
        isAdmin: false,
        role: 'muthawwif',
        roleLabel: 'Muthawwif',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RootNavigation(api: api),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MuthawwifShellPage), findsOneWidget);
      expect(find.text('Layanan Mutawwif'), findsOneWidget);
      expect(find.text('Detail Rombongan'), findsOneWidget);
      expect(find.text('Jadwal Kegiatan'), findsOneWidget);
    });

    testWidgets('RootNavigation mengarahkan Jemaah ke MainScreen (Landing Page User)', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final client = ApiClient(
        httpClient: MockClient((req) async {
          return http.Response(
            jsonEncode({
              'data': [],
              'meta': {'current_page': 1, 'last_page': 1, 'total': 0},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
        baseUrl: 'http://test',
      );
      client.token = 'test_token';
      final api = TravelApi(client);
      TravelApi.currentUser = AppUser(
        id: 3,
        name: 'Zara Anselma',
        email: 'zara@traveldoaibu.test',
        isAdmin: false,
        role: 'jemaah',
        roleLabel: 'Jemaah',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RootNavigation(api: api),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.text('Tiket Saya'), findsNothing); // Home tab aktif
    });

    testWidgets('Logout dari AdminProfilePage mengembalikan ke halaman sambutan', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final client = ApiClient(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
        baseUrl: 'http://test',
      );
      client.token = 'test_token';
      final api = TravelApi(client);
      TravelApi.currentUser = AppUser(
        id: 1,
        name: 'Raina Admin',
        email: 'raina@traveldoaibu.test',
        isAdmin: true,
        role: 'admin',
        roleLabel: 'Admin',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RootNavigation(api: api),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdminShellPage), findsOneWidget);

      // Pindah ke tab profil admin untuk logout
      await tester.tap(find.byTooltip('Profil Administrator'));
      await tester.pumpAndSettle();

      // Scroll ke menu Keluar dan tekan
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      // Di halaman ProfileLogoutPage, konfirmasi keluar
      expect(find.byType(ProfileLogoutPage), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      // Sesi terhapus dan kembali ke alur landing
      expect(api.user, isNull);
      expect(api.client.token, isNull);
      expect(find.byType(AdminShellPage), findsNothing);
    });

    testWidgets('Login berhasil mengarahkan ke landing page sesuai role dari response backend API', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final client = ApiClient(
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/auth/login')) {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            final email = body['email'] as String;
            final isAdmin = email.contains('admin');
            return http.Response(
              jsonEncode({
                'token': 'sanctum_token_123',
                'user': {
                  'id': 10,
                  'name': isAdmin ? 'Admin Utama' : 'Jemaah Test',
                  'email': email,
                  'is_admin': isAdmin,
                  'role': isAdmin ? 'admin' : 'jemaah',
                  'role_label': isAdmin ? 'Admin' : 'Jemaah',
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('{}', 200);
        }),
        baseUrl: 'http://test',
      );
      final api = TravelApi(client);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginPage(
              api: api,
              onLoginSuccess: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Isi email & password riil
      await tester.enterText(find.byType(TextField).first, 'admin@travel.com');
      await tester.enterText(find.byType(TextField).last, 'secret123');
      await tester.tap(find.text('MASUK'));
      await tester.pumpAndSettle();

      // Sesi tersimpan dengan data yang murni dari response backend API
      expect(api.user, isNotNull);
      expect(api.user!.isAdminRole, isTrue);
      expect(api.user!.email, 'admin@travel.com');
      expect(api.client.token, 'sanctum_token_123');
    });

    testWidgets('Alur lengkap login admin dari RootNavigation mengarahkan ke AdminShellPage', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final client = ApiClient(
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/auth/login')) {
            return http.Response(
              jsonEncode({
                'token': 'admin_sanctum_token',
                'user': {
                  'id': 2,
                  'name': 'Raina',
                  'email': 'raina@traveldoaibu.test',
                  'is_admin': true,
                  'role': 'admin',
                  'role_label': 'Admin',
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('{}', 200);
        }),
        baseUrl: 'http://test',
      );
      final api = TravelApi(client);

      await tester.pumpWidget(
        MaterialApp(
          home: RootNavigation(api: api),
        ),
      );
      await tester.pumpAndSettle();

      // Mulai dari InitialLandingPage, tekan LOGIN
      expect(find.text('LOGIN'), findsOneWidget);
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // Sekarang di LoginPage
      expect(find.byType(LoginPage), findsOneWidget);

      // Masukkan kredensial admin
      await tester.enterText(find.byType(TextField).first, 'raina@traveldoaibu.test');
      await tester.enterText(find.byType(TextField).last, 'DoaIbu123!');
      await tester.tap(find.text('MASUK'));
      await tester.pumpAndSettle();

      // Harus mengarahkan ke AdminShellPage, BUKAN MainScreen
      expect(find.byType(AdminShellPage), findsOneWidget);
      expect(find.byType(MainScreen), findsNothing);
    });

    testWidgets('Session restore: token ada tetapi currentUser belum dimuat harus memuat me() dan menampilkan AdminShellPage', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final client = ApiClient(
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/auth/me')) {
            return http.Response(
              jsonEncode({
                'data': {
                  'id': 2,
                  'name': 'Raina Admin',
                  'email': 'raina@traveldoaibu.test',
                  'is_admin': true,
                  'role': 'admin',
                  'role_label': 'Admin',
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('{}', 200);
        }),
        baseUrl: 'http://test',
      );
      client.token = 'existing_valid_token';
      final api = TravelApi(client);
      TravelApi.currentUser = null;

      await tester.pumpWidget(
        MaterialApp(
          home: RootNavigation(api: api),
        ),
      );
      await tester.pumpAndSettle();

      // Harusnya AdminShellPage yang muncul, bukan MainScreen
      expect(find.byType(AdminShellPage), findsOneWidget);
      expect(find.byType(MainScreen), findsNothing);
    });
  });
}
