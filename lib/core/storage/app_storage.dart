import 'app_storage_stub.dart'
    if (dart.library.html) 'app_storage_web.dart';

/// Abstraksi penyimpanan lokal (Local Storage) murni Dart / Web
/// Aman dari masalah symlink native Windows dan persisten di browser / mobile
abstract class AppStorage {
  static final AppStorage instance = getAppStorage();

  String? get(String key);
  void set(String key, String value);
  void remove(String key);
  void clear();
}
