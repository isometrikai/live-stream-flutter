import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

/// This class will be used for providing all configuration
/// for the live stream module
class IsmLiveConfigData with Diagnosticable {
  factory IsmLiveConfigData.fromMap(Map<String, dynamic> map) =>
      IsmLiveConfigData(
        userConfig: IsmLiveUserConfig.fromMap(
            map['userConfig'] as Map<String, dynamic>),
        projectConfig: IsmLiveProjectConfig.fromMap(
            map['projectConfig'] as Map<String, dynamic>),
        mqttConfig: IsmLiveMqttConfig.fromMap(
            map['mqttConfig'] as Map<String, dynamic>),
        socketConfig: map['socketConfig'] != null
            ? IsmLiveWebSocketConfig.fromMap(
                map['socketConfig'] as Map<String, dynamic>)
            : null,
        username: map['username'] != null ? map['username'] as String : null,
        password: map['password'] != null ? map['password'] as String : null,
        secure: map['secure'] as bool? ?? false,
      );

  factory IsmLiveConfigData.fromJson(String source) =>
      IsmLiveConfigData.fromMap(json.decode(source) as Map<String, dynamic>);

  IsmLiveConfigData({
    required this.userConfig,
    required this.projectConfig,
    required this.mqttConfig,
    this.socketConfig,
    this.secure = false,
    String? username,
    String? password,
  })  : username =
            username ?? '2${projectConfig.accountId}${projectConfig.projectId}',
        password =
            password ?? '${projectConfig.licenseKey}${projectConfig.keySetId}';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<IsmLiveUserConfig>('userConfig', userConfig));
    properties.add(DiagnosticsProperty<IsmLiveProjectConfig>(
        'projectConfig', projectConfig));
    properties
        .add(DiagnosticsProperty<IsmLiveMqttConfig>('mqttConfig', mqttConfig));
    properties.add(DiagnosticsProperty<IsmLiveWebSocketConfig>(
        'socketConfig', socketConfig));
    properties.add(StringProperty('username', username));
    properties.add(StringProperty('password', password));
    properties.add(DiagnosticsProperty<bool>('secure', secure));
  }

  final IsmLiveUserConfig userConfig;
  final IsmLiveProjectConfig projectConfig;
  final IsmLiveMqttConfig mqttConfig;
  final IsmLiveWebSocketConfig? socketConfig;
  final String? username;
  final String? password;
  final bool secure;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userConfig': userConfig.toMap(),
        'projectConfig': projectConfig.toMap(),
        'mqttConfig': mqttConfig.toMap(),
        'socketConfig': socketConfig?.toMap(),
        'username': username,
        'password': password,
        'secure': secure,
      };

  String toJson() => json.encode(toMap());
}
