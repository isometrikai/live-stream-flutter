import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/material.dart';

class IsmLiveApp extends StatelessWidget {
  IsmLiveApp({
    super.key,
    required this.configuration,
    this.onCallStart,
    this.onCallEnd,
    this.enableLog = true,
    this.theme,
    this.onLogout,
  }) {
    IsmLiveHandler.initialize();
    IsmLiveHandler.isLogsEnabled = enableLog;
    IsmLiveHandler.onLogout = onLogout;
  }

  static bool get isMqttConnected => IsmLiveHandler.isMqttConnected;
  static set isMqttConnected(bool value) =>
      IsmLiveHandler.isMqttConnected = value;

  static Future<void> logout([VoidCallback? logoutCallback]) =>
      IsmLiveHandler.logout(logoutCallback);

  static MapStreamSubscription addListener(
    MapFunction listener,
  ) =>
      IsmLiveHandler.addListener(listener);

  final IsmLiveConfigData configuration;
  final VoidCallback? onCallStart;
  final VoidCallback? onCallEnd;
  final bool enableLog;
  final IsmLiveThemeData? theme;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) => IsmLiveTheme(
        data: theme ?? IsmLiveThemeData.fallback(),
        child: IsmLiveConfig(
          data: configuration,
          child: const IsmLiveStreamListing(),
        ),
      );
}
