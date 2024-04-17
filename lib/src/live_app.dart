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
  }) {
    initialize(configuration);
    IsmLiveHandler.isLogsEnabled = enableLog;
    IsmLiveHandler.onLogout = onLogout;
  }

  static bool get isMqttConnected => IsmLiveHandler.isMqttConnected;
  static set isMqttConnected(bool value) => IsmLiveHandler.isMqttConnected = value;

  static bool _initialized = false;

  static bool _mqttInitialized = false;

  static Future<void> initialize(
    IsmLiveConfigData config, {
    bool shouldInitializeMqtt = true,
    List<String>? mqttTopics,
    List<String>? mqttTopicChannels,
    VoidCallback? onStreamEnd,
  }) async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await IsmLiveDelegate.instance.initialize(
      config,
      onEndStream: onStreamEnd,
    );
    if (shouldInitializeMqtt) {
      await initializeMqtt(
        topics: mqttTopics,
        topicChannels: mqttTopicChannels,
      );
    }
  }

  static Future<void> initializeMqtt({
    List<String>? topics,
    List<String>? topicChannels,
  }) async {
    if (_mqttInitialized) {
      return;
    }
    _mqttInitialized = true;
    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
    await Get.find<IsmLiveMqttController>().setup(
      topics: topics,
      topicChannels: topicChannels,
    );
  }

  static void configureInterface({
    IsmLiveHeaderBuilder? streamHeader,
    IsmLiveHeaderBuilder? bottomBuilder,
    IsmLiveInputBuilder? inputBuilder,
    bool showHeader = true,
    Alignment? headerPosition,
    Alignment? endStreamPosition,
  }) {
    assert(_initialized, 'IsmLiveApp is not initialized, initialize it using `IsmLiveApp.initialize()`');
    IsmLiveDelegate.streamHeader = streamHeader;
    IsmLiveDelegate.bottomBuilder = bottomBuilder;
    IsmLiveDelegate.showHeader = showHeader;
    IsmLiveDelegate.inputBuilder = inputBuilder;
    IsmLiveDelegate.headerPosition = headerPosition ?? Alignment.topLeft;
    IsmLiveDelegate.endStreamPosition = endStreamPosition ?? Alignment.topRight;
  }

  static Future<void> endStream() => IsmLiveDelegate.endStream();

  static void handleMqttEvent(DynamicMap payload) {
    assert(
      _initialized && _mqttInitialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    Get.find<IsmLiveMqttController>().handleEventsExternally(payload);
  }

  static Future<void> joinStream({
    required IsmLiveStreamModel stream,
    required bool isHost,
    bool isInteractive = false,
    VoidCallback? onStreamEnd,
  }) async {
    assert(
      _initialized && _mqttInitialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }
    IsmLiveUtility.updateLater(() async {
      await Get.find<IsmLiveStreamController>().joinStream(
        stream,
        isHost,
        joinByScrolling: false,
        isInteractive: isInteractive,
        onStreamEnd: onStreamEnd,
      );
    });
  }

  static VoidCallback? get onStreamEnd => IsmLiveDelegate.onStreamEnd;

  static set onStreamEnd(VoidCallback? callback) => IsmLiveDelegate.onStreamEnd = callback;

  static IsmLiveHeaderBuilder? get streamHeader => IsmLiveDelegate.streamHeader;

  static IsmLiveHeaderBuilder? get bottomBuilder => IsmLiveDelegate.bottomBuilder;

  static IsmLiveInputBuilder? get inputBuilder => IsmLiveDelegate.inputBuilder;

  static bool get showHeader => IsmLiveDelegate.showHeader;

  static Alignment get headerPosition => IsmLiveDelegate.headerPosition;

  static Alignment get endStreamPosition => IsmLiveDelegate.endStreamPosition;

  // static void disconnect() {}

  static Future<void> logout([
    bool? isStreaming,
    VoidCallback? logoutCallback,
  ]) =>
      IsmLiveHandler.logout(
        logoutCallback: logoutCallback,
      );

  static MapStreamSubscription addListener(
    MapFunction listener,
  ) {
    assert(
      _initialized && _mqttInitialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );
    return IsmLiveHandler.addListener(listener);
  }

  static Future<void> removeListener(MapFunction listener) async {
    assert(
      _initialized && _mqttInitialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );
    await IsmLiveHandler.removeListener(listener);
  }

  IsmLiveThemeData get themeData => _kThemeData;

  IsmLiveTranslationsData get translationsData => _kTranslationsData;

  final IsmLiveConfigData configuration;
  final VoidCallback? onCallStart;
  final VoidCallback? onCallEnd;
  final bool enableLog;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) => IsmLiveConfig(
        data: configuration,
        child: const IsmLiveStreamListing(),
      );
}
