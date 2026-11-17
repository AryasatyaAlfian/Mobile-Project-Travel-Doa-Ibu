import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/main.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';

Map<String, dynamic> _package(int id, String name, {String? categoryName, String? categorySlug}) => {
      'id': id,
      'name': name,
      'slug': 'paket-$id',
      'formatted_price': 'Rp 1.000.000',
      'duration': '3 Hari 2 Malam',
      if (categoryName != null)
        'category': {'id': id, 'name': categoryName, 'slug': categorySlug ?? 'kategori-$id'},
    };

String _page(List<Map<String, dynamic>> items, int page, int lastPage, int total) => jsonEncode({
      'data': items,
      'meta': {'current_page': page, 'last_page': lastPage, 'per_page': 50, 'total': total},
    });

void main() {
  group('TravelApi.allPackages', () {
    test('membaca seluruh halaman, bukan hanya halaman pertama', () async {
      final requestedPages = <String>[];
      final client = MockClient((request) async {
        final page = request.url.queryParameters['page'] ?? '1';
        requestedPages.add(page);
        if (page == '1') {
          return http.Response(
            _page([_package(1, 'Paket Umrah A'), _package(2, 'Paket Umrah B')], 1, 2, 3),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          _page([_package(3, 'Paket Domestik C')], 2, 2, 3),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = TravelApi(ApiClient(httpClient: client, baseUrl: 'http://test/api/v1'));
      final packages = await api.allPackages();

      expect(packages.map((p) => p.id), [1, 2, 3]);
      expect(requestedPages, ['1', '2']);
    });

    test('berhenti setelah halaman terakhir walau last_page lebih besar dari jumlah data', () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        return http.Response(
          _page([], 1, 1, 0),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = TravelApi(ApiClient(httpClient: client, baseUrl: 'http://test/api/v1'));
      expect(await api.allPackages(), isEmpty);
      expect(calls, 1);
    });
  });

  group('PackageListPage kategori', () {
    testWidgets('chip "Umrah" mengirim slug backend, bukan label', (tester) async {
      final categoryQueries = <String?>[];
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/categories')) {
          return http.Response(
            jsonEncode({
              'data': [
                {'id': 9, 'name': 'Paket Umrah', 'slug': 'paket-umrah'},
                {'id': 1, 'name': 'Wisata Domestik', 'slug': 'wisata-domestik'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        categoryQueries.add(request.url.queryParameters['category']);
        return http.Response(
          _page([_package(1, 'Paket Umrah A', categoryName: 'Paket Umrah', categorySlug: 'paket-umrah')], 1, 1, 1),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = TravelApi(ApiClient(httpClient: client, baseUrl: 'http://test/api/v1'));
      await tester.pumpWidget(MaterialApp(home: PackageListPage(api: api)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Umrah').first);
      await tester.pumpAndSettle();

      expect(categoryQueries, isNotEmpty);
      expect(categoryQueries.last, 'paket-umrah');
    });
  });
}
