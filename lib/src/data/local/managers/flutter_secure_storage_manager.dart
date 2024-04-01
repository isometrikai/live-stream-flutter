import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IsmLiveFlutterSecureStorageManager {
  const IsmLiveFlutterSecureStorageManager();

  /// initialize flutter secure storage
  final flutterSecureStorage = const FlutterSecureStorage();

  /// Get data from secure storage
  Future<String> getSecuredValue(String key) async {
    try {
      var value = await flutterSecureStorage.read(key: key);
      if (value == null || value.isEmpty) {
        value = '';
      }
      return value;
    } catch (error) {
      return '';
    }
  }

  /// Save data in secure storage
  void saveValueSecurely(String key, String value) {
    flutterSecureStorage.write(key: key, value: value);
  }

  /// Delete data from secure storage
  void deleteSecuredValue(String key) {
    flutterSecureStorage.delete(key: key);
  }

  /// Delete all data from secure storage
  void deleteAllSecuredValues() {
    flutterSecureStorage.deleteAll();
  }

  /// Method For Delete & Override from Secure Storage
  void deleteSaveSecureValue(String key, String value) async {
    try {
      await flutterSecureStorage.delete(key: key);
      await flutterSecureStorage.write(key: key, value: value);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
  }
}
