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
    if (value is bool) {
      await sharedPreferences?.setBool(key, value);
    } else if (value is String) {
      await sharedPreferences?.setString(key, value);
    } else if (value is int) {
      await sharedPreferences?.setInt(key, value);
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
