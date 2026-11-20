import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/jemaah_services_pages.dart';

class _FakeApi extends TravelApi {
  _FakeApi({this.profile = const {}, this.documents = const [], this.groups = const []});

  final Map<String, dynamic> profile;
  final List<Map<String, dynamic>> documents;
  final List<Map<String, dynamic>> groups;

  @override
  Future<Map<String, dynamic>> getProfile() async => profile;

  @override
  Future<List<Map<String, dynamic>>> getDocuments() async => documents;

  @override
  Future<List<Map<String, dynamic>>> getDepartures({String? month}) async => groups;

  @override
  Future<List<Map<String, dynamic>>> getMuthawwifJemaah({String? query, int? departureGroupId}) async => const [];

}

Map<String, dynamic> _profile({String visa = 'processing', bool withGroup = true}) => {
      'id': 3,
      'name': 'Zara Anselma',
      'email': 'zara@traveldoaibu.test',
      'phone': '081200000003',
      'role': 'jemaah',
      'identity': {'id': 3, 'name': 'Zara Anselma', 'phone': '081200000003'},
      'group': {'name': withGroup ? 'Rombongan Umrah Desember' : null},
      'profile': {
        'gender': 'P',
        'birth_date': '1998-04-12',
        'address': 'Jl. Melati No. 21',
        'city': 'Bandung',
        'passport_number': 'C1234567',
        'passport_expiry': '2031-08-30',
        'visa_status': visa,
        'visa_number': 'V-778899',
        'visa_expiry': '2026-12-01',
        'group_name': 'Rombongan Umrah Desember',
        'emergency_contact_name': 'Ibu Ratna',
        'emergency_contact_phone': '081200000099',
      },
      'muthawwif': {'id': 2, 'name': 'Ust. Felix', 'phone': '081200000002'},
      'package': {'id': 11, 'name': 'Paket Umrah 15 Hari', 'slug': 'umrah-15'},
      'departure_group': withGroup
          ? {'id': 1, 'name': 'Rombongan A', 'departure_date': '2026-11-07', 'return_date': '2026-12-07', 'tour_leader_name': 'Ust. Felix'}
          : null,
      'updated_at': '2026-11-20T12:00:00+07:00',
    };

void main() {
  testWidgets('Profil Jemaah menampilkan identitas dan pembimbing', (tester) async {
    await tester.pumpWidget(MaterialApp(home: JemaahProfileDetailPage(api: _FakeApi(profile: _profile()))));
    await tester.pumpAndSettle();
    expect(find.text('Zara Anselma'), findsWidgets);
    expect(find.text('Paket Umrah 15 Hari'), findsOneWidget);
    expect(find.text('Ust. Felix'), findsOneWidget);
    expect(find.text('Rombongan Umrah Desember'), findsOneWidget);
  });

  testWidgets('Visa & Keberangkatan menampilkan status dan tanggal', (tester) async {
    await tester.pumpWidget(MaterialApp(home: VisaDeparturePage(api: _FakeApi(profile: _profile()))));
    await tester.pumpAndSettle();
    expect(find.text('Sedang diproses'), findsOneWidget);
    expect(find.text('V-778899'), findsOneWidget);
    expect(find.text('7 Nov 2026'), findsOneWidget);
  });

  testWidgets('Dokumen kosong menampilkan kelengkapan 0/4 dan ajakan unggah', (tester) async {
    await tester.pumpWidget(MaterialApp(home: DocumentsPage(api: _FakeApi())));
    await tester.pumpAndSettle();
    expect(find.text('0/4'), findsOneWidget);
    expect(find.text('Belum ada dokumen'), findsOneWidget);
    expect(find.text('Unggah Dokumen'), findsOneWidget);
  });

  testWidgets('Dokumen terisi menghitung kelengkapan 2/4', (tester) async {
    final docs = [
      {'id': 1, 'document_type': 'passport', 'original_name': 'paspor.pdf', 'file_name': 'a.pdf', 'size': 2048, 'uploaded_at': '2026-11-20', 'is_image': false},
      {'id': 2, 'document_type': 'ktp', 'original_name': 'ktp.png', 'file_name': 'b.png', 'size': 1024, 'uploaded_at': '2026-11-20', 'is_image': true},
    ];
    await tester.pumpWidget(MaterialApp(home: DocumentsPage(api: _FakeApi(documents: docs))));
    await tester.pumpAndSettle();
    expect(find.text('2/4'), findsOneWidget);
    expect(find.text('paspor.pdf'), findsOneWidget);
    expect(find.text('ktp.png'), findsOneWidget);
  });

  testWidgets('Riwayat Keberangkatan menampilkan grup dan anggota', (tester) async {
    final groups = [
      {
        'id': 1,
        'name': 'Rombongan A',
        'departure_date': '2026-11-07',
        'package': {'id': 1, 'name': 'Paket Umrah 15 Hari'},
        'members': [
          {'id': 3, 'name': 'Zara Anselma', 'visa_status': 'processing', 'visa_label': 'Sedang diproses'},
        ],
      }
    ];
    await tester.pumpWidget(MaterialApp(home: DepartureHistoryPage(api: _FakeApi(groups: groups))));
    await tester.pumpAndSettle();
    expect(find.text('Rombongan A'), findsOneWidget);
    expect(find.textContaining('1 jemaah'), findsOneWidget);
    await tester.tap(find.text('Rombongan A'));
    await tester.pumpAndSettle();
    expect(find.text('Zara Anselma'), findsOneWidget);
    expect(find.text('Sedang diproses'), findsOneWidget);
  });

  testWidgets('Kelola Jemaah menampilkan daftar grup', (tester) async {
    final groups = [
      {
        'id': 1,
        'name': 'Rombongan A',
        'departure_date': '2026-11-07',
        'members': [
          {'id': 4, 'name': 'Nadia Putri', 'visa_status': 'not_started'},
        ],
      }
    ];
    await tester.pumpWidget(MaterialApp(home: GroupManagementPage(api: _FakeApi(groups: groups), isAdmin: true)));
    await tester.pumpAndSettle();
    expect(find.text('Rombongan A'), findsOneWidget);
    expect(find.textContaining('1 jemaah'), findsOneWidget);
  });
}
