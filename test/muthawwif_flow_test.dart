import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_project_doa_ibu/models/models.dart';
import 'package:mobile_project_doa_ibu/models/muthawwif_models.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif/muthawwif_day_schedule_page.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif/muthawwif_group_detail_page.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif/muthawwif_home_page.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif/muthawwif_itinerary_page.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif/muthawwif_member_detail_page.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif/muthawwif_member_list_page.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif_shell_page.dart';

class MockTravelApi extends TravelApi {
  @override
  AppUser? get user => AppUser(
        id: 10,
        name: 'Ust. Felix Siauw',
        email: 'felix@traveldoaibu.test',
        isAdmin: false,
        role: 'muthawwif',
        roleLabel: 'Muthawwif',
      );

  @override
  Future<List<Map<String, dynamic>>> getDepartures({String? month}) async {
    return [
      {
        'id': 1,
        'name': 'Rombongan Umrah Reguler Januari 2027',
        'code': 'AGR-12',
        'departure_date': '12 Januari 2027',
        'return_date': '20 Januari 2027',
        'airline': 'Garuda Indonesia (GA-980)',
        'hotel_makkah': 'Anjum Hotel Makkah',
        'hotel_madinah': 'Dar Al Iman Madinah',
        'muthawwif': {
          'id': 10,
          'name': 'Ust. Ahmad Fadli, Lc.',
          'phone': '081234567890',
        },
        'members_count': 24,
      }
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getMuthawwifJemaah({
    String? query,
    int? departureGroupId,
  }) async {
    return [
      {
        'id': 101,
        'name': 'Zara Anselma',
        'is_leader': true,
        'passport_number': 'A1234567',
        'birth_date': '12 Januari 2004',
        'phone': '+62 812 3456 7890',
        'room_makkah': '101 (Double)',
        'room_madinah': '205 (Double)',
      },
      {
        'id': 102,
        'name': 'Aisyah Rahma',
        'is_leader': false,
        'passport_number': 'B7654321',
        'birth_date': '15 Mei 1999',
        'phone': '+62 813 4567 8901',
        'room_makkah': '102 (Triple)',
        'room_madinah': '206 (Triple)',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getSosReports({String? status}) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getDepartureGroupTracker(int groupId) async {
    return {
      'members': [
        {
          'identity': {'id': 101, 'name': 'Rina Kartika', 'phone': '08123456781'},
          'name': 'Rina Kartika',
          'phone': '08123456781',
          'location_text': 'Ajyad · 3 mnt lalu',
          'latitude': 21.4178,
          'longitude': 39.8302,
          'distance_meters': 2400,
          'is_out_of_radius': true,
          'has_active_sos': false,
        },
        {
          'identity': {'id': 102, 'name': 'Hendra Wijaya', 'phone': '08123456782'},
          'name': 'Hendra Wijaya',
          'phone': '08123456782',
          'location_text': 'Misfalah · 1 mnt lalu',
          'latitude': 21.4172,
          'longitude': 39.8248,
          'distance_meters': 2100,
          'is_out_of_radius': true,
          'has_active_sos': false,
        },
        {
          'identity': {'id': 103, 'name': 'Zara Anselma', 'phone': '08123456783'},
          'name': 'Zara Anselma',
          'phone': '08123456783',
          'location_text': 'Abraj Al Bait',
          'latitude': 21.4225,
          'longitude': 39.8262,
          'distance_meters': 250,
          'is_out_of_radius': false,
          'has_active_sos': false,
        },
      ]
    };
  }
}

void main() {
  group('Muthawwif Models Tests', () {
    test('MuthawwifGroupInfo parses correctly from backend json', () {
      final json = {
        'id': 1,
        'name': 'Rombongan Umrah Reguler Januari 2027',
        'code': 'AGR-12',
        'departure_date': '12 Januari 2027',
        'airline': 'Garuda Indonesia (GA-980)',
        'hotel_makkah': 'Anjum Hotel Makkah',
        'hotel_madinah': 'Dar Al Iman Madinah',
        'muthawwif': {
          'name': 'Ust. Ahmad Fadli, Lc.',
          'phone': '081234567890',
        },
        'members_count': 24,
      };

      final group = MuthawwifGroupInfo.fromBackend(groupData: json);
      expect(group.id, 1);
      expect(group.name, 'Rombongan Umrah Reguler Januari 2027');
      expect(group.airline, 'Garuda Indonesia (GA-980)');
      expect(group.muthawwifName, 'Ust. Ahmad Fadli, Lc.');
      expect(group.membersCount, 24);
    });

    test('MuthawwifMemberInfo initializes correctly', () {
      final member = MuthawwifMemberInfo(
        id: 101,
        name: 'Zara Anselma',
        isLeader: true,
        passportNumber: 'A1234567',
        birthDate: '12 Januari 2004',
        phone: '+62 812 3456 7890',
        roomMakkah: '101 (Double)',
        roomMadinah: '205 (Double)',
      );

      expect(member.id, 101);
      expect(member.name, 'Zara Anselma');
      expect(member.isLeader, true);
      expect(member.passportNumber, 'A1234567');
      expect(member.roomMakkah, '101 (Double)');
    });

    test('ItineraryDayItem progress calculation', () {
      final day = ItineraryDayItem(
        dayNumber: 3,
        dayName: 'Rab',
        dateLabel: '14 Jan',
        title: 'Umrah Pertama',
        activities: [
          ItineraryChecklistItem(time: '03.30', title: 'Shalat Tahajud', isCompleted: true),
          ItineraryChecklistItem(time: '04.30', title: 'Persiapan & Sarapan', isCompleted: true),
          ItineraryChecklistItem(time: '06.00', title: 'Briefing Umrah', isCompleted: true),
          ItineraryChecklistItem(time: '07.00', title: 'Berangkat ke Masjidil Haram', isCompleted: false),
          ItineraryChecklistItem(time: '07.30', title: 'Pelaksanaan Umrah', isCompleted: false),
          ItineraryChecklistItem(time: '10.30', title: 'Istirahat & Kegiatan Bebas', isCompleted: false),
        ],
      );

      expect(day.completedCount, 3);
      expect(day.totalCount, 6);
      expect(day.progress, 0.5);
      expect(day.isAllCompleted, false);
    });
  });

  group('Muthawwif UI Widget Tests', () {
    testWidgets('MuthawwifHomePage renders title and 2 menus', (tester) async {
      final mockApi = MockTravelApi();

      await tester.pumpWidget(
        MaterialApp(
          home: MuthawwifHomePage(api: mockApi),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mutawwif'), findsOneWidget);
      expect(find.text('Layanan Mutawwif'), findsOneWidget);
      expect(find.text('Detail Rombongan'), findsOneWidget);
      expect(find.text('Jadwal Kegiatan'), findsOneWidget);
    });

    testWidgets('MuthawwifItineraryPage renders 9 days journey and opens progress dialog', (tester) async {
      final mockApi = MockTravelApi();
      final group = MuthawwifGroupInfo.defaultPreset();

      await tester.pumpWidget(
        MaterialApp(
          home: MuthawwifItineraryPage(api: mockApi, group: group),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jadwal Kegiatan'), findsOneWidget);
      expect(find.text('Jadwal Perjalanan Umrah'), findsOneWidget);
      expect(find.text('Keberangkatan ke Jeddah'), findsOneWidget);
      expect(find.text('Tiba di Makkah & Check-in Hotel'), findsOneWidget);
      expect(find.text('Umrah Pertama'), findsOneWidget);

      // Tap card header summary to show Progres Kegiatan modal dialog
      await tester.tap(find.text('Jadwal Perjalanan Umrah'));
      await tester.pumpAndSettle();

      expect(find.text('Progres Kegiatan'), findsOneWidget);
      expect(find.text('Rombongan Umrah'), findsOneWidget);
      expect(find.text('Lihat Jadwal'), findsOneWidget);
    });

    testWidgets('MuthawwifGroupDetailPage renders rombongan info', (tester) async {
      final mockApi = MockTravelApi();
      final group = MuthawwifGroupInfo.defaultPreset();

      await tester.pumpWidget(
        MaterialApp(
          home: MuthawwifGroupDetailPage(api: mockApi, group: group),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Detail Rombongan'), findsOneWidget);
      expect(find.text('Garuda Indonesia (GA-980)'), findsOneWidget);
      expect(find.text('Lihat Anggota Rombongan'), findsOneWidget);
    });

    testWidgets('MuthawwifMemberListPage renders member list and search', (tester) async {
      final mockApi = MockTravelApi();
      final group = MuthawwifGroupInfo.defaultPreset();

      await tester.pumpWidget(
        MaterialApp(
          home: MuthawwifMemberListPage(api: mockApi, group: group),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Anggota Rombongan'), findsOneWidget);
      expect(find.text('Zara Anselma'), findsOneWidget);
      expect(find.text('Ketua Rombongan'), findsOneWidget);
      expect(find.text('Aisyah Rahma'), findsOneWidget);
    });

    testWidgets('MuthawwifMemberDetailPage renders passport and room numbers', (tester) async {
      final mockApi = MockTravelApi();
      final group = MuthawwifGroupInfo.defaultPreset();
      final member = MuthawwifMemberInfo(
        id: 1,
        name: 'Zara Anselma',
        roleLabel: 'Ketua Rombongan',
        isLeader: true,
        passportNumber: 'A1234567',
        birthDate: '12 Januari 2004',
        phone: '+62 812 3456 7890',
        roomMakkah: '101 (Double)',
        roomMadinah: '205 (Double)',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MuthawwifMemberDetailPage(
            member: member,
            api: mockApi,
            group: group,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zara Anselma'), findsOneWidget);
      expect(find.text('Ketua Rombongan'), findsOneWidget);
      expect(find.text('A1234567'), findsOneWidget);
      expect(find.textContaining('101 (Double)'), findsOneWidget);
      expect(find.textContaining('205 (Double)'), findsOneWidget);
    });

    testWidgets('MuthawwifDaySchedulePage allows toggling checklist item', (tester) async {
      final mockApi = MockTravelApi();
      final day = ItineraryDayItem(
        dayNumber: 3,
        dayName: 'Rab',
        dateLabel: '14 Jan',
        title: 'Umrah Pertama',
        activities: [
          ItineraryChecklistItem(time: '03.30', title: 'Shalat Tahajud (Mandiri)', isCompleted: true),
          ItineraryChecklistItem(time: '07.00', title: 'Berangkat ke Masjidil Haram', isCompleted: false),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MuthawwifDaySchedulePage(
            day: day,
            api: mockApi,
            onScheduleUpdated: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Detail Jadwal (Hari 3)'), findsOneWidget);
      expect(find.text('Shalat Tahajud (Mandiri)'), findsOneWidget);
      expect(find.text('Berangkat ke Masjidil Haram'), findsOneWidget);

      // Tap checklist item 2 to toggle
      await tester.tap(find.text('Berangkat ke Masjidil Haram'));
      await tester.pumpAndSettle();

      expect(day.activities[1].isCompleted, true);
    });

    testWidgets('MuthawwifShellPage renders 3 bottom navigation items', (tester) async {
      final mockApi = MockTravelApi();

      await tester.pumpWidget(
        MaterialApp(
          home: MuthawwifShellPage(api: mockApi),
        ),
      );
      await tester.pumpAndSettle();

      // Memiliki navigasi kapsul melayang dengan 3 ikon
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      // Tab default adalah MuthawwifHomePage
      expect(find.text('Layanan Mutawwif'), findsOneWidget);

      // Pindah ke tab Maps (tab 1)
      await tester.tap(find.byIcon(Icons.map_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Jemaah Rombongan'), findsOneWidget);
      expect(find.text('Dalam radius'), findsOneWidget);

      // Pindah ke tab Profile
      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('MuthawwifMapsPage renders map, banner, and bottom sheet correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockApi = MockTravelApi();

      await tester.pumpWidget(
        MaterialApp(
          home: MuthawwifShellPage(api: mockApi),
        ),
      );
      await tester.pumpAndSettle();

      // Pindah ke tab Maps
      await tester.tap(find.byIcon(Icons.map_outlined));
      await tester.pumpAndSettle();

      // Verifikasi Header Pill
      expect(find.text('Rombongan AGR-12'), findsOneWidget);

      // Verifikasi Banner Peringatan
      expect(find.textContaining('di luar radius aman'), findsOneWidget);

      // Verifikasi Bottom Sheet "Jemaah Rombongan"
      expect(find.text('Jemaah Rombongan'), findsOneWidget);
      expect(find.text('Dalam radius'), findsOneWidget);
      expect(find.text('Di luar radius'), findsOneWidget);
      expect(find.text('SOS aktif'), findsOneWidget);

      // Verifikasi Jemaah List
      expect(find.text('Rina Kartika'), findsOneWidget);
      expect(find.text('Hendra Wijaya'), findsOneWidget);

      // Tap member Rina Kartika untuk masuk ke mode tracking (Gambar 4)
      await tester.tap(find.text('Rina Kartika'));
      await tester.pumpAndSettle();

      // Verifikasi mode tracking: tombol "Lacak Jemaah" dan detail sheet
      expect(find.text('Lacak Jemaah'), findsOneWidget);
      expect(find.text('Hubungi'), findsOneWidget);
      expect(find.text('Petunjuk Arah'), findsOneWidget);

      // Kembali ke overview dengan tap tombol back "Lacak Jemaah"
      await tester.tap(find.text('Lacak Jemaah'));
      await tester.pumpAndSettle();

      expect(find.text('Jemaah Rombongan'), findsOneWidget);
    });
  });
}
