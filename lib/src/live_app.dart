import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_helper/mqtt_helper.dart';

part 'live_data.dart';

class IsmLiveApp extends StatefulWidget {
  /// Plug-and-play entry point: Handles its own initialization and shows default UI.
  /// Usage:
  ///   IsmLiveApp(configuration: ..., navigatorKey: ...)
  const IsmLiveApp({
    super.key,
    required this.configuration,
    required this.navigatorKey,
    this.onCallStart,
    this.onCallEnd,
    this.enableLog = true,
    this.onLogout,
  });
  final IsmLiveConfigData configuration;
  final GlobalKey<NavigatorState> navigatorKey;
  final VoidCallback? onCallStart;
  final VoidCallback? onCallEnd;
  final bool enableLog;
  final VoidCallback? onLogout;

  static bool get isInitialized => _initialized;

  static bool get isMqttConnected => IsmLiveHandler.isMqttConnected;
  static set isMqttConnected(bool value) =>
      IsmLiveHandler.isMqttConnected = value;

  static bool _initialized = false;
  static bool _initializing = false; // To prevent re-entrancy
  static bool _mqttInitialized = false;

  static Future<void> initialize(
    IsmLiveConfigData config, {
    required GlobalKey<NavigatorState> navigatorKey,
    bool shouldInitializeMqtt = true,
    List<String>? mqttTopics,
    List<String>? mqttTopicChannels,
    VoidCallback? onStreamEnd,
  }) async {
    if (_initialized || _initializing) {
      IsmLiveLog.info(
          'IsmLiveApp.initialize: Already initialized or initializing.');
      return;
    }
    _initializing = true;
    IsmLiveLog.info('IsmLiveApp.initialize: START');

    try {
      IsmLiveUtility.navigatorKey = navigatorKey;

      IsmLiveLog.info('Calling IsmLiveDelegate.instance.initialize');
      await IsmLiveDelegate.instance.initialize(
        config,
        onEndStream: onStreamEnd,
      );
      IsmLiveLog.info('IsmLiveDelegate.instance.initialize DONE');

      // Register all required controllers up front
      if (!Get.isRegistered<IsmLiveStreamController>()) {
        IsmLiveLog.info('Registering IsmLiveStreamController');
        IsmLiveStreamBinding().dependencies();
      }
      if (!Get.isRegistered<IsmLiveMqttController>()) {
        IsmLiveLog.info('Registering IsmLiveMqttController');
        IsmLiveMqttBinding().dependencies();
      }

      IsmLiveLog.info('Calling initializeMqtt');
      await initializeMqtt(
        topics: mqttTopics,
        topicChannels: mqttTopicChannels,
        shouldInitializeMqtt: shouldInitializeMqtt,
      );
      IsmLiveLog.info('initializeMqtt DONE');

      _initialized = true;
      IsmLiveLog.info('IsmLiveApp.initialize: SUCCESS');
    } catch (e, stack) {
      _initialized = false;
      IsmLiveLog.error('IsmLiveApp.initialize: FAILED: $e\n$stack');
      rethrow;
    } finally {
      _initializing = false;
    }
  }

  static Future<void> initializeMqtt({
    List<String>? topics,
    List<String>? topicChannels,
    required bool shouldInitializeMqtt,
  }) async {
    if (_mqttInitialized) {
      return;
    }
    _mqttInitialized = true;

    IsmLiveLog.info('mqtt setup from starting');
    await Get.find<IsmLiveMqttController>().setup(
      topics: topics,
      topicChannels: topicChannels,
      shouldInitializeMqtt: shouldInitializeMqtt,
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
    Function(String id)? subscribStreamById,
    Function(String id)? unsubscribStreamById,
    List<IsmLiveStreamOption> viewersOptions = const [],
    List<IsmLiveStreamOption> hostOptions = const [],
    List<IsmLiveStreamOption> rtmpOptions = const [],
    List<IsmLiveStreamOption> copublisherOptions = const [],
    List<IsmLiveStreamOption> pkOptions = const [],
    List<IsmLiveAnalyticsOptions> liveAnalyticsOptions = const [],
    Widget? homeScreen,
    void Function(String userId)? openUserProfileView,
    String Function(String key)? getUserProfileUrl,
    IsmLiveButtonConfig? ismLiveButtonConfig,
    LinearGradient? streamOptionsBgGradient,
    Widget? logoWidget,
    Future<void> Function(String streamId)? onHostStopStream,
    AddProductViewBuilder? addProductViewBuilder,
  }) {
    // assert(_initialized,
    //     'IsmLiveApp is not initialized, initialize it using `IsmLiveApp.initialize()`');
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
    IsmLiveDelegate.subscribStreamById = subscribStreamById;
    IsmLiveDelegate.unsubscribStreamById = unsubscribStreamById;
    IsmLiveDelegate.openUserProfileView = openUserProfileView;
    IsmLiveDelegate.getUserProfileUrl = getUserProfileUrl;
    IsmLiveDelegate.ismLiveButtonConfig = ismLiveButtonConfig;
    IsmLiveDelegate.streamOptionsBgGradient = streamOptionsBgGradient;
    IsmLiveDelegate.liveAnalyticsOptions = liveAnalyticsOptions;
    IsmLiveDelegate.logoWidget = logoWidget;
    IsmLiveDelegate.onHostStopStream = onHostStopStream;
    IsmLiveDelegate.addProductViewBuilder = addProductViewBuilder;
  }

  static Future<void> endStream({required BuildContext context}) async =>
      await IsmLiveDelegate.endStream(context: context);

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
    required BuildContext context,
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
        context: context,
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

  @override
  State<IsmLiveApp> createState() => _IsmLiveAppState();
}

class _IsmLiveAppState extends State<IsmLiveApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    // Set logging and logout callback for plug-and-play usage
    IsmLiveHandler.isLogsEnabled = widget.enableLog;
    IsmLiveHandler.onLogout = widget.onLogout;
    _initFuture = IsmLiveApp.initialize(
      widget.configuration,
      navigatorKey: widget.navigatorKey,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return IsmLiveConfig(
              data: widget.configuration,
              child: const IsmLiveStreamListing(),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
}
