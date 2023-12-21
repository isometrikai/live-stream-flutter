import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class Utility {
  const Utility._();

  /// common header for All api
  static Map<String, String> secretHeader() => IsmLiveUtility.secretHeader();

  /// Token common Header for All api
  static Map<String, String> tokenHeader(String token) => IsmLiveUtility.tokenHeader();
}
