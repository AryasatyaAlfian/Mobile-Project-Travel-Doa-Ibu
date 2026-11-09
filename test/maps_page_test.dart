import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/maps_my_location_sheet.dart';
import 'package:mobile_project_doa_ibu/ui/maps_page.dart';
import 'package:mobile_project_doa_ibu/ui/maps_track_muthawwif_view.dart';
import 'package:mobile_project_doa_ibu/ui/widgets/maps_canvas_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TravelApi fakeApi;

  setUp(() {
    fakeApi = TravelApi(
      ApiClient(
        baseUrl: 'http://test.local/api',
        httpClient: MockClient((request) async {
          if (request.url.path.contains('/me/location/status')) {
            return http.Response('{"status":"success","data":{"state":"available"}}', 200);
          }
          if (request.url.path.contains('/me/location')) {
            return http.Response('{"status":"success","data":{"id":1}}', 200);
          }
          if (request.url.path.contains('/me/sos')) {
            return http.Response('{"status":"success","data":{"sos_id":99}}', 200);
          }
          if (request.url.path.contains('/me/tracker')) {
            return http.Response(
              '{"status":"success","data":{"identity":{"name":"Zara Anselma"},"group":{"code":"AGR8598"}}}',
              200,
            );
          }
          if (request.url.path.contains('/me/muthawwif/contact')) {
            return http.Response(
              '{"status":"success","data":{"name":"Ust. Ahmad Fauzi","phone":"081234567890"}}',
              200,
            );
          }
          return http.Response('{"status":"error","message":"Not found"}', 404);
        }),
      ),
    );
  });

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Maps UI UX Tests', () {
    testWidgets('Renders MapsPage in normal state with all controls', (tester) async {
      setupScreen(tester);

      await tester.pumpWidget(createWidgetUnderTest(MapsPage(api: fakeApi)));
      await tester.pump(const Duration(milliseconds: 300));

      // Verifikasi komponen peta & header
      expect(find.byType(MapsCanvasView), findsOneWidget);
      expect(find.text('Hi, Zara'), findsOneWidget);
      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.text('Check In'), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);

      // Verifikasi tombol island
      expect(find.byIcon(Icons.groups_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('Tapping Check In triggers location API and shows feedback', (tester) async {
      setupScreen(tester);

      await tester.pumpWidget(createWidgetUnderTest(MapsPage(api: fakeApi)));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Check In
      final checkInBtn = find.text('Check In');
      expect(checkInBtn, findsOneWidget);
      await tester.tap(checkInBtn);
      await tester.pump(const Duration(milliseconds: 500));

      // Cek SnackBar muncul
      expect(find.textContaining('Check In berhasil dicatat'), findsOneWidget);
    });

    testWidgets('SOS flow: Triggering activates countdown timer and can be cancelled', (tester) async {
      setupScreen(tester);

      await tester.pumpWidget(createWidgetUnderTest(MapsPage(api: fakeApi)));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap SOS
      final sosBtn = find.text('SOS');
      expect(sosBtn, findsOneWidget);
      await tester.tap(sosBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Banner SOS muncul
      expect(find.text('SOS TERKIRIM'), findsOneWidget);
      expect(find.textContaining('SOS', findRichText: true), findsWidgets);

      // Majukan waktu 3 detik
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('00:03'), findsOneWidget);

      // Batalkan SOS
      final cancelBtn = find.text('Batalkan');
      expect(cancelBtn, findsOneWidget);
      await tester.tap(cancelBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Mode SOS dinonaktifkan
      expect(find.text('SOS TERKIRIM'), findsNothing);
      expect(find.text('SOS'), findsOneWidget);
      expect(find.textContaining('Panggilan Darurat Dibatalkan'), findsOneWidget);
    });

    testWidgets('Tapping Right Island Button opens MapsMyLocationSheet with toggle', (tester) async {
      setupScreen(tester);

      await tester.pumpWidget(createWidgetUnderTest(MapsPage(api: fakeApi)));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap tombol lokasi saya di island
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verifikasi bottom sheet terbuka
      expect(find.byType(MapsMyLocationSheet), findsOneWidget);
      expect(find.text('Lokasi Saya'), findsWidgets);
      expect(find.text('Bagikan ke Rombongan'), findsOneWidget);
      expect(find.text('Dibagikan dari'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // Toggle switch berbagi lokasi
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.textContaining('Berbagi lokasi ke rombongan dinonaktifkan'), findsOneWidget);
    });

    testWidgets('Tapping Left Island Button navigates to MapsTrackMuthawwifView', (tester) async {
      setupScreen(tester);

      await tester.pumpWidget(createWidgetUnderTest(MapsPage(api: fakeApi)));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap tombol Lacak Mutawwif di island
      await tester.tap(find.byIcon(Icons.groups_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verifikasi halaman Lacak Mutawwif
      expect(find.byType(MapsTrackMuthawwifView), findsOneWidget);
      expect(find.text('Lacak Mutawwif'), findsOneWidget);
      expect(find.text('Ust. Ahmad Fauzi'), findsOneWidget);
      expect(find.text('Gerbang King Abdul Aziz (Gate 1)'), findsOneWidget);
      expect(find.text('1,2'), findsOneWidget);
      expect(find.text('15 mnt'), findsWidgets);
      expect(find.text('Timur Laut'), findsOneWidget);

      // Tap Hubungi
      await tester.tap(find.text('Hubungi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Menghubungi Ust. Ahmad Fauzi'), findsOneWidget);

      // Hapus SnackBar saat ini agar tidak menghalangi tombol Petunjuk Arah
      ScaffoldMessenger.of(tester.element(find.byType(MapsTrackMuthawwifView))).removeCurrentSnackBar();
      await tester.pump();

      // Tap Petunjuk Arah
      await tester.tap(find.text('Petunjuk Arah'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Rute navigasi ke Ust. Ahmad Fauzi'), findsOneWidget);
    });

    testWidgets('Tapping Muthawwif marker on map opens MapsTrackMuthawwifView', (tester) async {
      setupScreen(tester);

      await tester.pumpWidget(createWidgetUnderTest(MapsPage(api: fakeApi)));
      await tester.pump(const Duration(milliseconds: 300));

      // Temukan marker Muthawwif pada peta (teks 'Mutawaf')
      final muthawwifMarker = find.text('Mutawaf');
      expect(muthawwifMarker, findsOneWidget);

      await tester.tap(muthawwifMarker);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verifikasi bottom sheet Lacak Mutawwif terbuka
      expect(find.byType(MapsTrackMuthawwifView), findsOneWidget);
      expect(find.text('Gerbang King Abdul Aziz (Gate 1)'), findsOneWidget);
    });
  });
}

