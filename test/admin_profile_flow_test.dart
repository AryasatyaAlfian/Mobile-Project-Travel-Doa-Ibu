import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/models/models.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/admin_profile_page.dart';
import 'package:mobile_project_doa_ibu/ui/admin_shell_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_account_info_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_change_password_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_logout_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_security_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TravelApi api;

  setUp(() {
    api = TravelApi(
      ApiClient(
        baseUrl: 'http://test.local/api',
        httpClient: MockClient((request) async {
          // 1. GET /me/profile
          if (request.method == 'GET' && request.url.path.contains('/me/profile')) {
            return http.Response(
              jsonEncode({
                'data': {
                  'id': 1,
                  'name': 'Raina',
                  'email': 'raina@gmail.com',
                  'phone': '0855 3668 1691',
                  'role': 'admin',
                  'role_label': 'Admin',
                  'is_admin': true,
                  'menus': [],
                }
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }

          // 2. PATCH /me/profile
          if (request.method == 'PATCH' && request.url.path.contains('/me/profile')) {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            return http.Response(
              jsonEncode({
                'data': {
                  'id': 1,
                  'name': body['name'] ?? 'Raina',
                  'email': 'raina@gmail.com',
                  'phone': body['phone'] ?? '0855 3668 1691',
                  'role': 'admin',
                  'role_label': 'Admin',
                  'is_admin': true,
                  'menus': [],
                },
                'message': 'Profil berhasil diperbarui.',
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }

          // 3. Settings
          if (request.method == 'GET' && request.url.path.contains('/settings')) {
            return http.Response(
              jsonEncode({
                'company_name': 'Travel Doa Ibu',
                'email': 'info@traveldoaibu.com',
                'phone': '0855 3668 1691',
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }

          // 4. Departure groups & SOS (Admin Maps)
          if (request.method == 'GET' && request.url.path.contains('/admin/departure-groups')) {
            return http.Response(
              jsonEncode({'data': []}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          if (request.method == 'GET' && request.url.path.contains('/sos')) {
            return http.Response(
              jsonEncode({'data': []}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }

          // 5. Logout
          if (request.method == 'POST' && request.url.path.contains('/auth/logout')) {
            return http.Response(
              jsonEncode({'message': 'Berhasil keluar.'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }

          return http.Response(jsonEncode({'data': {}}), 200, headers: {'content-type': 'application/json'});
        }),
      ),
    );

    TravelApi.currentUser = AppUser(
      id: 1,
      name: 'Raina',
      email: 'raina@gmail.com',
      isAdmin: true,
      role: 'admin',
      roleLabel: 'Admin',
      phone: '0855 3668 1691',
    );
  });

  tearDown(() {
    TravelApi.currentUser = null;
  });

  group('Admin Profile Page Tests', () {
    testWidgets('menampilkan layout profile admin: Header, Kartu Raina, dan 4 Menu (tanpa Digital Payment)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminProfilePage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header Profile
      expect(find.text('Profile'), findsOneWidget);

      // 2. Kartu Profil Admin (Raina)
      expect(find.text('Raina'), findsOneWidget);
      expect(find.text('raina@gmail.com'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // 3. Seksi Akun & 4 Menu
      expect(find.text('Akun'), findsOneWidget);
      expect(find.text('Informasi Akun'), findsOneWidget);
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Keamanan Akun'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);

      // 4. Pastikan Digital Payment TIDAK ada pada role Admin
      expect(find.text('Digital Payment'), findsNothing);
    });

    testWidgets('menekan tombol Edit / Informasi Akun membuka ProfileAccountInfoPage admin', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminProfilePage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Informasi Akun'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileAccountInfoPage), findsOneWidget);
      expect(find.text('Data Pribadi'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Nomor Telepon'), findsOneWidget);
      expect(find.text('Tanggal Lahir'), findsOneWidget);
      expect(find.text('Jenis Kelamin'), findsOneWidget);
    });

    testWidgets('menekan Pengaturan membuka ProfileSettingsPage ringkas admin (Bahasa, Tema, Notifikasi)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminProfilePage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pengaturan'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSettingsPage), findsOneWidget);
      expect(find.text('Preferensi Aplikasi'), findsOneWidget);
      expect(find.text('Bahasa Aplikasi'), findsOneWidget);
      expect(find.text('Tema Tampilan'), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);

      // Pastikan Mata Uang dan seksi Lainnya TIDAK ada pada mode admin
      expect(find.text('Mata Uang'), findsNothing);
      expect(find.text('Lainnya'), findsNothing);
      expect(find.text('Tentang Aplikasi'), findsNothing);
    });

    testWidgets('menekan Keamanan Akun membuka ProfileSecurityPage admin dengan Ubah Kata Sandi saja', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminProfilePage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keamanan Akun'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileSecurityPage), findsOneWidget);
      expect(find.text('Ubah Kata Sandi'), findsOneWidget);

      // Pastikan 2FA dan Riwayat Aktivitas disembunyikan sesuai mockup admin
      expect(find.text('Autentikasi Dua Faktor'), findsNothing);
      expect(find.text('Riwayat Aktivitas'), findsNothing);

      // Menekan Ubah Kata Sandi membuka ProfileChangePasswordPage
      await tester.tap(find.text('Ubah Kata Sandi'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileChangePasswordPage), findsOneWidget);
    });

    testWidgets('menekan Keluar membuka ProfileLogoutPage', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminProfilePage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileLogoutPage), findsOneWidget);
    });

    testWidgets('AdminShellPage Tab 1 mengintegrasikan AdminProfilePage secara presisi', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          home: AdminShellPage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Secara default Tab 0 aktif (Maps)
      expect(find.byTooltip('Peta Lapangan'), findsOneWidget);
      expect(find.byTooltip('Profil Administrator'), findsOneWidget);

      // Pindah ke Tab 1 (Profil Administrator)
      await tester.tap(find.byTooltip('Profil Administrator'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminProfilePage), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Raina'), findsOneWidget);
    });
  });
}
