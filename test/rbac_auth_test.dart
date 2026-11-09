import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/main.dart';
import 'package:mobile_project_doa_ibu/models/models.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/admin_landing_page.dart';
import 'package:mobile_project_doa_ibu/ui/login_page.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif_landing_page.dart';

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
    });

    testWidgets('RootNavigation mengarahkan Admin ke AdminLandingPage', (tester) async {
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

      expect(find.byType(AdminLandingPage), findsOneWidget);
      expect(find.text('Panel Administrator'), findsOneWidget);
      expect(find.text('ROLE: ADMIN'), findsOneWidget);
      expect(find.text('Modul Manajemen Admin'), findsOneWidget);
      expect(find.text('Data Jemaah'), findsOneWidget);
      expect(find.text('Data Muthawwif'), findsOneWidget);
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

      expect(find.byType(MuthawwifLandingPage), findsOneWidget);
      expect(find.text('Portal Pembimbing'), findsOneWidget);
      expect(find.text('ROLE: MUTHAWWIF'), findsOneWidget);
      expect(find.text('Jemaah Bimbingan'), findsOneWidget);
      expect(find.text('Radar & Pemantauan Lokasi'), findsOneWidget);
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

    testWidgets('Logout dari AdminLandingPage mengembalikan ke halaman sambutan', (tester) async {
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

      expect(find.byType(AdminLandingPage), findsOneWidget);

      // Tekan tombol logout
      await tester.tap(find.text('Keluar dari Akun Admin'));
      await tester.pumpAndSettle();

      // Sesi terhapus dan kembali ke alur landing
      expect(api.user, isNull);
      expect(api.client.token, isNull);
      expect(find.byType(AdminLandingPage), findsNothing);
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
  });
}
