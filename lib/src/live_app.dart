import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet.dart';
import 'package:appscrip_live_stream_component/src/controllers/mqtt/mqtt_helper.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  static bool get isInitialized =>
      _initialized && IsmLiveUtility.hasValidUserToken;

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

  /// Returns all supported restream platform types.
  ///
  /// Host apps can use this helper to render channel options in their own UI.
  static List<IsmLiveRestreamType> getSupportedRestreamTypes() =>
      List<IsmLiveRestreamType>.unmodifiable(IsmLiveRestreamType.values);

  /// Fetches the list of configured restream channels for the current user.
  ///
  /// This is a convenience wrapper around the internal `StreamViewModel`
  /// implementation so that host apps can directly access the SDK's
  /// configured restream destinations.
  ///
  /// Returns an empty list if the request fails.
  static Future<List<IsmLiveReStreamModel>> getRestreamChannels() async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    try {
      final controller = Get.find<IsmLiveStreamController>();
      return await controller.viewModel.getRestreamChannels();
    } catch (e, stack) {
      IsmLiveLog.error('IsmLiveApp.getRestreamChannels failed: $e\n$stack');
      return <IsmLiveReStreamModel>[];
    }
  }

  /// Fetches a paginated list of stream viewers.
  ///
  /// This is a convenience wrapper around the internal
  /// `StreamViewModel.getStreamViewer` implementation so host apps can render
  /// their own viewer list UI.
  ///
  /// Returns an empty list if the request fails.
  static Future<List<IsmLiveViewerModel>> getStreamViewer({
    required String streamId,
    int limit = 10,
    int skip = 0,
    String? searchTag,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    try {
      final controller = Get.find<IsmLiveStreamController>();
      return await controller.viewModel.getStreamViewer(
        streamId: streamId,
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
    } catch (e, stack) {
      IsmLiveLog.error('IsmLiveApp.getStreamViewer failed: $e\n$stack');
      return <IsmLiveViewerModel>[];
    }
  }

  /// Fetches a paginated list of users.
  ///
  /// Host apps can use this helper to build custom user-pickers (e.g. add
  /// moderator sheets) without relying on SDK UI.
  ///
  /// Returns an empty list if the request fails.
  static Future<List<UserDetails>> fetchUsers({
    int limit = 10,
    int skip = 0,
    String? searchTag,
    Map<String, dynamic>? queryParams,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    try {
      final controller = Get.find<IsmLiveStreamController>();
      return await controller.viewModel.fetchUsers(
            skip: skip,
            limit: limit,
            searchTag: searchTag,
            queryParams: queryParams,
          ) ??
          <UserDetails>[];
    } catch (e, stack) {
      IsmLiveLog.error('IsmLiveApp.fetchUsers failed: $e\n$stack');
      return <UserDetails>[];
    }
  }

  /// Fetches gift categories (gift groups) for gifting/PK UI.
  ///
  /// Host apps can use this helper to build their own gift catalog UI.
  /// Returns an empty list if the request fails.
  static Future<List<IsmLiveGiftGroupModel>> getGiftCategories({
    int limit = 10,
    int skip = 0,
    String? searchTag,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    try {
      if (!Get.isRegistered<IsmLiveApiWrapper>()) {
        // Should already be registered during SDK initialization.
        await IsmLiveHandler.initialize();
      }
      final viewModel = IsmLivePkViewModel(
        IsmLivePkRepository(
          IsmLivePkApis(
            Get.find<IsmLiveApiWrapper>(),
          ),
        ),
      );
      return await viewModel.getGiftCategories(
        skip: skip,
        limit: limit,
        searchTag: searchTag,
      );
    } catch (e, stack) {
      IsmLiveLog.error('IsmLiveApp.getGiftCategories failed: $e\n$stack');
      return <IsmLiveGiftGroupModel>[];
    }
  }

  /// Fetches gifts for a given gift category (gift group).
  ///
  /// Host apps can use this helper to build their own gift catalog UI.
  /// Returns an empty list if the request fails.
  static Future<List<IsmLiveGiftsCategoryModel>> getGiftsForACategory({
    required String giftGroupId,
    int limit = 10,
    int skip = 0,
    String? searchTag,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    try {
      if (!Get.isRegistered<IsmLiveApiWrapper>()) {
        // Should already be registered during SDK initialization.
        await IsmLiveHandler.initialize();
      }
      final viewModel = IsmLivePkViewModel(
        IsmLivePkRepository(
          IsmLivePkApis(
            Get.find<IsmLiveApiWrapper>(),
          ),
        ),
      );
      return await viewModel.getGiftsForACategory(
        giftGroupId: giftGroupId,
        skip: skip,
        limit: limit,
        searchTag: searchTag,
      );
    } catch (e, stack) {
      IsmLiveLog.error('IsmLiveApp.getGiftsForACategory failed: $e\n$stack');
      return <IsmLiveGiftsCategoryModel>[];
    }
  }

  /// Adds or updates a restream channel configuration for the current user.
  ///
  /// This delegates to the internal `StreamViewModel.addRestreamChannel`
  /// implementation and returns the raw `data` string from the API response.
  /// Returns an empty string if the request fails.
  static Future<String> addRestreamChannel({
    required String url,
    required String channelName,
    required int channelType,
    required bool enable,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    try {
      final controller = Get.find<IsmLiveStreamController>();
      return await controller.viewModel.addRestreamChannel(
        url: url,
        channelName: channelName,
        channelType: channelType,
        enable: enable,
      );
    } catch (e, stack) {
      IsmLiveLog.error('IsmLiveApp.addRestreamChannel failed: $e\n$stack');
      return '';
    }
  }

  /// Edits an existing restream channel configuration for the current user.
  ///
  /// This delegates to the internal `StreamViewModel.editRestreamChannel`
  /// implementation and returns `true` when the API call succeeds.
  /// Returns `false` if the request fails.
  static Future<bool> editRestreamChannel({
    required String url,
    required String channelId,
    required String channelName,
    required int channelType,
    required bool enable,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    try {
      final controller = Get.find<IsmLiveStreamController>();
      return await controller.viewModel.editRestreamChannel(
        url: url,
        channelId: channelId,
        channelName: channelName,
        channelType: channelType,
        enable: enable,
      );
    } catch (e, stack) {
      IsmLiveLog.error('IsmLiveApp.editRestreamChannel failed: $e\n$stack');
      return false;
    }
  }

  /// Adds a member (co-publisher) to a live stream.
  ///
  /// Delegates to [IsmLiveStreamController.addMember] so local lists and UI
  /// stay in sync when the stream experience is active. Returns `false` if
  /// the request fails.
  static Future<bool> addMember({
    required String streamId,
    required String memberId,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    try {
      final controller = Get.find<IsmLiveStreamController>();
      return await controller.addMember(
        streamId: streamId,
        memberId: memberId,
      );
    } catch (e, stack) {
      IsmLiveLog.error('IsmLiveApp.addMember failed: $e\n$stack');
      return false;
    }
  }

  /// Removes a member (co-publisher) from a live stream.
  ///
  /// Delegates to [IsmLiveStreamController.removeMember] so local lists and
  /// UI stay in sync when the stream experience is active. Returns `false` if
  /// the request fails.
  static Future<bool> removeMember({
    required String streamId,
    required String memberId,
  }) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    try {
      final controller = Get.find<IsmLiveStreamController>();
      return await controller.removeMember(
        streamId: streamId,
        memberId: memberId,
      );
    } catch (e, stack) {
      IsmLiveLog.error('IsmLiveApp.removeMember failed: $e\n$stack');
      return false;
    }
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

    final sw = Stopwatch()..start();
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.sdkInitializeAttempt,
      properties: [
        {
          'project_id': config.projectConfig.projectId,
          'account_id': config.projectConfig.accountId,
          'user_id': config.userConfig.userId,
          'should_initialize_mqtt': shouldInitializeMqtt,
          'enable_background_lifecycle': enableBackgroundLifecycle,
          'enable_background_audio': enableBackgroundAudio,
          'enable_background_video': enableBackgroundVideo,
          'has_background_timeout': backgroundTimeout != null,
          'has_mqtt_topics': mqttTopics != null && mqttTopics.isNotEmpty,
          'has_mqtt_topic_channels':
              mqttTopicChannels != null && mqttTopicChannels.isNotEmpty,
        }
      ],
    );

    try {
      IsmLiveUtility.navigatorKey = navigatorKey;
      // Before delegate work: parallel [Future.wait] previously raced with stream binding.
      await IsmLiveUtility.initialize(config);

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

      sw.stop();
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.sdkInitializeSuccess,
        properties: [
          {
            'project_id': config.projectConfig.projectId,
            'account_id': config.projectConfig.accountId,
            'user_id': config.userConfig.userId,
            'duration_ms': sw.elapsedMilliseconds,
          }
        ],
      );
    } catch (e, stack) {
      _initialized = false;
      IsmLiveLog.error('IsmLiveApp.initialize: FAILED: $e\n$stack');

      sw.stop();
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.sdkInitializeFailure,
        properties: [
          {
            'project_id': config.projectConfig.projectId,
            'account_id': config.projectConfig.accountId,
            'user_id': config.userConfig.userId,
            'duration_ms': sw.elapsedMilliseconds,
            'error': e.toString(),
          }
        ],
      );

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
    // IMPORTANT: Do not block SDK initialization on MQTT connection.
    // MQTT may take a long time or fail entirely; host/viewer must still
    // be able to start and watch the stream.
    unawaited(
      Get.find<IsmLiveMqttController>()
          .setup(
        topics: topics,
        topicChannels: topicChannels,
        shouldInitializeMqtt: shouldInitializeMqtt,
      )
          .catchError((Object e, StackTrace st) {
        IsmLiveLog.error('MQTT setup failed: $e', st);
      }),
    );
  }

  static void configureInterface({
    IsmLiveStreamHeaderBuilder? streamHeader,
    IsmLiveHeaderBuilder? bottomBuilder,
    IsmLiveInputBuilder? inputBuilder,
    IsmLiveCustomBottomSheetBuilder? customBottomSheetBuilder,
    IsmLiveChatMessageBuilder? chatMessageBuilder,
    IsmLiveChatItemBgColorCallback? chatItemBgColorCallback,
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
    StreamDisconnectApiHandler? streamDisconnectApiHandler,
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
    StreamAnalyticsApiHandler? streamAnalyticsApiHandler,
    StreamAnalyticsViewersApiHandler? streamAnalyticsViewersApiHandler,
    HostTopProfileClickCallback? hostTopProfileClickCallback,
    MissingHostTokenStopStreamCallback? missingHostTokenStopStreamCallback,
    GoLiveSmallButtonBuilder? goLiveSmallButtonBuilder,
    IsmLiveCartBuilder? cartBuilder,
    TopViewersListCallback? topViewersListCallback,
    ModeratorsListCallback? moderatorsListCallback,
    AttentionDialogButtonCallback? attentionDialogButtonCallback,
    StreamListingRefreshCallback? streamListingRefreshCallback,
    OnStreamScrollCallback? onStreamScrollCallback,
    AddCoinsClickCallback? addCoinsClickCallback,
    GiftClickCallback? giftClickCallback,
    HeartBatchFlushCallback? heartBatchFlushCallback,
    IsmLiveAnalyticsDelegate? analyticsDelegate,
    Set<String>? enabledAnalyticsEvents,
    BorderRadius? bottomSheetBorderRadius,
    IsmLiveCameraPosition? initialCameraPositionStream,
    Duration? mqttChatFallbackInterval,

    /// When `false` (default), 2+ participants use horizontal full-width rows.
    /// When `true`, uses the multi-column grid layout.
    bool useGridLayoutForMultipleParticipants = false,

    /// When `false`, [IsmLiveStreamController.getStreams] does not call the
    /// listing API. Default `true`.
    bool enableInternalStreamListingRefresh = true,
    // New control customization options
    ControlOptionCallback? controlOptionCallback,
    ControlWidgetBuilder? controlWidgetBuilder,
    ProductStreamSideOptionsBottomMarginBuilder?
        productStreamSideOptionsBottomMargin,
    IsmLiveStreamRecordingPlayerConfig? streamRecordingPlayerConfig,
  }) {
    // assert(_initialized,
    //     'IsmLiveApp is not initialized, initialize it using `IsmLiveApp.initialize()`');
    IsmLiveDelegate.streamHeader = streamHeader;
    IsmLiveDelegate.bottomBuilder = bottomBuilder;
    IsmLiveDelegate.showHeader = showHeader;
    IsmLiveDelegate.inputBuilder = inputBuilder;
    IsmLiveDelegate.customBottomSheetBuilder = customBottomSheetBuilder;
    IsmLiveDelegate.chatMessageBuilder = chatMessageBuilder;
    IsmLiveDelegate.chatItemBgColorCallback = chatItemBgColorCallback;
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
    IsmLiveDelegate.streamDisconnectApiHandler = streamDisconnectApiHandler;
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
    // Heart message is now handled via controlOptionCallback
    IsmLiveDelegate.streamAnalyticsApiHandler = streamAnalyticsApiHandler;
    IsmLiveDelegate.streamAnalyticsViewersApiHandler =
        streamAnalyticsViewersApiHandler;
    IsmLiveDelegate.hostTopProfileClickCallback = hostTopProfileClickCallback;
    IsmLiveDelegate.missingHostTokenStopStreamCallback =
        missingHostTokenStopStreamCallback;

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

    IsmLiveDelegate.controlOptionCallback = controlOptionCallback;
    IsmLiveDelegate.controlWidgetBuilder = controlWidgetBuilder;
    IsmLiveDelegate.productStreamSideOptionsBottomMargin =
        productStreamSideOptionsBottomMargin;
    IsmLiveDelegate.cartBuilder = cartBuilder;
    IsmLiveDelegate.topViewersListCallback = topViewersListCallback;
    IsmLiveDelegate.moderatorsListCallback = moderatorsListCallback;
    IsmLiveDelegate.attentionDialogButtonCallback =
        attentionDialogButtonCallback;
    IsmLiveDelegate.streamListingRefreshCallback = streamListingRefreshCallback;
    IsmLiveDelegate.onStreamScrollCallback = onStreamScrollCallback;
    IsmLiveDelegate.addCoinsClickCallback = addCoinsClickCallback;
    IsmLiveDelegate.giftClickCallback = giftClickCallback;
    IsmLiveDelegate.heartBatchFlushCallback = heartBatchFlushCallback;
    IsmLiveDelegate.analyticsDelegate = analyticsDelegate;
    IsmLiveDelegate.enabledAnalyticsEvents = enabledAnalyticsEvents;
    IsmLiveDelegate.bottomSheetBorderRadius = bottomSheetBorderRadius;
    // Camera position preference for streams (suffix to avoid other camera screens)
    if (initialCameraPositionStream != null) {
      IsmLiveDelegate.initialCameraPositionStream = initialCameraPositionStream;
    }
    IsmLiveDelegate.streamRecordingPlayerConfig = streamRecordingPlayerConfig;

    // Chat polling fallback while MQTT disconnected (host can override).
    IsmLiveDelegate.mqttChatFallbackInterval =
        mqttChatFallbackInterval ?? const Duration(seconds: 6);
    IsmLiveDelegate.enableInternalStreamListingRefresh =
        enableInternalStreamListingRefresh;
    IsmLiveDelegate.useGridLayoutForMultipleParticipants =
        useGridLayoutForMultipleParticipants;
  }

  static Future<void> endStream(
          {required BuildContext context,
          bool isSchedule = false,
          bool showViewerLeaveDialog = false}) async =>
      await IsmLiveDelegate.endStream(
          context: context,
          isSchedule: isSchedule,
          showViewerLeaveDialog: showViewerLeaveDialog);

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

  static Future<void> initializeAndJoinStream(
      {required IsmLiveStreamDataModel stream,
      required bool isHost,
      required BuildContext context,
      VoidCallback? onStreamEnd,
      bool isScrolling = false}) async {
    assert(
      _initialized,
      'IsmLiveApp || IsmLiveMqtt is not initialized. Initialize it using `IsmLiveApp.initialize(config) and/or IsmLiveApp.initializeMqtt()`',
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    // IsmLiveUtility.updateLater(() async {
    final startedAt = DateTime.now();
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.streamInitializeAndJoinAttempt,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'is_host': isHost,
          'is_scrolling': isScrolling,
          'is_paid': stream.isPaid ?? false,
          'is_buy': stream.isBuy ?? false,
          'is_scheduled_stream': stream.isScheduledStream ?? false,
          'is_pk': stream.isPkChallenge ?? false,
          'audio_only': stream.audioOnly ?? false,
          'hd_broadcast': stream.hdBroadcast ?? false,
          'restream': stream.restream ?? false,
          'stream_type': stream.type ?? '',
          'viewers_count': stream.viewersCount ?? 0,
        }
      ],
    );
    try {
      await Get.find<IsmLiveStreamController>().initializeAndJoinStream(
          stream, isHost,
          context: context, isScrolling: isScrolling, onStreamEnd: onStreamEnd);
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.streamInitializeAndJoinSuccess,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'is_host': isHost,
            'is_scrolling': isScrolling,
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
          }
        ],
      );
    } catch (e) {
      IsmLiveLog.error('Error in initializeAndJoinStream: $e');
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.streamInitializeAndJoinFailure,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'is_host': isHost,
            'is_scrolling': isScrolling,
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': e.toString(),
          }
        ],
      );
    }
    // });
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

  static IsmLiveStreamHeaderBuilder? get streamHeader =>
      IsmLiveDelegate.streamHeader;

  static IsmLiveHeaderBuilder? get bottomBuilder =>
      IsmLiveDelegate.bottomBuilder;

  static IsmLiveInputBuilder? get inputBuilder => IsmLiveDelegate.inputBuilder;

  static IsmLiveCustomBottomSheetBuilder? get customBottomSheetBuilder =>
      IsmLiveDelegate.customBottomSheetBuilder;

  static Widget? get endButton => IsmLiveDelegate.endButton;

  static bool get showHeader => IsmLiveDelegate.showHeader;

  /// See [IsmLiveDelegate.useGridLayoutForMultipleParticipants].
  static bool get useGridLayoutForMultipleParticipants =>
      IsmLiveDelegate.useGridLayoutForMultipleParticipants;

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

  static StreamAnalyticsApiHandler? get streamAnalyticsApiHandler =>
      IsmLiveDelegate.streamAnalyticsApiHandler;

  static StreamAnalyticsViewersApiHandler?
      get streamAnalyticsViewersApiHandler =>
          IsmLiveDelegate.streamAnalyticsViewersApiHandler;

  static HostTopProfileClickCallback? get hostTopProfileClickCallback =>
      IsmLiveDelegate.hostTopProfileClickCallback;

  static MissingHostTokenStopStreamCallback?
      get missingHostTokenStopStreamCallback =>
          IsmLiveDelegate.missingHostTokenStopStreamCallback;

  static GoLiveHeaderBuilder? get goLiveHeaderBuilder =>
      IsmLiveDelegate.goLiveScreenConfigure?.goLiveHeaderBuilder;

  static GoLiveButtonBuilder? get goLiveButtonBuilder =>
      IsmLiveDelegate.goLiveScreenConfigure?.goLiveButtonBuilder;

  static IsmLiveCartBuilder? get cartBuilder => IsmLiveDelegate.cartBuilder;

  static TopViewersListCallback? get topViewersListCallback =>
      IsmLiveDelegate.topViewersListCallback;

  static ModeratorsListCallback? get moderatorsListCallback =>
      IsmLiveDelegate.moderatorsListCallback;

  static AttentionDialogButtonCallback? get attentionDialogButtonCallback =>
      IsmLiveDelegate.attentionDialogButtonCallback;

  static BorderRadius? get bottomSheetBorderRadius =>
      IsmLiveDelegate.bottomSheetBorderRadius;

  static StreamListingRefreshCallback? get streamListingRefreshCallback =>
      IsmLiveDelegate.streamListingRefreshCallback;

  static OnStreamScrollCallback? get onStreamScrollCallback =>
      IsmLiveDelegate.onStreamScrollCallback;

  static AddCoinsClickCallback? get addCoinsClickCallback =>
      IsmLiveDelegate.addCoinsClickCallback;

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

  // Removed: updateHeartMessageCallback (use controlOptionCallback instead)

  /// Update stream analytics API handler dynamically at runtime
  static void updateStreamAnalyticsApiHandler(
      StreamAnalyticsApiHandler? streamAnalyticsApiHandler) {
    IsmLiveDelegate.streamAnalyticsApiHandler = streamAnalyticsApiHandler;
  }

  /// Update stream analytics viewers API handler dynamically at runtime
  static void updateStreamAnalyticsViewersApiHandler(
      StreamAnalyticsViewersApiHandler? streamAnalyticsViewersApiHandler) {
    IsmLiveDelegate.streamAnalyticsViewersApiHandler =
        streamAnalyticsViewersApiHandler;
  }

  /// Update host top profile click callback dynamically at runtime
  static void updateHostTopProfileClickCallback(
      HostTopProfileClickCallback? hostTopProfileClickCallback) {
    IsmLiveDelegate.hostTopProfileClickCallback = hostTopProfileClickCallback;
  }

  /// Update missing host token stop stream callback dynamically at runtime
  static void updateMissingHostTokenStopStreamCallback(
      MissingHostTokenStopStreamCallback? missingHostTokenStopStreamCallback) {
    IsmLiveDelegate.missingHostTokenStopStreamCallback =
        missingHostTokenStopStreamCallback;
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

  /// Update cart builder dynamically at runtime
  static void updateCartBuilder(IsmLiveCartBuilder? cartBuilder) {
    IsmLiveDelegate.cartBuilder = cartBuilder;
    // Trigger rebuild of stream view to apply new cart builder
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().update([IsmLiveStreamView.updateId]);
    }
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

  /// Update attention dialog button callback dynamically at runtime
  static void updateAttentionDialogButtonCallback(
      AttentionDialogButtonCallback? attentionDialogButtonCallback) {
    IsmLiveDelegate.attentionDialogButtonCallback =
        attentionDialogButtonCallback;
  }

  /// Update bottom sheet border radius dynamically at runtime
  static void updateBottomSheetBorderRadius(
      BorderRadius? bottomSheetBorderRadius) {
    IsmLiveDelegate.bottomSheetBorderRadius = bottomSheetBorderRadius;
  }

  /// Update stream listing refresh callback dynamically at runtime
  static void updateStreamListingRefreshCallback(
      StreamListingRefreshCallback? streamListingRefreshCallback) {
    IsmLiveDelegate.streamListingRefreshCallback = streamListingRefreshCallback;
  }

  /// Update stream scroll callback dynamically at runtime
  static void updateOnStreamScrollCallback(
      OnStreamScrollCallback? onStreamScrollCallback) {
    IsmLiveDelegate.onStreamScrollCallback = onStreamScrollCallback;
  }

  /// Update custom bottom sheet builder dynamically at runtime
  static void updateCustomBottomSheetBuilder(
      IsmLiveCustomBottomSheetBuilder? customBottomSheetBuilder) {
    IsmLiveDelegate.customBottomSheetBuilder = customBottomSheetBuilder;
  }

  /// Triggers a rebuild of stream view
  static void rebuildStreamUi() {
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().update([IsmLiveStreamView.updateId]);
    }
  }

  /// Opens the stream recording player. Host app can use this to play a list of
  /// recordings (e.g. from missed streams or search). Uses
  /// [IsmLiveDelegate.streamRecordingPlayerConfig] when [config] is null.
  ///
  /// Example:
  /// ```dart
  /// await IsmLiveApp.openStreamRecordingPlayer(
  ///   recordings: listOfIsmLiveStreamRecordingItem,
  ///   initialIndex: 0,
  ///   onLoadMore: () async {
  ///     // Fetch next page in host app and append into the same list.
  ///     await recordingsController.fetchNextRecordingsPage();
  ///   },
  /// );
  /// ```
  static Future<void> openStreamRecordingPlayer({
    required List<IsmLiveStreamRecordingItem> recordings,
    int initialIndex = 0,
    IsmLiveStreamRecordingPlayerConfig? config,
    Future<void> Function()? onLoadMore,
  }) async {
    await IsmLiveRouteManagement.goToStreamRecordingPlayer(
      recordings: recordings,
      initialIndex: initialIndex,
      config: config,
      onLoadMore: onLoadMore,
    );
  }

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
          return const IsmLiveStreamListingShimmer();
        },
      );
}
