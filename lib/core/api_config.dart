import 'package:flutter/foundation.dart';

/// Alamat REST API backend Laravel (database MySQL yang sama dengan web).
///
/// Override saat run/build:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;

    // Emulator Android mengakses localhost komputer lewat 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static const Duration timeout = Duration(seconds: 15);
}
