import 'package:flutter/foundation.dart';

/// Alamat REST API backend Laravel (database MySQL yang sama dengan web).
///
/// Default mengarah ke server produksi (Cloudflare named tunnel, URL tetap):
///   https://doaibu.sangcakapuniverse.my.id/api/v1
///
/// Override saat run/build (mis. untuk emulator lokal):
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
class ApiConfig {
  ApiConfig._();

  /// URL publik backend (fixed, tidak berubah saat service restart).
  static const String productionBaseUrl =
      'https://doaibu.sangcakapuniverse.my.id/api/v1';

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    return productionBaseUrl;
  }

  /// Dipakai halaman debug untuk menandai bahwa API menunjuk ke server publik.
  static bool get isProduction => baseUrl.startsWith('https://');

  static const Duration timeout = Duration(seconds: 15);
}
