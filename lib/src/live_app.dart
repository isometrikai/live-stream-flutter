import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet.dart';
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
  static RxBool get isMqttConnectedRx => IsmLiveHandler.isMqttConnectedRx;

  /// Refresh coins balance from server
  static Future<void> refreshCoinsBalance() async {
    if (!Get.isRegistered<CoinsPlansWalletController>()) {
      CoinsPlansWalletBinding().dependencies();
    }
    final controller = Get.find<CoinsPlansWalletController>();
    await controller.totalWalletCoins('coin');
    await controller.totalWalletCoins('usd');
  }

  /// Get coins balance with automatic controller registration if needed
  static int get coinsBalance {
    if (!Get.isRegistered<CoinsPlansWalletController>()) {
      CoinsPlansWalletBinding().dependencies();
    }
    return Get.find<CoinsPlansWalletController>().coinBalance;
  }

  /// Get wallet balance in USD with automatic controller registration if needed
  static int get walletBalance {
    if (!Get.isRegistered<CoinsPlansWalletController>()) {
      CoinsPlansWalletBinding().dependencies();
    }
    return Get.find<CoinsPlansWalletController>().balance;
  }

  /// Manual MQTT reconnection method
  static Future<bool> reconnectMqtt() async =>
      await IsmLiveHandler.reconnectMqtt();

  /// Get MQTT reconnection status
  static Map<String, dynamic> getMqttReconnectionStatus() =>
      IsmLiveHandler.getMqttReconnectionStatus();

  /// Get MQTT controller instance for advanced operations
  static IsmLiveMqttController getMqttController() =>
      IsmLiveHandler.getMqttController();

  /// Get stream controller instance for advanced operations
  static IsmLiveStreamController getStreamController() {
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }
    return Get.find<IsmLiveStreamController>();
  }

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
    // Background lifecycle configuration
    bool enableBackgroundLifecycle = true,
    bool enableBackgroundAudio = true,
    bool enableBackgroundVideo = false,
    Duration? backgroundTimeout,
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

        // Configure background lifecycle after controller registration
        final streamController = Get.find<IsmLiveStreamController>();
        streamController.configureBackgroundLifecycle(
          enableBackgroundLifecycle: enableBackgroundLifecycle,
          enableBackgroundAudio: enableBackgroundAudio,
          enableBackgroundVideo: enableBackgroundVideo,
          backgroundTimeout: backgroundTimeout,
        );
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
    IsmLiveCustomBottomSheetBuilder? customBottomSheetBuilder,
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
    Future<void> Function(String streamId)? onLeftStreamAsViewer,
    GoLiveClickCallback? onGoLiveClick,
    GoLiveDisposeCallback? onGoLiveDispose,
    bool productionMode = false,
    IsmLiveEcomConfigure? ecomConfigure,
    IsmLiveGoLiveScreenConfigure? goLiveScreenConfigure,
    bool enableFreeGift = false,
    bool restrictProfileSheetOnProfileClick = false,
    String? fontFamily,
    MessageProcessCallback? messageProcessCallback,
    StreamViewLoadedCallback? streamViewLoadedCallback,
    HeartMessageCallback? heartMessageCallback,
    StreamAnalyticsCallback? streamAnalyticsCallback,
    StreamAnalyticsViewersCallback? streamAnalyticsViewersCallback,
    HostTopProfileClickCallback? hostTopProfileClickCallback,
    GoLiveSmallButtonBuilder? goLiveSmallButtonBuilder,
    AnalyticsButtonCallback? analyticsButtonCallback,
    ScheduleModifyButtonCallback? scheduleModifyButtonCallback,
    TopViewersListCallback? topViewersListCallback,
    ModeratorsListCallback? moderatorsListCallback,
    BorderRadius? bottomSheetBorderRadius,
  }) {
    // assert(_initialized,
    //     'IsmLiveApp is not initialized, initialize it using `IsmLiveApp.initialize()`');
    IsmLiveDelegate.streamHeader = streamHeader;
    IsmLiveDelegate.bottomBuilder = bottomBuilder;
    IsmLiveDelegate.showHeader = showHeader;
    IsmLiveDelegate.inputBuilder = inputBuilder;
    IsmLiveDelegate.customBottomSheetBuilder = customBottomSheetBuilder;
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
    IsmLiveDelegate.onLeftStreamAsViewer = onLeftStreamAsViewer;
    IsmLiveDelegate.onGoLiveClick = onGoLiveClick;
    IsmLiveDelegate.onGoLiveDispose = onGoLiveDispose;
    IsmLiveDelegate.productionMode = productionMode;
    IsmLiveDelegate.ecomConfigure = ecomConfigure;
    IsmLiveDelegate.goLiveScreenConfigure = goLiveScreenConfigure;
    IsmLiveDelegate.enableFreeGift = enableFreeGift;
    IsmLiveDelegate.restrictProfileSheetOnProfileClick =
        restrictProfileSheetOnProfileClick;
    IsmLiveDelegate.fontFamily = fontFamily;
    IsmLiveDelegate.messageProcessCallback = messageProcessCallback;
    IsmLiveDelegate.streamViewLoadedCallback = streamViewLoadedCallback;
    IsmLiveDelegate.heartMessageCallback = heartMessageCallback;
    IsmLiveDelegate.streamAnalyticsCallback = streamAnalyticsCallback;
    IsmLiveDelegate.streamAnalyticsViewersCallback =
        streamAnalyticsViewersCallback;
    IsmLiveDelegate.hostTopProfileClickCallback = hostTopProfileClickCallback;

    // Handle GoLive screen configuration
    if (goLiveScreenConfigure != null) {
      IsmLiveDelegate.goLiveHeaderBuilder =
          goLiveScreenConfigure.goLiveHeaderBuilder;
      IsmLiveDelegate.goLiveButtonBuilder =
          goLiveScreenConfigure.goLiveButtonBuilder;
    }

    // Set standalone goLiveSmallButtonBuilder if provided
    if (goLiveSmallButtonBuilder != null) {
      IsmLiveDelegate.goLiveSmallButtonBuilder = goLiveSmallButtonBuilder;
    }

    IsmLiveDelegate.analyticsButtonCallback = analyticsButtonCallback;
    IsmLiveDelegate.scheduleModifyButtonCallback = scheduleModifyButtonCallback;
    IsmLiveDelegate.topViewersListCallback = topViewersListCallback;
    IsmLiveDelegate.moderatorsListCallback = moderatorsListCallback;
    IsmLiveDelegate.bottomSheetBorderRadius = bottomSheetBorderRadius;
  }

  static Future<void> endStream(
          {required BuildContext context, bool isSchedule = false}) async =>
      await IsmLiveDelegate.endStream(context: context, isSchedule: isSchedule);

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
    bool isScrolling = false,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    IsmLiveUtility.updateLater(() async {
      await Get.find<IsmLiveStreamController>().joinStream(stream, isHost,
          joinByScrolling: false,
          isInteractive: isInteractive,
          onStreamEnd: onStreamEnd,
          context: context,
          isScrolling: isScrolling);
    });
  }

  static Future<void> connectStream({
    required String token,
    required String streamId,
    String? streamImage,
    String? streamDescription,
    bool hdBroadcast = false,
    bool restream = false,
    required bool isHost,
    bool isCopublisher = false,
    bool isPk = false,
    bool isPkGuest = false,
    required bool isNewStream,
    bool joinByScrolling = false,
    bool isScrolling = false,
    bool isInteractive = false,
    DateTime? startTime,
    bool? isScheduledStream,
    String? eventId,
    required BuildContext context,
    bool reJoin = false,

  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    IsmLiveUtility.updateLater(() async {
      await Get.find<IsmLiveStreamController>().connectStream(
        token: token,
        streamId: streamId,
        streamImage: streamImage,
        streamDiscription: streamDescription,
        hdBroadcast: hdBroadcast,
        restream: restream,
        isHost: isHost,
        isCopublisher: isCopublisher,
        isPk: isPk,
        isPkGust: isPkGuest,
        isNewStream: isNewStream,
        joinByScrolling: joinByScrolling,
        isScrolling: isScrolling,
        isInteractive: isInteractive,
        startTime: startTime,
        isScheduledStream: isScheduledStream,
        eventId: eventId,
        context: context,
        reJoin: reJoin,
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

  static IsmLiveCustomBottomSheetBuilder? get customBottomSheetBuilder =>
      IsmLiveDelegate.customBottomSheetBuilder;

  static Widget? get endButton => IsmLiveDelegate.endButton;

  static bool get showHeader => IsmLiveDelegate.showHeader;

  static Alignment get headerPosition => IsmLiveDelegate.headerPosition;

  static Alignment get endStreamPosition => IsmLiveDelegate.endStreamPosition;

  static GoLiveClickCallback? get onGoLiveClick =>
      IsmLiveDelegate.onGoLiveClick;

  static GoLiveDisposeCallback? get onGoLiveDispose =>
      IsmLiveDelegate.onGoLiveDispose;

  static IsmLiveEcomConfigure? get ecomConfigure =>
      IsmLiveDelegate.ecomConfigure;

  static IsmLiveGoLiveScreenConfigure? get goLiveScreenConfigure =>
      IsmLiveDelegate.goLiveScreenConfigure;

  static String? get fontFamily => IsmLiveDelegate.fontFamily;

  static MessageProcessCallback? get messageProcessCallback =>
      IsmLiveDelegate.messageProcessCallback;

  static StreamViewLoadedCallback? get streamViewLoadedCallback =>
      IsmLiveDelegate.streamViewLoadedCallback;

  static HeartMessageCallback? get heartMessageCallback =>
      IsmLiveDelegate.heartMessageCallback;

  static StreamAnalyticsCallback? get streamAnalyticsCallback =>
      IsmLiveDelegate.streamAnalyticsCallback;

  static StreamAnalyticsViewersCallback? get streamAnalyticsViewersCallback =>
      IsmLiveDelegate.streamAnalyticsViewersCallback;

  static HostTopProfileClickCallback? get hostTopProfileClickCallback =>
      IsmLiveDelegate.hostTopProfileClickCallback;

  static GoLiveHeaderBuilder? get goLiveHeaderBuilder =>
      IsmLiveDelegate.goLiveScreenConfigure?.goLiveHeaderBuilder;

  static GoLiveButtonBuilder? get goLiveButtonBuilder =>
      IsmLiveDelegate.goLiveScreenConfigure?.goLiveButtonBuilder;

  static AnalyticsButtonCallback? get analyticsButtonCallback =>
      IsmLiveDelegate.analyticsButtonCallback;

  static ScheduleModifyButtonCallback? get scheduleModifyButtonCallback =>
      IsmLiveDelegate.scheduleModifyButtonCallback;

  static TopViewersListCallback? get topViewersListCallback =>
      IsmLiveDelegate.topViewersListCallback;

  static ModeratorsListCallback? get moderatorsListCallback =>
      IsmLiveDelegate.moderatorsListCallback;

  static BorderRadius? get bottomSheetBorderRadius =>
      IsmLiveDelegate.bottomSheetBorderRadius;

  /// Update font family dynamically at runtime
  static void updateFontFamily(String? fontFamily) {
    IsmLiveDelegate.fontFamily = fontFamily;
    // Trigger rebuild of widgets that use the font
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().update();
    }
  }

  /// Update message process callback dynamically at runtime
  static void updateMessageProcessCallback(
      MessageProcessCallback? messageProcessCallback) {
    IsmLiveDelegate.messageProcessCallback = messageProcessCallback;
    // Trigger rebuild of stream view to apply new filter
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().update([IsmLiveStreamView.updateId]);
    }
  }

  /// Update stream view loaded callback dynamically at runtime
  static void updateStreamViewLoadedCallback(
      StreamViewLoadedCallback? streamViewLoadedCallback) {
    IsmLiveDelegate.streamViewLoadedCallback = streamViewLoadedCallback;
  }

  /// Update heart message callback dynamically at runtime
  static void updateHeartMessageCallback(
      HeartMessageCallback? heartMessageCallback) {
    IsmLiveDelegate.heartMessageCallback = heartMessageCallback;
  }

  /// Update stream analytics callback dynamically at runtime
  static void updateStreamAnalyticsCallback(
      StreamAnalyticsCallback? streamAnalyticsCallback) {
    IsmLiveDelegate.streamAnalyticsCallback = streamAnalyticsCallback;
  }

  /// Update stream analytics viewers callback dynamically at runtime
  static void updateStreamAnalyticsViewersCallback(
      StreamAnalyticsViewersCallback? streamAnalyticsViewersCallback) {
    IsmLiveDelegate.streamAnalyticsViewersCallback =
        streamAnalyticsViewersCallback;
  }

  /// Update host top profile click callback dynamically at runtime
  static void updateHostTopProfileClickCallback(
      HostTopProfileClickCallback? hostTopProfileClickCallback) {
    IsmLiveDelegate.hostTopProfileClickCallback = hostTopProfileClickCallback;
  }

  /// Update go live click callback dynamically at runtime
  static void updateGoLiveClickCallback(GoLiveClickCallback? onGoLiveClick) {
    IsmLiveDelegate.onGoLiveClick = onGoLiveClick;
  }

  /// Update go live dispose callback dynamically at runtime
  static void updateGoLiveDisposeCallback(
      GoLiveDisposeCallback? onGoLiveDispose) {
    IsmLiveDelegate.onGoLiveDispose = onGoLiveDispose;
  }

  /// Update go live screen configuration dynamically at runtime
  static void updateGoLiveScreenConfigure(
      IsmLiveGoLiveScreenConfigure? goLiveScreenConfigure) {
    IsmLiveDelegate.goLiveScreenConfigure = goLiveScreenConfigure;
    if (goLiveScreenConfigure != null) {
      IsmLiveDelegate.goLiveHeaderBuilder =
          goLiveScreenConfigure.goLiveHeaderBuilder;
      IsmLiveDelegate.goLiveButtonBuilder =
          goLiveScreenConfigure.goLiveButtonBuilder;
    } else {
      // Clear the builders when configuration is null
      IsmLiveDelegate.goLiveHeaderBuilder = null;
      IsmLiveDelegate.goLiveButtonBuilder = null;
    }
    // Trigger rebuild of go live view to apply new configuration
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().update([IsmGoLiveView.updateId]);
    }
  }

  /// Update go live header builder dynamically at runtime
  /// Note: This method updates the header builder in the current goLiveScreenConfigure
  static void updateGoLiveHeaderBuilder(
      GoLiveHeaderBuilder? goLiveHeaderBuilder) {
    IsmLiveDelegate.goLiveHeaderBuilder = goLiveHeaderBuilder;
    // Trigger rebuild of go live view to apply new header
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().update([IsmGoLiveView.updateId]);
    }
  }

  /// Update go live button builder dynamically at runtime
  /// Note: This method updates the button builder in the current goLiveScreenConfigure
  static void updateGoLiveButtonBuilder(
      GoLiveButtonBuilder? goLiveButtonBuilder) {
    IsmLiveDelegate.goLiveButtonBuilder = goLiveButtonBuilder;
    // Trigger rebuild of go live view to apply new button
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().update([IsmGoLiveView.updateId]);
    }
  }

  /// Update go live small button builder dynamically at runtime
  static void updateGoLiveSmallButtonBuilder(
      GoLiveSmallButtonBuilder? goLiveSmallButtonBuilder) {
    IsmLiveDelegate.goLiveSmallButtonBuilder = goLiveSmallButtonBuilder;
    // Trigger rebuild of stream view to apply new small button
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().update([IsmLiveStreamView.updateId]);
    }
  }

  /// Update analytics button callback dynamically at runtime
  static void updateAnalyticsButtonCallback(
      AnalyticsButtonCallback? analyticsButtonCallback) {
    IsmLiveDelegate.analyticsButtonCallback = analyticsButtonCallback;
  }

  /// Update schedule modify button callback dynamically at runtime
  static void updateScheduleModifyButtonCallback(
      ScheduleModifyButtonCallback? scheduleModifyButtonCallback) {
    IsmLiveDelegate.scheduleModifyButtonCallback = scheduleModifyButtonCallback;
  }

  /// Update top viewers list callback dynamically at runtime
  static void updateTopViewersListCallback(
      TopViewersListCallback? topViewersListCallback) {
    IsmLiveDelegate.topViewersListCallback = topViewersListCallback;
  }

  /// Update moderators list callback dynamically at runtime
  static void updateModeratorsListCallback(
      ModeratorsListCallback? moderatorsListCallback) {
    IsmLiveDelegate.moderatorsListCallback = moderatorsListCallback;
  }

  /// Update bottom sheet border radius dynamically at runtime
  static void updateBottomSheetBorderRadius(
      BorderRadius? bottomSheetBorderRadius) {
    IsmLiveDelegate.bottomSheetBorderRadius = bottomSheetBorderRadius;
  }

  /// Update custom bottom sheet builder dynamically at runtime
  static void updateCustomBottomSheetBuilder(
      IsmLiveCustomBottomSheetBuilder? customBottomSheetBuilder) {
    IsmLiveDelegate.customBottomSheetBuilder = customBottomSheetBuilder;
  }

  /// Example usage of custom bottom sheet builder:
  ///
  /// ```dart
  /// IsmLiveApp.configureInterface(
  ///   customBottomSheetBuilder: (context, title, leftLabel, rightLabel, onLeft, onRight) {
  ///     return Container(
  ///       padding: EdgeInsets.all(20),
  ///       decoration: BoxDecoration(
  ///         color: Colors.white,
  ///         borderRadius: BorderRadius.circular(20),
  ///       ),
  ///       child: Column(
  ///         mainAxisSize: MainAxisSize.min,
  ///         children: [
  ///           Text(
  ///             title,
  ///             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ///           ),
  ///           SizedBox(height: 20),
  ///           Row(
  ///             children: [
  ///               Expanded(
  ///                 child: ElevatedButton(
  ///                   onPressed: onLeft,
  ///                   child: Text(leftLabel),
  ///                 ),
  ///               ),
  ///               SizedBox(width: 10),
  ///               Expanded(
  ///                 child: ElevatedButton(
  ///                   onPressed: onRight,
  ///                   child: Text(rightLabel),
  ///                 ),
  ///               ),
  ///             ],
  ///           ),
  ///         ],
  ///       ),
  ///     );
  ///   },
  /// );
  /// ```
  ///
  /// Or use the update method at runtime:
  ///
  /// ```dart
  /// IsmLiveApp.updateCustomBottomSheetBuilder((context, title, leftLabel, rightLabel, onLeft, onRight) {
  ///   return YourCustomBottomSheetWidget(
  ///     title: title,
  ///     leftButton: leftLabel,
  ///     rightButton: rightLabel,
  ///     onLeftPressed: onLeft,
  ///     onRightPressed: onRight,
  ///   );
  /// });
  /// ```

  /// Configure background lifecycle management
  static void configureBackgroundLifecycle({
    bool enableBackgroundLifecycle = true,
    bool enableBackgroundAudio = true,
    bool enableBackgroundVideo = false,
    Duration? backgroundTimeout,
  }) {
    if (Get.isRegistered<IsmLiveStreamController>()) {
      final streamController = Get.find<IsmLiveStreamController>();
      streamController.configureBackgroundLifecycle(
        enableBackgroundLifecycle: enableBackgroundLifecycle,
        enableBackgroundAudio: enableBackgroundAudio,
        enableBackgroundVideo: enableBackgroundVideo,
        backgroundTimeout: backgroundTimeout,
      );
    }
  }

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
