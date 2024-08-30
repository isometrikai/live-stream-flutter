import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_helper/mqtt_helper.dart';

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
  static set isMqttConnected(bool value) =>
      IsmLiveHandler.isMqttConnected = value;

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

    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
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

    IsmLiveLog.info('mqtt setup from starting');
    await Get.find<IsmLiveMqttController>().setup(
      topics: topics,
      topicChannels: topicChannels,
    );
  }

  static void configureInterface({
    IsmLiveHeaderBuilder? streamHeader,
    IsmLiveHeaderBuilder? bottomBuilder,
    IsmLiveInputBuilder? inputBuilder,
    Widget? endButton,
    Widget? endStreamScreen,
    bool showHeader = true,
    Alignment? headerPosition,
    Alignment? endStreamPosition,
    bool? hdStream,
    bool? scheduleStream,
    bool? productStream,
    bool? rtmpStream,
    bool? restreamStream,
    bool? paidStream,
    bool? multiLiveStream,
    bool? recordeStream,
    List<IsmLiveStreamOption> viewersOptions = const [],
    List<IsmLiveStreamOption> hostOptions = const [],
    List<IsmLiveStreamOption> rtmpOptions = const [],
    List<IsmLiveStreamOption> copublisherOptions = const [],
    List<IsmLiveStreamOption> pkOptions = const [],
    Widget? homeScreen,
  }) {
    assert(_initialized,
        'IsmLiveApp is not initialized, initialize it using `IsmLiveApp.initialize()`');
    IsmLiveDelegate.streamHeader = streamHeader;
    IsmLiveDelegate.bottomBuilder = bottomBuilder;
    IsmLiveDelegate.showHeader = showHeader;
    IsmLiveDelegate.inputBuilder = inputBuilder;
    IsmLiveDelegate.endButton = endButton;
    IsmLiveDelegate.headerPosition = headerPosition ?? Alignment.topLeft;
    IsmLiveDelegate.endStreamPosition = endStreamPosition ?? Alignment.topRight;
    IsmLiveDelegate.viewersOption = viewersOptions;
    IsmLiveDelegate.hostOptions = hostOptions;
    IsmLiveDelegate.rtmpOptions = rtmpOptions;
    IsmLiveDelegate.copublisherOptions = copublisherOptions;
    IsmLiveDelegate.pkOptions = pkOptions;
    IsmLiveDelegate.homeScreen = homeScreen;
    IsmLiveDelegate.scheduleStream = scheduleStream;
    IsmLiveDelegate.hdStream = hdStream;
    IsmLiveDelegate.paidStream = paidStream;
    IsmLiveDelegate.restreamStream = restreamStream;
    IsmLiveDelegate.rtmpStream = rtmpStream;
    IsmLiveDelegate.multiLiveStream = multiLiveStream;
    IsmLiveDelegate.productStream = productStream;
    IsmLiveDelegate.recordeStream = recordeStream;
    IsmLiveDelegate.endStreamScreen = endStreamScreen;
  }

  static Future<void> endStream() async => await IsmLiveDelegate.endStream();

  static void handleMqttEvent(EventModel payload) {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveMqttController>().handleEventsExternally(payload);
    }
  }

  static Future<void> joinStream({
    required IsmLiveStreamDataModel stream,
    required bool isHost,
    bool isInteractive = false,
    VoidCallback? onStreamEnd,
  }) async {
    assert(
      _initialized,
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

  static set onStreamEnd(VoidCallback? callback) =>
      IsmLiveDelegate.onStreamEnd = callback;

  static IsmLiveHeaderBuilder? get streamHeader => IsmLiveDelegate.streamHeader;

  static IsmLiveHeaderBuilder? get bottomBuilder =>
      IsmLiveDelegate.bottomBuilder;

  static IsmLiveInputBuilder? get inputBuilder => IsmLiveDelegate.inputBuilder;

  static Widget? get endButton => IsmLiveDelegate.endButton;

  static bool get showHeader => IsmLiveDelegate.showHeader;

  static Alignment get headerPosition => IsmLiveDelegate.headerPosition;

  static Alignment get endStreamPosition => IsmLiveDelegate.endStreamPosition;

  static Future<void> dispose({
    bool? isStreaming,
    VoidCallback? logoutCallback,
    bool isLoading = true,
  }) {
    _initialized = false;
    _mqttInitialized = false;
    return IsmLiveHandler.dispose(
      isLoading: isLoading,
      isStreaming: isStreaming,
      logoutCallback: logoutCallback,
    );
  }

  static EventStreamSubscription addListener(
    EventFunction listener,
  ) {
    assert(
      _initialized && _mqttInitialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );
    return IsmLiveHandler.addListener(listener);
  }

  static Future<void> removeListener(EventFunction listener) async {
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
