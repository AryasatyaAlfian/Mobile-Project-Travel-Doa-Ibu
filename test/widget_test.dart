import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/main.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';

void main() {
  testWidgets('menampilkan paket dari API', (WidgetTester tester) async {
    final mock = MockClient((request) async {
      expect(request.url.path, endsWith('/packages'));
      return http.Response(
        jsonEncode({
          'data': [
            {'id': 1, 'name': 'Paket Bali 4D3N', 'slug': 'bali', 'formatted_price': 'Rp 3.500.000', 'duration': '4 Hari'},
          ],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    await tester.pumpWidget(MyApp(api: TravelApi(ApiClient(httpClient: mock, baseUrl: 'http://test/api/v1'))));
    await tester.pumpAndSettle();

    expect(find.text('Paket Bali 4D3N'), findsOneWidget);
    expect(find.text('Rp 3.500.000'), findsOneWidget);
  });

  test('error validasi 422 diubah menjadi ApiException', () async {
    final mock = MockClient((_) async => http.Response(
          jsonEncode({
            'message': 'Format nomor WhatsApp tidak valid.',
            'errors': {'whatsapp': ['Format nomor WhatsApp tidak valid.']},
          }),
          422,
        ));
    final api = TravelApi(ApiClient(httpClient: mock, baseUrl: 'http://test/api/v1'));

    expect(
      () => api.submitContact(name: 'A', whatsapp: '123', email: 'a@b.c', subject: 's', message: 'm'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 422)
          .having((e) => e.errors['whatsapp'], 'errors', isNotEmpty)),
    );
  });
}
