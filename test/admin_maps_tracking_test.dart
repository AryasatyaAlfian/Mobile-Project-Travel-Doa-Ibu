import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_project_doa_ibu/models/admin_tracking_models.dart';
import 'package:mobile_project_doa_ibu/ui/widgets/admin_group_list_sheet.dart';
import 'package:mobile_project_doa_ibu/ui/widgets/admin_jemaah_detail_sheet.dart';
import 'package:mobile_project_doa_ibu/ui/widgets/admin_muthawwif_sheet.dart';
import 'package:mobile_project_doa_ibu/ui/widgets/admin_sos_alert_dialog.dart';

void main() {
  group('GeodesicHelper Calculations', () {
    test('calculateDistanceMeters and formatDistance calculate correctly', () {
      // Dua titik di Makkah (Masjidil Haram ke Abraj Al Bait ~400-600 meter)
      final dist = GeodesicHelper.calculateDistanceMeters(
        21.4225,
        39.8262,
        21.4187,
        39.8256,
      );
      expect(dist, greaterThan(300));
      expect(dist, lessThan(800));

      expect(GeodesicHelper.formatDistance(650), equals('650 m'));
      expect(GeodesicHelper.formatDistance(1200), equals('1,2 km'));
      expect(GeodesicHelper.formatDistance(2400), equals('2,4 km'));
    });

    test('getBearingDirection resolves correct Indonesian direction', () {
      expect(GeodesicHelper.getBearingDirection(0), equals('Utara'));
      expect(GeodesicHelper.getBearingDirection(45), equals('Timur Laut'));
      expect(GeodesicHelper.getBearingDirection(90), equals('Timur'));
      expect(GeodesicHelper.getBearingDirection(180), equals('Selatan'));
      expect(GeodesicHelper.getBearingDirection(270), equals('Barat'));
      expect(GeodesicHelper.getBearingDirection(315), equals('Barat Laut'));
    });

    test('estimateWalkingMinutes gives realistic duration', () {
      expect(GeodesicHelper.estimateWalkingMinutes(75), equals(1));
      expect(GeodesicHelper.estimateWalkingMinutes(1200), equals(16));
    });
  });

  group('Admin Models Parsing', () {
    test('AdminSosAlert parses backend JSON correctly', () {
      final json = {
        'id': 101,
        'status': 'received',
        'message': 'Tolong tersesat',
        'reporter': {
          'id': 55,
          'name': 'Siti Aminah',
          'phone': '08123456789',
        },
        'group': {
          'departure_group': 'AGR-12',
          'package': 'Umrah Plus Turki',
        },
        'location': {
          'available': true,
          'latitude': 21.4225,
          'longitude': 39.8262,
        },
        'delivery': {
          'received_at': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
        },
      };

      final alert = AdminSosAlert.fromJson(json);
      expect(alert.id, equals(101));
      expect(alert.jemaahName, equals('Siti Aminah'));
      expect(alert.groupName, equals('AGR-12'));
      expect(alert.timeAgo, contains('mnt lalu'));
    });

    test('AdminTrackingMember computes initials and out-of-radius correctly', () {
      final safeMember = AdminTrackingMember(
        id: 1,
        name: 'Siti Aminah',
        locationText: 'Dekat Gate 79',
        distanceToMuthawwifMeters: 650,
      );
      expect(safeMember.initials, equals('SA'));
      expect(safeMember.isOutOfRadius, isFalse);
      expect(safeMember.statusBadgeLabel, equals('Aman'));

      final outMember = AdminTrackingMember(
        id: 2,
        name: 'Rina Kartika',
        locationText: 'Ajyad',
        distanceToMuthawwifMeters: 2400,
      );
      expect(outMember.initials, equals('RK'));
      expect(outMember.isOutOfRadius, isTrue);
      expect(outMember.statusBadgeLabel, equals('Di luar · 2,4 km'));
    });
  });

  group('UI Widgets Rendering Tests', () {
    testWidgets('AdminSosAlertDialog renders headline, info card, and actions', (tester) async {
      final alert = AdminSosAlert(
        id: 1,
        jemaahId: 10,
        jemaahName: 'Siti Aminah',
        phone: '08123456789',
        groupName: 'AGR-12',
        muthawwifName: 'Ust. Ahmad Fauzi',
        muthawwifPhone: '08198765432',
        locationText: 'Dekat Gate 79, Masjidil Haram',
        distanceToMuthawwifMeters: 650,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        status: 'received',
      );

      bool viewLocationCalled = false;
      bool callJemaahCalled = false;
      bool callMuthawwifCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminSosAlertDialog(
              alert: alert,
              onViewLocation: () => viewLocationCalled = true,
              onCallJemaah: () => callJemaahCalled = true,
              onCallMuthawwif: () => callMuthawwifCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('SOS Darurat!'), findsOneWidget);
      expect(find.textContaining('Siti Aminah'), findsWidgets);
      expect(find.textContaining('Rombongan AGR-12'), findsOneWidget);
      expect(find.text('Lihat Lokasi Jemaah'), findsOneWidget);
      expect(find.text('Telepon Jemaah'), findsOneWidget);
      expect(find.text('Hubungi Mutawwif'), findsOneWidget);

      await tester.tap(find.text('Lihat Lokasi Jemaah'));
      expect(viewLocationCalled, isTrue);

      await tester.tap(find.text('Telepon Jemaah'));
      expect(callJemaahCalled, isTrue);

      await tester.tap(find.text('Hubungi Mutawwif'));
      expect(callMuthawwifCalled, isTrue);
    });

    testWidgets('AdminGroupListSheet renders summary counters and cards', (tester) async {
      const overview = AdminMapsOverview(
        totalGroups: 5,
        totalJemaah: 118,
        safeCount: 114,
        outOfRadiusCount: 3,
        sosActiveCount: 1,
        groups: [
          AdminDepartureGroupTrack(
            id: 12,
            code: 'AGR-12',
            packageName: 'Umrah Plus Turki',
            city: 'Makkah',
            muthawwifId: 1,
            muthawwifName: 'Ust. Ahmad Fauzi',
            totalJemaah: 24,
            safeCount: 23,
            outOfRadiusCount: 0,
            sosCount: 1,
          ),
        ],
      );

      AdminDepartureGroupTrack? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminGroupListSheet(
              overview: overview,
              onSelectGroup: (g) => selected = g,
            ),
          ),
        ),
      );

      expect(find.text('Grup Berangkat'), findsOneWidget);
      expect(find.text('114'), findsOneWidget);
      expect(find.text('Aman'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Di luar radius'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('SOS aktif'), findsOneWidget);
      expect(find.textContaining('AGR-12 · Umrah Plus Turki'), findsOneWidget);

      await tester.tap(find.textContaining('AGR-12 · Umrah Plus Turki'));
      expect(selected?.code, equals('AGR-12'));
    });

    testWidgets('AdminMuthawwifSheet renders muthawwif info and member list', (tester) async {
      const group = AdminDepartureGroupTrack(
        id: 12,
        code: 'AGR-12',
        packageName: 'Umrah Plus Turki',
        city: 'Makkah',
        muthawwifId: 1,
        muthawwifName: 'Ust. Felix',
        totalJemaah: 24,
        safeCount: 21,
        outOfRadiusCount: 2,
        sosCount: 1,
        members: [
          AdminTrackingMember(
            id: 1,
            name: 'Siti Aminah',
            locationText: 'Dekat Gate 79',
            hasActiveSos: true,
          ),
          AdminTrackingMember(
            id: 2,
            name: 'Rina Kartika',
            locationText: 'Ajyad',
            distanceToMuthawwifMeters: 2400,
          ),
        ],
      );

      AdminTrackingMember? selectedMem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminMuthawwifSheet(
              group: group,
              onSelectMember: (m) => selectedMem = m,
              onCallMuthawwif: () {},
            ),
          ),
        ),
      );

      expect(find.text('Ust. Felix'), findsOneWidget);
      expect(find.text('Mutawwif'), findsOneWidget);
      expect(find.text('Semua · 2'), findsOneWidget);
      expect(find.text('Siti Aminah'), findsOneWidget);
      expect(find.text('Rina Kartika'), findsOneWidget);

      await tester.tap(find.text('Siti Aminah'));
      expect(selectedMem?.name, equals('Siti Aminah'));
    });

    testWidgets('AdminJemaahDetailSheet renders distance metrics and contact buttons', (tester) async {
      const member = AdminTrackingMember(
        id: 10,
        name: 'Zahra Anselma',
        locationText: 'Abraj Al Bait, Lantai Dasar',
        distanceToMuthawwifMeters: 1200,
      );

      const group = AdminDepartureGroupTrack(
        id: 12,
        code: 'AGR-12',
        packageName: 'Umrah Plus Turki',
        city: 'Makkah',
        muthawwifId: 1,
        muthawwifName: 'Ust. Ahmad Fauzi',
        totalJemaah: 24,
        safeCount: 23,
        outOfRadiusCount: 0,
        sosCount: 1,
      );

      bool closeCalled = false;
      bool callJemaah = false;
      bool callMuthawwif = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminJemaahDetailSheet(
              member: member,
              group: group,
              onClose: () => closeCalled = true,
              onCallJemaah: () => callJemaah = true,
              onCallMuthawwif: () => callMuthawwif = true,
            ),
          ),
        ),
      );

      expect(find.text('Zahra Anselma'), findsOneWidget);
      expect(find.text('Rombongan AGR-12'), findsOneWidget);
      expect(find.text('Abraj Al Bait, Lantai Dasar'), findsOneWidget);
      expect(find.text('1,2 km'), findsOneWidget);
      expect(find.text('Jalan kaki'), findsOneWidget);
      expect(find.text('Lewat rute'), findsOneWidget);
      expect(find.text('Arah mutawwif'), findsOneWidget);
      expect(find.text('Hubungi Jemaah'), findsOneWidget);
      expect(find.text('Hubungi Mutawwif'), findsOneWidget);

      await tester.tap(find.text('Hubungi Jemaah'));
      expect(callJemaah, isTrue);

      await tester.tap(find.text('Hubungi Mutawwif'));
      expect(callMuthawwif, isTrue);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closeCalled, isTrue);
    });
  });
}

