import 'app_storage.dart';

class StubStorage implements AppStorage {
  final Map<String, String> _memory = {};

  @override
  String? get(String key) => _memory[key];

  @override
  void set(String key, String value) => _memory[key] = value;

  @override
  void remove(String key) => _memory.remove(key);

  @override
  void clear() => _memory.clear();
}

AppStorage getAppStorage() => StubStorage();
