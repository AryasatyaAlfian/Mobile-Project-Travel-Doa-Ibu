// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'app_storage.dart';

class WebStorage implements AppStorage {
  @override
  String? get(String key) => html.window.localStorage[key];

  @override
  void set(String key, String value) => html.window.localStorage[key] = value;

  @override
  void remove(String key) => html.window.localStorage.remove(key);

  @override
  void clear() => html.window.localStorage.clear();
}

AppStorage getAppStorage() => WebStorage();
