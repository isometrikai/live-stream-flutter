import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  // Obtain shared preferences.
  SharedPreferences? sharedPreferences;

  /// initialize the hive box
  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  void clear() {
    sharedPreferences?.clear();
  }

  void delete(String key) {
    sharedPreferences?.remove(key);
  }

  /// store the data
  void saveSharedValue<T>(String key, T value) async {
    if (T is bool) {
      await sharedPreferences?.setBool(key, value as bool);
    } else if (T is String) {
      await sharedPreferences?.setString(key, value as String);
    } else if (T is int) {
      await sharedPreferences?.setInt(key, value as int);
    }
  }

  /// return bool value
  bool getBoolValue(String key, bool defaultValue) =>
      sharedPreferences?.getBool(key) ?? defaultValue;

  /// return string value
  String getStringValue(String key, String defaultValue) =>
      sharedPreferences?.getString(key) ?? defaultValue;

  /// return int value
  int getIntValue(String key, int defaultValue) =>
      sharedPreferences?.getInt(key) ?? defaultValue;
}
