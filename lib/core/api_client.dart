import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'storage/app_storage.dart';

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
        _baseUrl = baseUrl ?? ApiConfig.baseUrl {
    _token = AppStorage.instance.get('auth_token');
  }

  final http.Client _http;
  final String _baseUrl;

  String? _token;

  /// Token Sanctum hasil login; tersimpan persisten di AppStorage.
  String? get token => _token;
  set token(String? val) {
    _token = val;
    if (val != null && val.isNotEmpty) {
      AppStorage.instance.set('auth_token', val);
    } else {
      AppStorage.instance.remove('auth_token');
    }
  }

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

  Future<Map<String, dynamic>> put(String path, [Map<String, dynamic>? body]) {
    return _send(() => _http.put(_uri(path), headers: _headers(), body: jsonEncode(body ?? {})));
  }


  /// Unggah berkas multipart (dokumen). Mengembalikan JSON seperti [_send].
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String field,
    required String filePath,
    required String filename,
    Map<String, String> fields = const {},
  }) async {
    final request = http.MultipartRequest('POST', _uri(path))
      ..headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      })
      ..fields.addAll(fields)
      ..files.add(await http.MultipartFile.fromPath(field, filePath, filename: filename));

    final http.Response response;
    try {
      final streamed = await request.send().timeout(ApiConfig.timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException('Unggahan melewati batas waktu. Coba lagi.');
    } catch (_) {
      throw ApiException('Tidak dapat mengunggah berkas ke server.');
    }

    final dynamic decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};
    if (response.statusCode >= 200 && response.statusCode < 300) return body;

    final errors = <String, List<String>>{};
    if (body['errors'] is Map) {
      (body['errors'] as Map).forEach((key, value) => errors['$key'] = (value as List).map((e) => '$e').toList());
    }
    throw ApiException(body['message'] as String? ?? 'Gagal mengunggah berkas (${response.statusCode}).', statusCode: response.statusCode, errors: errors);
  }

  /// Unduh isi berkas (dokumen) dengan token Bearer.
  Future<List<int>> getBytes(String path) async {
    final http.Response response;
    try {
      response = await _http.get(_uri(path), headers: {
        'Accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      }).timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw ApiException('Unduhan melewati batas waktu.');
    } catch (_) {
      throw ApiException('Tidak dapat mengunduh berkas.');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return response.bodyBytes;
    throw ApiException('Gagal mengunduh berkas (${response.statusCode}).', statusCode: response.statusCode);
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
