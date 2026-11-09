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
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/models/models.dart';
import 'package:mobile_project_doa_ibu/ui/booking_form_page.dart';
import 'package:mobile_project_doa_ibu/ui/contact_page.dart';
import 'package:mobile_project_doa_ibu/ui/forgot_password_page.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif_guard_page.dart';
import 'package:mobile_project_doa_ibu/ui/package_detail_page.dart';
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
import 'package:mobile_project_doa_ibu/ui/ticket_page.dart';
import 'package:mobile_project_doa_ibu/ui/homepage_jemaah.dart';
import 'package:mobile_project_doa_ibu/ui/initial_landing_page.dart';
import 'package:mobile_project_doa_ibu/ui/login_page.dart';
import 'package:mobile_project_doa_ibu/ui/register_page.dart';
import 'package:mobile_project_doa_ibu/ui/widgets/design_frame.dart';
import 'package:mobile_project_doa_ibu/ui/widgets/responsive_shell.dart';

/// Ukuran layar (logical px, devicePixelRatio 1) yang harus didukung aplikasi.
const devices = <String, Size>{
  'HP portrait': Size(360, 780),
  'HP landscape': Size(780, 360),
  'tablet portrait': Size(800, 1280),
  'tablet landscape': Size(1280, 800),
  'HP lipat terbuka': Size(884, 1104),
  'HP lipat layar luar': Size(344, 882),
};

TravelApi fakeApi() => TravelApi(
      ApiClient(
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/packages')) {
            return http.Response(
              jsonEncode({
                'data': [],
                'meta': {'current_page': 1, 'last_page': 1, 'total': 0},
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('{"data":[]}', 200, headers: {'content-type': 'application/json'});
        }),
        baseUrl: 'http://test/api/v1',
      ),
    );

TravelPackage samplePackage() => TravelPackage.fromJson({
      'id': 1,
      'name': 'Paket Umrah Reguler 12 Hari dengan Nama Paket yang Cukup Panjang',
      'slug': 'paket-umrah-reguler',
      'excerpt': 'Perjalanan umrah penuh berkah. Hotel strategis dekat Masjidil Haram dan Nabawi.',
      'formatted_price': 'Rp 28.500.000',
      'starting_price': 28500000,
      'duration': '12 Hari',
      'hotel': 'Hotel bintang 4 dekat Haram',
      'quota': 40,
      'remaining_quota': 12,
      'category': {'id': 1, 'name': 'Paket Umrah', 'slug': 'paket-umrah'},
      'images': [],
      'itineraries': [],
      'departure_groups': [],
    });

Future<void> pumpApp(WidgetTester tester, Size size, Widget page) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(builder: ResponsiveShell.builder, home: page));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Font Poppins dari SDK lokal (tanpa jaringan), sama seperti google_auth_pages_test.
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final root = Platform.environment['FLUTTER_ROOT']!;
    final font = ByteData.sublistView(
      await File('$root/bin/cache/artifacts/material_fonts/roboto-regular.ttf').readAsBytes(),
    );
    const codec = StandardMessageCodec();
    final manifest = <String, Object>{
      for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold'])
        'test-font/Poppins-$weight.ttf': [
          <String, Object>{'asset': 'test-font/Poppins-$weight.ttf'},
        ],
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (message) async {
      final name = utf8.decode(message!.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
      if (name == 'AssetManifest.bin') return codec.encodeMessage(manifest);
      if (name.startsWith('test-font/')) return font;
      final asset = File(name);
      if (await asset.exists()) return ByteData.sublistView(await asset.readAsBytes());
      return null;
    });
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
    GoogleFonts.config.allowRuntimeFetching = true;
  });
  setUp(() {
    AppStorage.instance.clear();
    TravelApi.currentUser = null;
  });

  group('ResponsiveShell', () {
    testWidgets('lebar konten dibatasi di tablet, HP lipat, dan landscape; HP portrait tetap penuh', (tester) async {
      for (final entry in devices.entries) {
        late double contentWidth;
        late double mediaWidth;
        await pumpApp(
          tester,
          entry.value,
          Scaffold(
            body: LayoutBuilder(builder: (context, constraints) {
              contentWidth = constraints.maxWidth;
              mediaWidth = MediaQuery.sizeOf(context).width;
              return const SizedBox.expand();
            }),
          ),
        );

        final expected = entry.value.width > ResponsiveShell.maxContentWidth ? ResponsiveShell.maxContentWidth : entry.value.width;
        expect(contentWidth, expected, reason: entry.key);
        expect(mediaWidth, expected, reason: '${entry.key}: MediaQuery ikut lebar konten (dialog/bottom sheet ikut pas)');
      }
    });

    testWidgets('ukuran teks sistem yang ekstrem dibatasi supaya layout tidak pecah', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      late double scale;
      await pumpApp(
        tester,
        const Size(360, 780),
        Builder(builder: (context) {
          scale = MediaQuery.textScalerOf(context).scale(10) / 10;
          return const SizedBox();
        }),
      );
      expect(scale, ResponsiveShell.maxTextScale);
    });
  });

  group('Halaman login & register berbingkai desain', () {
    for (final isLogin in [true, false]) {
      final name = isLogin ? 'Login' : 'Register';

      testWidgets('$name di HP landscape tetap terbaca & bisa di-scroll (tidak mengecil)', (tester) async {
        // Pembanding: ukuran kolom isian di HP portrait (sesuai desain).
        await pumpApp(tester, const Size(412, 915), isLogin ? LoginPage(api: fakeApi()) : RegisterPage(api: fakeApi()));
        final portraitHeight = tester.getRect(find.byType(TextField).first).height;

        await pumpApp(tester, const Size(780, 360), isLogin ? LoginPage(api: fakeApi()) : RegisterPage(api: fakeApi()));

        final field = find.byType(TextField).first;
        // Dulu (FittedBox contain) di landscape kolom menyusut ±2,5× lebih kecil dari portrait.
        // Sekarang paling kecil DesignFrame.minScale (0,85) dibanding skala portrait 1,025.
        expect(tester.getRect(field).height, greaterThanOrEqualTo(portraitHeight * 0.8), reason: 'kolom isian tidak boleh mengecil di landscape');
        expect(find.byType(Scrollable), findsWidgets);

        // Tombol Google di bagian bawah bisa dijangkau dengan scroll.
        await tester.scrollUntilVisible(find.text('Google'), 200, scrollable: find.byType(Scrollable).first);
        expect(find.text('Google'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('$name: kolom isian tidak tertutup keyboard', (tester) async {
        await pumpApp(tester, const Size(412, 915), isLogin ? LoginPage(api: fakeApi()) : RegisterPage(api: fakeApi()));

        final lastField = find.byType(TextField).last;
        final widthBefore = tester.getRect(lastField).width;
        await tester.tap(lastField);
        tester.view.viewInsets = const FakeViewPadding(bottom: 420);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();

        final rect = tester.getRect(lastField);
        expect(rect.bottom, lessThanOrEqualTo(915 - 420), reason: 'kolom yang sedang diisi harus terlihat di atas keyboard');
        expect(rect.width, widthBefore, reason: 'halaman tidak boleh mengecil saat keyboard muncul');
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Halaman berbingkai desain tampil utuh di tablet & HP lipat (tidak kebesaran/terpotong)', () {
    const wideScreens = <String, Size>{
      'tablet landscape': Size(1280, 800),
      'tablet portrait': Size(800, 1280),
      'HP lipat terbuka': Size(884, 1104),
    };
    final framed = <String, (Widget Function(), List<String>)>{
      'Landing awal': (() => InitialLandingPage(api: fakeApi(), onStart: () {}), ['LOGIN', 'Daftar']),
      'Login': (() => LoginPage(api: fakeApi()), ['Google']),
      'Register': (() => RegisterPage(api: fakeApi()), ['Google']),
    };

    for (final page in framed.entries) {
      for (final screen in wideScreens.entries) {
        testWidgets('${page.key} — ${screen.key}', (tester) async {
          await pumpApp(tester, screen.value, page.value.$1());
          for (final label in page.value.$2) {
            final rect = tester.getRect(find.text(label));
            expect(rect.bottom, lessThanOrEqualTo(screen.value.height), reason: '"$label" harus terlihat tanpa scroll');
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(screen.value.width));
          }
          // Bingkai tidak lebih tinggi dari layar → tidak ada yang terpotong di bawah.
          final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
          expect(scrollable.position.maxScrollExtent, 0, reason: 'seluruh desain muat di layar');
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('Landing awal di HP landscape tetap terbaca & tombol LOGIN bisa dijangkau', (tester) async {
      await pumpApp(tester, const Size(780, 360), InitialLandingPage(api: fakeApi(), onStart: () {}));
      final width = tester.getRect(find.descendant(of: find.byType(DesignFrame), matching: find.byType(FittedBox)).first).width;
      expect(width, greaterThanOrEqualTo(414 * DesignFrame.minScale - 1), reason: 'artboard tidak mengecil di bawah skala minimum');
      await tester.scrollUntilVisible(find.text('LOGIN'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('LOGIN').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Tidak ada overflow di semua ukuran layar', () {
    final pages = <String, Widget Function()>{
      'Landing awal': () => InitialLandingPage(api: fakeApi(), onStart: () {}),
      'Login': () => LoginPage(api: fakeApi()),
      'Register': () => RegisterPage(api: fakeApi()),
      'Lupa password': () => ForgotPasswordPage(api: fakeApi()),
      'Beranda jemaah': () => Scaffold(body: HomepageJemaah(api: fakeApi())),
      'Detail paket': () => PackageDetailPage(package: samplePackage(), api: fakeApi()),
      'Form pemesanan': () => BookingFormPage(package: samplePackage(), api: fakeApi()),
      'Kontak': () => ContactPage(api: fakeApi()),
      'Muthawwif saya': () => MuthawwifGuardPage(api: fakeApi()),
      'Profil': () => ProfilePage(api: fakeApi(), onLogout: () {}),
      'Info akun': () => const ProfileAccountInfoPage(name: 'Zara Anselma', email: 'zara@traveldoaibu.test', phone: '081200000003'),
      'Ubah password': () => ProfileChangePasswordPage(api: fakeApi()),
      'Keamanan': () => const ProfileSecurityPage(),
      'Pengaturan': () => const ProfileSettingsPage(),
      'Bahasa': () => const ProfileLanguagePage(),
      'Keluar': () => const ProfileLogoutPage(),
      'Metode pembayaran': () => const ProfilePaymentMethodsPage(),
      'Dompet digital': () => const ProfileDigitalPaymentPage(),
      'PayPal': () => const ProfilePaypalPage(),
      'PayPal terhubung': () => const ProfilePaypalSuccessPage(),
      'Transfer bank/QRIS': () => const ProfileBankTransferQrisPage(),
      'Tiket': () => const TicketPage(),
    };

    for (final page in pages.entries) {
      for (final device in devices.entries) {
        testWidgets('${page.key} — ${device.key}', (tester) async {
          await pumpApp(tester, device.value, page.value());
          expect(tester.takeException(), isNull, reason: '${page.key} overflow/error di ${device.key}');
        });
      }
    }
  });
}
