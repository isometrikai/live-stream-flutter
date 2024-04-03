import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'live_data.dart';

class IsmLiveApp extends StatelessWidget {
  IsmLiveApp({
    super.key,
    required this.configuration,
    this.onCallStart,
    this.onCallEnd,
    this.enableLog = true,
    this.onLogout,
    this.navigationType = IsmLiveNavigation.streaming,
  }) {
    initialize(configuration);
    IsmLiveHandler.isLogsEnabled = enableLog;
    IsmLiveHandler.onLogout = onLogout;
    IsmLiveHandler.navigationType = navigationType;
  }

  static bool get isMqttConnected => IsmLiveHandler.isMqttConnected;
  static set isMqttConnected(bool value) => IsmLiveHandler.isMqttConnected = value;

  static bool _initialized = false;

  static bool _mqttInitialized = false;

  static Future<void> initialize(
    IsmLiveConfigData config, {
    bool shouldInitializeMqtt = true,
    List<String>? mqttTopics,
  }) async {
    _initialized = true;
    await IsmLiveDelegate.instance.initialize(config);
    if (shouldInitializeMqtt) {
      await initializeMqtt(mqttTopics);
    }
  }

  static Future<void> initializeMqtt([List<String>? topics]) async {
    _mqttInitialized = true;
    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
    await Get.find<IsmLiveMqttController>().setup(topics: topics);
  }

  static void handleMqttEvent(DynamicMap payload) {
    assert(_initialized, 'IsmLiveApp must be initialized before using handleMqttEvent, call `IsmLiveApp.initialize(config)`');
    assert(_mqttInitialized, 'IsmLiveMqtt must be initialized before using handleMqttEvent, call `IsmLiveApp.initializeMqtt()`');

    Get.find<IsmLiveMqttController>().handleEventsExternally(payload);
  }

  static Future<void> joinStream({
    required IsmLiveStreamModel stream,
    required bool isHost,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp is not initialized. Initialize it using `IsmLiveApp.initialize(config)`',
    );
    assert(
      _mqttInitialized,
      'IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initializeMqtt()`',
    );
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }
    IsmLiveUtility.updateLater(() async {
      await Get.find<IsmLiveStreamController>().joinStream(
        stream,
        isHost,
        joinByScrolling: false,
      );
    });
  }

  static Future<void> logout([
    bool? isStreaming,
    VoidCallback? logoutCallback,
  ]) =>
      IsmLiveHandler.logout(
        isStreaming: isStreaming ?? IsmLiveHandler.navigationType == IsmLiveNavigation.streaming,
        logoutCallback: logoutCallback,
      );

  static MapStreamSubscription addListener(
    MapFunction listener,
  ) =>
      IsmLiveHandler.addListener(listener);

  IsmLiveThemeData get themeData => _kThemeData;

  IsmLiveTranslationsData get translationsData => _kTranslationsData;

  final IsmLiveConfigData configuration;
  final VoidCallback? onCallStart;
  final VoidCallback? onCallEnd;
  final bool enableLog;
  final VoidCallback? onLogout;
  final IsmLiveNavigation navigationType;

  @override
  Widget build(BuildContext context) => IsmLiveConfig(
        data: configuration,
        child: navigationType.isStreaming ? const IsmLiveStreamListing() : const IsmLiveMeetingView(),
      );
}
