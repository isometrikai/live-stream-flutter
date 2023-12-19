import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';

class Utility {
  const Utility._();

  /// common header for All api
  static Map<String, String> secretHeader() => IsmLiveUtility.secretHeader(
        userSecret: AppConstants.userSecret,
        licenseKey: AppConstants.licenseKey,
        appSecret: AppConstants.appSecret,
      );

  /// Token common Header for All api
  static Map<String, String> tokenHeader(String token) =>
      IsmLiveUtility.tokenHeader(
        token: token,
        licenseKey: AppConstants.licenseKey,
        appSecret: AppConstants.appSecret,
      );
}
