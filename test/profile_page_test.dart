import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/models/models.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/profile_account_info_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_bank_transfer_qris_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_card_payment_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_change_password_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_digital_payment_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_language_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_logout_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_paypal_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_security_page.dart';
import 'package:mobile_project_doa_ibu/ui/profile_settings_page.dart';
import 'package:mobile_project_doa_ibu/ui/widgets/skeleton_view.dart';

void main() {
  late TravelApi api;
  String? lastPutPath;
  Map<String, dynamic>? lastPutBody;

  setUp(() {
    lastPutPath = null;
    lastPutBody = null;
    api = TravelApi(
      ApiClient(
        baseUrl: 'http://test.local/api',
        httpClient: MockClient((request) async {
          if (request.method == 'PUT' && request.url.path.contains('/me/password')) {
            lastPutPath = request.url.path;
            lastPutBody = jsonDecode(request.body) as Map<String, dynamic>;
            return http.Response('{"message": "Password berhasil diubah."}', 200);
          }
          if (request.method == 'GET' && request.url.path.contains('/me/profile')) {
            return http.Response(
              jsonEncode({
                'name': 'Ahmad Dahlan',
                'email': 'ahmad@traveldoaibu.com',
                'phone': '081299998888',
                'profile': {
                  'gender': 'L',
                  'birth_date': '1995-05-20',
                },
              }),
              200,
            );
          }
          return http.Response('{"status": "success", "data": {}}', 200);
        }),
      ),
    );
    TravelApi.currentUser = AppUser(
      id: 1,
      name: 'Ahmad Dahlan',
      email: 'ahmad@traveldoaibu.com',
      isAdmin: false,
      role: 'jemaah',
      roleLabel: 'Jemaah',
      phone: '081299998888',
    );
  });

  tearDown(() {
    TravelApi.currentUser = null;
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('ProfilePage Widget Tests', () {
    testWidgets('menampilkan header, kartu profil inisial asli dinamis, tombol edit, dan 5 menu utama', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfilePage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Ahmad Dahlan'), findsOneWidget);
      expect(find.text('ahmad@traveldoaibu.com'), findsOneWidget);
      expect(find.text('AD'), findsOneWidget); // Inisial dinamis
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Akun'), findsOneWidget);

      expect(find.text('Informasi Akun'), findsOneWidget);
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Keamanan Akun'), findsOneWidget);
      expect(find.text('Digital Payment'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);
    });

    testWidgets('membuka halaman Digital Payment saat menu ditekan', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfilePage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Digital Payment'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileDigitalPaymentPage), findsOneWidget);
      expect(find.text('Kelola Metode Pembayaran Anda'), findsOneWidget);
      expect(find.text('Transfer Bank / QRIS'), findsOneWidget);
      expect(find.text('Kartu Kredit/Debit'), findsOneWidget);
      expect(find.text('Paypal'), findsOneWidget);
    });

    testWidgets('menampilkan halaman konfirmasi ProfileLogoutPage saat tombol Keluar ditekan', (tester) async {
      bool loggedOut = false;
      await tester.pumpWidget(
        buildTestableWidget(
          ProfilePage(
            api: api,
            onLogout: () {
              loggedOut = true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileLogoutPage), findsOneWidget);
      expect(find.text('Keluar dari Akun?'), findsOneWidget);
      expect(find.text('Keluar'), findsWidgets);
      expect(find.text('Batal'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(loggedOut, isFalse);
    });

    testWidgets('navigasi halus dengan Hero avatar saat menekan Edit membuka ProfileAccountInfoPage', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfilePage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Hero), findsWidgets);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileAccountInfoPage), findsOneWidget);
      expect(find.text('Informasi Akun'), findsOneWidget);
    });

    testWidgets('navigasi halus saat menekan Pengaturan dan Keamanan Akun', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfilePage(
            api: api,
            onLogout: () {},
          ),
        ),
      );
      await tester.pump();

      // Buka Pengaturan
      await tester.tap(find.text('Pengaturan'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileSettingsPage), findsOneWidget);

      // Kembali
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Buka Keamanan Akun
      await tester.tap(find.text('Keamanan Akun'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileSecurityPage), findsOneWidget);
    });
  });

  group('ProfileAccountInfoPage Widget Tests', () {
    testWidgets('menampilkan data pribadi terintegrasi dengan backend', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileAccountInfoPage(
            api: api,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Informasi Akun'), findsOneWidget);
      expect(find.text('Data Pribadi'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Ahmad Dahlan'), findsWidgets);
      expect(find.text('ahmad@traveldoaibu.com'), findsWidgets);
      expect(find.text('081299998888'), findsOneWidget);
      expect(find.text('Laki-laki'), findsOneWidget);
      expect(find.text('20 Mei 1995'), findsOneWidget);
    });

    testWidgets('menampilkan skeleton view saat profil sedang memuat', (tester) async {
      final completer = Completer<http.Response>();
      final mockClient = MockClient((request) => completer.future);
      final testApi = TravelApi(ApiClient(baseUrl: 'http://test.local/api', httpClient: mockClient));

      await tester.pumpWidget(
        buildTestableWidget(
          ProfileAccountInfoPage(
            api: testApi,
          ),
        ),
      );
      await tester.pump();

      // Memastikan SkeletonBox dan SkeletonCircle tampil saat loading
      expect(find.byType(SkeletonBox), findsWidgets);
      expect(find.byType(SkeletonCircle), findsWidgets);

      // Selesaikan future
      completer.complete(http.Response('{"name": "Ahmad"}', 200));
      await tester.pumpAndSettle();
    });
  });

  group('ProfileChangePasswordPage Widget Tests', () {
    testWidgets('validasi form dan berhasil memanggil PUT /me/password backend', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileChangePasswordPage(
            api: api,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ubah Kata Sandi'), findsOneWidget);
      expect(find.text('Kata Sandi Saat Ini'), findsOneWidget);
      expect(find.text('Kata Sandi Baru'), findsOneWidget);
      expect(find.text('Konfirmasi Kata Sandi Baru'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);

      // 1. Submit form kosong -> Validasi error
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      expect(find.text('Kata sandi saat ini wajib diisi.'), findsOneWidget);

      // 2. Isi form dengan kata sandi baru
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'oldpassword123');
      await tester.enterText(textFields.at(1), 'NewPassword!999');
      await tester.enterText(textFields.at(2), 'NewPassword!999');
      await tester.pump();

      // 3. Submit form -> Panggilan ke backend sukses
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      expect(lastPutPath, contains('/me/password'));
      expect(lastPutBody?['current_password'], 'oldpassword123');
      expect(lastPutBody?['password'], 'NewPassword!999');
      expect(lastPutBody?['password_confirmation'], 'NewPassword!999');

      // 4. Verifikasi Tampilan Berhasil (media_1793591703722_e8774b9d.png)
      expect(find.text('Berhasil'), findsOneWidget);
      expect(find.text('Kata sandi Anda telah berhasil\ndiubah.'), findsOneWidget);
      expect(find.text('Kembali ke Profile'), findsOneWidget);
    });
  });

  group('ProfileSettingsPage Widget Tests', () {
    testWidgets('menampilkan preferensi aplikasi dan bagian lainnya', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ProfileSettingsPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Preferensi Aplikasi'), findsOneWidget);
      expect(find.text('Bahasa Aplikasi'), findsOneWidget);
      expect(find.text('Tema Tampilan'), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Mata Uang'), findsOneWidget);

      expect(find.text('Lainnya'), findsOneWidget);
      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(find.text('Syarat dan Ketentuan'), findsOneWidget);
      expect(find.text('Kebijakan Privasi'), findsOneWidget);
    });
  });

  group('ProfileSecurityPage Widget Tests', () {
    testWidgets('menampilkan opsi keamanan dan toggle 2FA', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileSecurityPage(api: api),
        ),
      );
      await tester.pump();

      expect(find.text('Keamanan Akun'), findsOneWidget);
      expect(find.text('Ubah Kata Sandi'), findsOneWidget);
      expect(find.text('Autentikasi Dua Faktor'), findsOneWidget);
      expect(find.text('Riwayat Aktivitas'), findsOneWidget);
    });
  });

  group('ProfileLanguagePage Widget Tests', () {
    testWidgets('menampilkan daftar bahasa dan ornamen bendera', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ProfileLanguagePage(),
        ),
      );
      await tester.pump();

      expect(find.text('Bahasa Aplikasi'), findsOneWidget);
      expect(find.text('Bahasa Indonesia'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
    });
  });

  group('ProfileBankTransferQrisPage Widget Tests', () {
    testWidgets('menampilkan tab Transfer Bank, detail rekening, dan catatan penting', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ProfileBankTransferQrisPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Transfer Bank / QRIS'), findsOneWidget);
      expect(find.text('Transfer Bank'), findsOneWidget);
      expect(find.text('QRIS'), findsOneWidget);
      expect(find.text('Pilih Bank'), findsOneWidget);
      expect(find.text('BCA'), findsOneWidget);
      expect(find.text('1234 5678 9012'), findsOneWidget);
      expect(find.text("PT Travel Do'a Ibu"), findsOneWidget);
      expect(find.text('Catatan Penting'), findsOneWidget);
      expect(find.text('Saya Sudah Transfer'), findsOneWidget);
    });

    testWidgets('beralih ke tab QRIS dan menampilkan QRIS code serta nominal', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ProfileBankTransferQrisPage(),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('QRIS'));
      await tester.pump();

      expect(find.text('QRIS'), findsWidgets);
      expect(find.text('Rp 10.500.000'), findsOneWidget);
      expect(find.text("Travel Do'a Ibu"), findsOneWidget);
      expect(find.text('Saya Sudah Transfer'), findsOneWidget);
    });
  });

  group('ProfilePaymentMethodsPage & Detail Kartu Tests', () {
    testWidgets('menampilkan metode pembayaran kartu dan navigasi ke Detail Kartu', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ProfilePaymentMethodsPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Pilih Metode Pembayaran'), findsOneWidget);
      expect(find.text('Visa Card'), findsWidgets);
      expect(find.text('4000 1234 5678 9012'), findsOneWidget);
      expect(find.text('Tambah Kartu Baru'), findsOneWidget);

      // Buka detail kartu
      await tester.ensureVisible(find.text('Lanjutkan Pembayaran'));
      await tester.tap(find.text('Lanjutkan Pembayaran'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileCardDetailPage), findsOneWidget);
      expect(find.text('Detail Kartu'), findsOneWidget);
      expect(find.text('Nama Pemilik'), findsOneWidget);
      expect(find.text('Hapus Kartu'), findsOneWidget);
      expect(find.text('Edit Kartu'), findsOneWidget);
    });
  });

  group('ProfilePaypalPage & ProfileLogoutPage Tests', () {
    testWidgets('menampilkan halaman PayPal dan beralih ke sukses', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ProfilePaypalPage(),
        ),
      );
      await tester.pump();

      expect(find.text('PayPal'), findsOneWidget);
      expect(find.text('Hubungkan Akun PayPal'), findsNWidgets(2)); // judul & tombol

      await tester.tap(find.widgetWithText(ElevatedButton, 'Hubungkan Akun PayPal'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePaypalSuccessPage), findsOneWidget);
      expect(find.text('PayPal Terhubung'), findsOneWidget);
      expect(find.text('Akun PayPal Berhasil\nTerhubung'), findsOneWidget);
      expect(find.text('Kembali ke Digital Payment'), findsOneWidget);

      await tester.tap(find.text('Kembali ke Digital Payment'));
      await tester.pumpAndSettle();
    });

    testWidgets('ProfileLogoutPage memproses logout saat tombol Keluar ditekan', (tester) async {
      bool logoutCalled = false;
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileLogoutPage(
            api: api,
            onLogout: () {
              logoutCalled = true;
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Keluar dari Akun?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
      await tester.pumpAndSettle();

      expect(logoutCalled, isTrue);
    });
  });
}
