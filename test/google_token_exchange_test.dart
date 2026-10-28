import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_project_doa_ibu/core/api_client.dart';
import 'package:mobile_project_doa_ibu/core/storage/app_storage.dart';
import 'package:mobile_project_doa_ibu/services/travel_api.dart';

void main() {
  setUp(() {
    AppStorage.instance.clear();
    TravelApi.currentUser = null;
  });

  test('empty Google tokens never reach the server', () async {
    var requests = 0;
    final api = TravelApi(
      ApiClient(
        httpClient: MockClient((_) async {
          requests++;
          return http.Response('{}', 200);
        }),
      ),
    );
    for (final token in ['', '   ']) {
      await expectLater(
        api.loginWithGoogle(token),
        throwsA(isA<ApiException>()),
      );
    }
    expect(requests, 0);
  });

  test('a malformed success never replaces an existing session', () async {
    final client = ApiClient(
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'token': '',
            'user': {'id': 9, 'name': 'Unit', 'email': 'unit@example.invalid'},
          }),
          200,
        ),
      ),
    )..token = 'previous-test-session';
    final api = TravelApi(client);
    await expectLater(
      api.loginWithGoogle('test-only-id-token'),
      throwsA(isA<ApiException>()),
    );
    expect(client.token, 'previous-test-session');
    expect(TravelApi.currentUser, isNull);
  });

  test('409 is not linked or replaced by password login', () async {
    var requests = 0;
    final client = ApiClient(
      httpClient: MockClient((request) async {
        requests++;
        expect(request.url.path, endsWith('/auth/google'));
        return http.Response(
          jsonEncode({'message': 'Masuk dengan password lalu tautkan Google.'}),
          409,
        );
      }),
    )..token = 'previous-test-session';
    final api = TravelApi(client);
    await expectLater(
      api.loginWithGoogle('test-only-id-token'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 409)
            .having(
              (e) => e.message,
              'message',
              'Masuk dengan password lalu tautkan Google.',
            ),
      ),
    );
    expect(requests, 1);
    expect(client.token, 'previous-test-session');
    expect(TravelApi.currentUser, isNull);
  });

  test('network failure is propagated without creating a session', () async {
    final client = ApiClient(
      httpClient: MockClient(
        (_) async => throw http.ClientException('test-only-network-error'),
      ),
    );
    final api = TravelApi(client);
    await expectLater(
      api.loginWithGoogle('test-only-id-token'),
      throwsA(isA<ApiException>()),
    );
    expect(client.token, isNull);
    expect(TravelApi.currentUser, isNull);
  });

  for (final status in [200, 201]) {
    test(
      'Google exchange $status saves the backend session and profile',
      () async {
        final client = ApiClient(
          baseUrl: 'https://unit.test/api/v1',
          httpClient: MockClient((request) async {
            expect(request.method, 'POST');
            expect(request.url.path, '/api/v1/auth/google');
            expect(jsonDecode(request.body), {
              'id_token': 'test-only-id-token',
              'device_name': 'mobile_project_doa_ibu',
            });
            return http.Response(
              jsonEncode({
                'token': 'test-only-session',
                'token_type': 'Bearer',
                'user': {
                  'id': 7,
                  'name': 'Unit user',
                  'email': 'unit@example.invalid',
                },
              }),
              status,
            );
          }),
        );
        final api = TravelApi(client);
        final user = await api.loginWithGoogle('test-only-id-token');
        expect(user.id, 7);
        expect(client.token, 'test-only-session');
        expect(TravelApi.currentUser?.id, 7);
        expect(AppStorage.instance.get('auth_token'), 'test-only-session');
        expect(jsonDecode(AppStorage.instance.get('user_profile')!)['id'], 7);
      },
    );
  }
}
