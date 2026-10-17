import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Error dari API. [errors] berisi pesan validasi per field (HTTP 422).
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.errors = const {}});

  final String message;
  final int? statusCode;
  final Map<String, List<String>> errors;

  @override
  String toString() => message;
}

/// Wrapper tipis di atas package:http: JSON, token Bearer, dan error handling.
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _http;
  final String _baseUrl;

  /// Token Sanctum hasil login; dikirim otomatis di setiap request.
  String? token;

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) {
    final params = query?.map((k, v) => MapEntry(k, '$v'))
      ?..removeWhere((_, v) => v == 'null' || v.isEmpty);
    return _send(() => _http.get(_uri(path, params), headers: _headers()));
  }

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) {
    return _send(() => _http.post(_uri(path), headers: _headers(), body: jsonEncode(body ?? {})));
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) {
    return _send(() => _http.patch(_uri(path), headers: _headers(), body: jsonEncode(body)));
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$_baseUrl$path');
    return query == null || query.isEmpty ? uri : uri.replace(queryParameters: query);
  }

  Map<String, String> _headers() => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw ApiException('Server tidak merespons. Coba lagi.');
    } catch (_) {
      throw ApiException('Tidak dapat terhubung ke server ($_baseUrl).');
    }

    final dynamic decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};

    if (response.statusCode >= 200 && response.statusCode < 300) return body;

    final errors = <String, List<String>>{};
    if (body['errors'] is Map) {
      (body['errors'] as Map).forEach((key, value) {
        errors['$key'] = (value as List).map((e) => '$e').toList();
      });
    }
    throw ApiException(
      body['message'] as String? ?? 'Terjadi kesalahan (${response.statusCode}).',
      statusCode: response.statusCode,
      errors: errors,
    );
  }
}
