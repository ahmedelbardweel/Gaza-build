import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const _appBoxName = 'app_settings_box';
  late Box _appBox;

  Future<void> initialize() async {
    _appBox = await Hive.openBox(_appBoxName);
  }

  String? getString(String key) => _appBox.get(key) as String?;
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      await _appBox.delete(key);
    } else {
      await _appBox.put(key, value);
    }
  }

  bool getBool(String key, {bool defaultValue = false}) =>
      (_appBox.get(key) as bool?) ?? defaultValue;

  Future<void> setBool(String key, bool value) async {
    await _appBox.put(key, value);
  }

  Future<void> clearAll() async {
    await _appBox.clear();
  }
}
