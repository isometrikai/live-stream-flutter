import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

/// This class will be used for providing all configuration
/// for the live stream module
class IsmLiveConfigData with Diagnosticable {
  IsmLiveConfigData({
    required this.userConfig,
    required this.projectConfig,
    required this.mqttConfig,
    String? username,
    String? password,
  })  : username = username ?? '2${projectConfig.accountId}${projectConfig.projectId}',
        password = password ?? '${projectConfig.licenseKey}${projectConfig.keySetId}';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IsmLiveUserConfig>('userConfig', userConfig));
    properties.add(DiagnosticsProperty<IsmLiveProjectConfig>('projectConfig', projectConfig));
    properties.add(DiagnosticsProperty<IsmLiveMqttConfig>('mqttConfig', mqttConfig));
    properties.add(StringProperty('username', username));
    properties.add(StringProperty('password', password));
  }

  final IsmLiveUserConfig userConfig;
  final IsmLiveProjectConfig projectConfig;
  final IsmLiveMqttConfig mqttConfig;
  final String? username;
  final String? password;
}
