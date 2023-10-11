import 'package:appscrip_live_stream_component_example/res/res.dart';

class Utility {
  const Utility._();

  /// common header for All api
  static Map<String, String> commonHeader() {
    var header = <String, String>{
      'Content-Type': 'application/json',
      'licenseKey': AppConstants.licenseKey,
      'appSecret': AppConstants.appSecret,
      'userSecret': AppConstants.userSecret,
    };
    return header;
  }

  /// Token common Header for All api
  static Map<String, String> tokenCommonHeader(String token) {
    var header = <String, String>{
      'Content-Type': 'application/json',
      'licenseKey': AppConstants.licenseKey,
      'appSecret': AppConstants.appSecret,
      'userToken': token,
    };
    return header;
  }
}
