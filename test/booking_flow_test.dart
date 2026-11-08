import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/models/models.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/booking_form_page.dart';
import 'package:mobile_project_doa_ibu/ui/package_detail_page.dart';

class MockApiClient extends ApiClient {
  MockApiClient() : super();

  Map<String, dynamic>? lastPostPayload;
  String? lastPostPath;

  @override
  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    lastPostPath = path;
    lastPostPayload = body;

    if (path == '/bookings') {
      return {
        'message': 'Pemesanan Anda telah kami terima. Tim kami akan menghubungi dalam 1×24 jam.',
        'data': {
          'id': 99,
          'status': 'new',
          'customer_name': body?['customer_name'] ?? 'Zara',
          'participants': body?['participants'] ?? 2,
        },
      };
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    if (path == '/packages/paket-umrah-reguler-12-hari') {
      return {
        'data': {
          'id': 2,
          'name': 'Paket Umrah Reguler 12 Hari',
          'slug': 'paket-umrah-reguler-12-hari',
          'formatted_price': 'Rp 28.500.000',
          'starting_price': 28500000,
          'duration': '12 Hari',
          'airline': 'Saudi Airlines',
          'hotel': 'Hotel setara bintang 4 dekat Haram',
          'meals': '3x sehari menu Indonesia',
          'category': {'id': 1, 'name': 'Paket Umrah', 'slug': 'umrah'},
          'features': [
            {'title': 'Bus AC Eksklusif', 'icon': 'bus', 'description': 'Transportasi jemaah'},
            {'title': 'Bimbingan Muthawwif', 'icon': 'mutawif', 'description': 'Pendamping bersertifikat'},
          ],
          'itineraries': [
            {
              'day_number': 1,
              'title': 'Jakarta - Jeddah - Mekkah',
              'description': 'Penerbangan Jakarta - Jeddah, check-in hotel.',
              'meals': 'Makan Malam',
            },
            {
              'day_number': 2,
              'title': 'Ibadah Umrah Pertama',
              'description': 'Melaksanakan Tawaf dan Sa\'i.',
              'meals': 'Sarapan & Makan Siang',
            },
          ],
          'inclusions': ['Tiket Pesawat PP', 'Air Zamzam 5L'],
          'exclusions': ['Pembuatan Paspor'],
        },
      };
    }
    if (path.startsWith('/packages/')) {
      return {
        'data': {
          'id': 1,
          'name': 'Paket Umrah Plus Turki 15 Hari',
          'slug': 'paket-umrah-plus-turki-15-hari',
          'formatted_price': 'Rp 35.000.000',
          'duration': '15 Hari',
          'departure_date': '2027-01-12',
          'quota': 30,
          'remaining_quota': 12,
          'airline': 'Saudia Airlines',
          'category': {'id': 1, 'name': 'Paket Umrah', 'slug': 'umrah'},
          'departure_groups': [
            {
              'id': 101,
              'name': 'Rombongan Syawal A',
              'departure_date': '2027-01-12',
              'remaining_quota': 12,
              'is_full': false,
            },
            {
              'id': 102,
              'name': 'Rombongan Syawal B',
              'departure_date': '2027-02-09',
              'remaining_quota': 20,
              'is_full': false,
            },
          ],
        },
      };
    }
    return {};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiClient mockClient;
  late TravelApi mockApi;
  late TravelPackage testPackage;

  setUp(() {
    mockClient = MockApiClient();
    mockApi = TravelApi(mockClient);
    testPackage = TravelPackage(
      id: 1,
      name: 'Paket Umrah Plus Turki 15 Hari',
      slug: 'paket-umrah-plus-turki-15-hari',
      formattedPrice: 'Rp 35.000.000',
      duration: '15 Hari',
      departureDate: DateTime(2027, 1, 12),
      quota: 30,
      remainingQuota: 12,
      category: PackageCategory(id: 1, name: 'Paket Umrah', slug: 'umrah'),
      departureGroups: [
        DepartureGroupItem(
          id: 101,
          name: 'Rombongan Syawal A',
          departureDate: DateTime(2027, 1, 12),
          remainingQuota: 12,
          isFull: false,
        ),
        DepartureGroupItem(
          id: 102,
          name: 'Rombongan Syawal B',
          departureDate: DateTime(2027, 2, 9),
          remainingQuota: 0,
          isFull: true,
        ),
      ],
    );
  });

  group('PackageDetailPage Widget Tests', () {
    testWidgets('menampilkan rincian paket, fasilitas, dan jadwal keberangkatan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: PackageDetailPage(package: testPackage, api: mockApi),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Paket Umrah Plus Turki 15 Hari'), findsWidgets);
      expect(find.text('Jadwal Keberangkatan'), findsOneWidget);
      expect(find.text('Pilihan Tipe Kamar'), findsOneWidget);
      expect(find.text('Pesan Sekarang'), findsOneWidget);
    });

    testWidgets('dapat memilih tipe kamar dan mengubah total biaya di bottom bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: PackageDetailPage(package: testPackage, api: mockApi),
        ),
      );
      await tester.pumpAndSettle();

      // Default Quad
      expect(find.text('Rp 35.000.000'), findsWidgets);

      // Scroll down to Pilihan Tipe Kamar
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Pilih Double
      final doubleOption = find.text('Double').first;
      await tester.tap(doubleOption);
      await tester.pumpAndSettle();

      expect(find.text('Rp 40.500.000'), findsWidgets);
    });

    testWidgets('menampilkan data dinamis dari database (hotel, itinerary, fasilitas, inclusions)', (tester) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dynamicPackage = TravelPackage(
        id: 2,
        name: 'Paket Umrah Reguler 12 Hari',
        slug: 'paket-umrah-reguler-12-hari',
        formattedPrice: 'Rp 28.500.000',
        startingPrice: 28500000,
        hotel: 'Hotel setara bintang 4 dekat Haram',
        airline: 'Saudi Airlines',
        meals: '3x sehari menu Indonesia',
        itineraries: [
          ItineraryDay(
            dayNumber: 1,
            title: 'Jakarta - Jeddah - Mekkah',
            description: 'Penerbangan Jakarta - Jeddah, check-in hotel.',
            meals: 'Makan Malam',
          ),
          ItineraryDay(
            dayNumber: 2,
            title: 'Ibadah Umrah Pertama',
            description: 'Melaksanakan Tawaf dan Sa\'i.',
            meals: 'Sarapan & Makan Siang',
          ),
        ],
        features: [
          PackageFeatureItem(title: 'Bus AC Eksklusif', icon: 'bus', description: 'Transportasi jemaah'),
          PackageFeatureItem(title: 'Bimbingan Muthawwif', icon: 'mutawif', description: 'Pendamping bersertifikat'),
        ],
        inclusions: ['Tiket Pesawat PP', 'Air Zamzam 5L'],
        exclusions: ['Pembuatan Paspor'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PackageDetailPage(package: dynamicPackage, api: mockApi),
        ),
      );
      await tester.pumpAndSettle();

      // Cek nama paket & specs
      expect(find.text('Paket Umrah Reguler 12 Hari'), findsWidgets);
      expect(find.text('Saudi Airlines'), findsWidgets);

      // Cek fasilitas dinamis dari features
      expect(find.text('Bus AC Eksklusif'), findsOneWidget);
      expect(find.text('Bimbingan Muthawwif'), findsOneWidget);

      // Cek hotel dinamis dari database
      expect(find.text('Hotel setara bintang 4 dekat Haram'), findsOneWidget);

      // Cek itinerary dinamis dari database
      expect(find.text('Jakarta - Jeddah - Mekkah'), findsOneWidget);
      expect(find.text('Ibadah Umrah Pertama'), findsOneWidget);
      expect(find.text('Makan: Makan Malam'), findsOneWidget);

      // Cek inclusions & exclusions dinamis
      expect(find.text('Tiket Pesawat PP'), findsOneWidget);
      expect(find.text('Air Zamzam 5L'), findsOneWidget);
      expect(find.text('Pembuatan Paspor'), findsOneWidget);
    });
  });

  group('BookingFormPage Multi-Step Tests', () {
    testWidgets('Step 1 validasi form data diri dan navigasi ke Step 2', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: BookingFormPage(package: testPackage, api: mockApi),
        ),
      );
      await tester.pumpAndSettle();

      // Coba klik lanjut tanpa isi form
      await tester.tap(find.text('Lanjut ke Detail Pesanan'));
      await tester.pumpAndSettle();
      expect(find.text('Nama Lengkap wajib diisi.'), findsOneWidget);

      // Isi Nama Lengkap
      await tester.enterText(find.byType(TextField).at(0), 'Zara Anselma');
      await tester.tap(find.text('Lanjut ke Detail Pesanan'));
      await tester.pumpAndSettle();
      expect(find.text('NIK harus 16 digit.'), findsOneWidget);

      // Isi NIK 16 digit, Paspor, WA, Email
      await tester.enterText(find.byType(TextField).at(1), '3201010101010001');
      await tester.enterText(find.byType(TextField).at(2), 'C1234567'); // Paspor
      await tester.enterText(find.byType(TextField).at(3), '081234567890'); // WhatsApp
      await tester.enterText(find.byType(TextField).at(4), 'zara@example.com'); // Email

      await tester.tap(find.text('Lanjut ke Detail Pesanan'));
      await tester.pumpAndSettle();

      // Verifikasi berhasil masuk ke Step 2 (Detail Pesanan)
      expect(find.text('Lanjut ke Konfirmasi Pesanan'), findsOneWidget);
      expect(find.text('Jumlah Jemaah'), findsOneWidget);
    });

    testWidgets('Step 2 kalkulasi harga dinamis dan navigasi ke Step 3 Pembayaran', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: BookingFormPage(package: testPackage, api: mockApi),
        ),
      );
      await tester.pumpAndSettle();

      // Isi Step 1
      await tester.enterText(find.byType(TextField).at(0), 'Zara Anselma');
      await tester.enterText(find.byType(TextField).at(1), '3201010101010001');
      await tester.enterText(find.byType(TextField).at(3), '081234567890');
      await tester.enterText(find.byType(TextField).at(4), 'zara@example.com');
      await tester.tap(find.text('Lanjut ke Detail Pesanan'));
      await tester.pumpAndSettle();

      // Step 2: Default Dewasa = 2, Kamar = Quad (Rp 35 jt) -> Total Rp 70.000.000
      expect(find.text('Rp 70.000.000'), findsWidgets);

      // Lanjut ke Step 3 (Pembayaran)
      await tester.tap(find.text('Lanjut ke Konfirmasi Pesanan'));
      await tester.pumpAndSettle();

      // Verifikasi layar pembayaran aktif
      expect(find.text('Tagihan Anda'), findsOneWidget);
      expect(find.text('Bayar Sekarang'), findsOneWidget);
      expect(find.text('Virtual Account'), findsOneWidget);
      expect(find.text('Sisa Waktu'), findsOneWidget);
    });

    testWidgets('Step 3 proses pembayaran memanggil API bookings dengan departure_group_id', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: BookingFormPage(package: testPackage, api: mockApi),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1
      await tester.enterText(find.byType(TextField).at(0), 'Zara Anselma');
      await tester.enterText(find.byType(TextField).at(1), '3201010101010001');
      await tester.enterText(find.byType(TextField).at(3), '081234567890');
      await tester.enterText(find.byType(TextField).at(4), 'zara@example.com');
      await tester.tap(find.text('Lanjut ke Detail Pesanan'));
      await tester.pumpAndSettle();

      // Step 2
      await tester.tap(find.text('Lanjut ke Konfirmasi Pesanan'));
      await tester.pumpAndSettle();

      // Step 3: Tekan Bayar Sekarang
      await tester.tap(find.text('Bayar Sekarang'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verifikasi API terpanggil
      expect(mockClient.lastPostPath, '/bookings');
      expect(mockClient.lastPostPayload?['departure_group_id'], 101);
      expect(mockClient.lastPostPayload?['customer_name'], 'Zara Anselma');
      expect(mockClient.lastPostPayload?['customer_whatsapp'], '081234567890');
      expect(mockClient.lastPostPayload?['terms_accepted'], true);

      // Verifikasi dialog sukses muncul
      expect(find.text('Pemesanan Berhasil!'), findsOneWidget);
    });
  });
}
