import 'package:appscrip_live_stream_component_example/res/constants/app_constants.dart';

class Utility {
  const Utility._();

  /// Token common Header for All api
  static Map<String, String> secretHeader() => {
        'Content-Type': 'application/json',
        'userSecret': AppConstants.userSecret,
        'licenseKey': AppConstants.licenseKey,
        'appSecret': AppConstants.appSecret,
      };
}
