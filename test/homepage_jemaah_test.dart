import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/main.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/homepage_jemaah.dart';

void main() {
  group('HomepageJemaah & MainScreen Navbar Tests', () {
    testWidgets('menampilkan skeleton card saat paket sedang loading', (tester) async {
      final completer = Completer<http.Response>();

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/packages')) {
          return completer.future;
        }
        return http.Response('{}', 200);
      });

      final api = TravelApi(ApiClient(httpClient: mockClient, baseUrl: 'http://test/api/v1'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomepageJemaah(api: api),
          ),
        ),
      );

      // Pada initial pump, connectionState == ConnectionState.waiting
      await tester.pump();

      // Cek elemen placeholder / icon skeleton muncul saat loading
      expect(find.byIcon(Icons.image_outlined), findsNWidgets(2));

      // Selesaikan future paket
      completer.complete(
        http.Response(
          jsonEncode({
            'data': [
              {
                'id': 1,
                'name': 'Paket Umrah Spesial',
                'slug': 'paket-umrah-spesial',
                'formatted_price': 'Rp 28.000.000',
                'excerpt': 'Perjalanan umrah barokah',
                'category': {'id': 1, 'name': 'Umrah', 'slug': 'umrah'},
              }
            ],
            'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
          }),
          200,
          headers: {'content-type': 'application/json'},
        ),
      );

      await tester.pumpAndSettle();

      // Setelah selesai loading, skeleton hilang dan nama paket muncul
      expect(find.byIcon(Icons.image_outlined), findsNothing);
      expect(find.text('Paket Umrah Spesial'), findsOneWidget);
    });

    testWidgets('menampilkan tombol Coba Lagi saat terjadi kegagalan koneksi', (tester) async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
          return http.Response('Internal Server Error', 500);
        }
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 2,
                'name': 'Paket Bali Eksotis',
                'slug': 'paket-bali-eksotis',
                'formatted_price': 'Rp 4.000.000',
                'category': {'id': 2, 'name': 'Domestik', 'slug': 'domestik'},
              }
            ],
            'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = TravelApi(ApiClient(httpClient: mockClient, baseUrl: 'http://test/api/v1'));

      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomepageJemaah(api: api),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Error message dan tombol Coba Lagi muncul
      expect(find.text('Gagal memuat paket. Periksa koneksi Anda.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Tekan tombol Coba Lagi
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      // Berhasil memuat paket setelah retry
      expect(find.text('Paket Bali Eksotis'), findsOneWidget);
    });

    testWidgets('bottom navbar di MainScreen memiliki tinggi terkunci 57 dan tetap di bagian bawah', (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': [],
            'meta': {'current_page': 1, 'last_page': 1, 'total': 0},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = TravelApi(ApiClient(httpClient: mockClient, baseUrl: 'http://test/api/v1'));

      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(api: api),
        ),
      );

      await tester.pumpAndSettle();

      // Navbar container 250 x 57 tetap ada di bawah
      final navFinder = find.byType(ClipRRect);
      expect(navFinder, findsWidgets);

      // Temukan SizedBox pembatas tinggi 57
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 57,
      );
      expect(sizedBoxFinder, findsOneWidget);

      // Pastikan 4 icon navigasi terbaru tersedia (Halaman Utama, Tiket Saya, Maps, Profile Saya)
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.confirmation_num_outlined), findsOneWidget);
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });
}
