import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';
import 'package:mobile_project_doa_ibu/ui/muthawwif/muthawwif_maps_page.dart';

class _GroupApi extends TravelApi {
  _GroupApi(this.groups);
  final List<Map<String, dynamic>> groups;
  final List<int> trackerCalls = [];

  @override
  Future<List<Map<String, dynamic>>> getDepartures({String? month}) async => groups;

  @override
  Future<List<Map<String, dynamic>>> getSosReports({String? status}) async => const [];

  @override
  Future<Map<String, dynamic>> getDepartureGroupTracker(int id) async {
    trackerCalls.add(id);
    return {
      'group': {'id': id},
      'members': const [],
    };
  }
}

Map<String, dynamic> _group(int id, String name) => {
      'id': id,
      'name': name,
      'departure_date': '2026-12-15',
      'package': {'id': 1, 'name': 'Paket QA'},
      'muthawwif': {'id': 2, 'name': 'Ust. Felix', 'phone': '0812'},
      'members': const [],
    };

Future<void> _pump(WidgetTester tester, _GroupApi api, int? initialGroupId) async {
  tester.view.physicalSize = const Size(402, 874);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(MaterialApp(
    home: MuthawwifMapsPage(api: api, initialGroupId: initialGroupId),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('grup B tersedia memuat tracker B, bukan A', (tester) async {
    final api = _GroupApi([_group(1, 'Rombongan A'), _group(2, 'Rombongan B')]);
    await _pump(tester, api, 2);
    expect(api.trackerCalls, [2]);
  });

  testWidgets('grup B tidak ditemukan tidak memanggil tracker pengganti', (tester) async {
    final api = _GroupApi([_group(1, 'Rombongan A')]);
    await _pump(tester, api, 2);
    expect(api.trackerCalls, isEmpty);
    expect(find.text('Grup tidak tersedia atau akses Anda berubah.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('initialGroupId null memakai grup default pertama', (tester) async {
    final api = _GroupApi([_group(1, 'Rombongan A'), _group(2, 'Rombongan B')]);
    await _pump(tester, api, null);
    expect(api.trackerCalls, [1]);
  });

  testWidgets('daftar kosong menampilkan empty state tanpa tracker', (tester) async {
    final api = _GroupApi(const []);
    await _pump(tester, api, null);
    expect(api.trackerCalls, isEmpty);
    expect(find.text('Belum ada grup bimbingan yang ditugaskan.'), findsOneWidget);
  });
}
