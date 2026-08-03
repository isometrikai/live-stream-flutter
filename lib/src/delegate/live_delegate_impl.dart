part of '../live_delegate.dart';

class IsmLiveDelegate {
  factory IsmLiveDelegate() => instance;

  const IsmLiveDelegate._();

  static const IsmLiveDelegate instance = IsmLiveDelegate._();

  IsmLiveDBWrapper get _dbWrapper => Get.find();

  static VoidCallback? onStreamEnd;

  static Function(String userId)? openUserProfileView;

  static String Function(String key)? getUserProfileUrl;

  static Function(String id)? subscribStreamById;

  static Function(String id)? unsubscribStreamById;

  static IsmLiveCustomBottomSheetBuilder? customBottomSheetBuilder;

  static List<IsmLiveStreamOption> viewersOption = [];

  static List<IsmLiveStreamOption> hostOptions = [];

  static List<IsmLiveStreamOption> rtmpOptions = [];

  static List<IsmLiveStreamOption> scheduleOptions = [];

  static List<IsmLiveStreamOption> copublisherOptions = [];

  static List<IsmLiveStreamOption> pkOptions = [];

  static List<IsmLiveAnalyticsOptions> liveAnalyticsOptions = [];

  static Widget? homeScreen;

  static bool? hdStream;

  static bool? scheduleStream;

  /// Optional default value for HD Broadcast toggle in Go Live.
  static bool? defaultHdBroadcast;

  /// Optional default value for Record Broadcast toggle in Go Live.
  static bool? defaultRecordBroadcast;

  /// Optional default value for Restream Broadcast toggle in Go Live.
  static bool? defaultRestreamBroadcast;

  /// Optional default text for the stream description field in Go Live.
  ///
  /// Used when [IsmLiveGoLiveScreenConfigure.defaultBroadcastDescription] is
  /// not set. Ignored for existing/scheduled streams (see go live view init).
  static String? defaultBroadcastDescription;

  static bool? productStream;

  static bool? rtmpStream;

  static bool? restreamStream;

  static bool? paidStream;

  static bool? multiLiveStream;

  static bool? recordeStream;

  static bool productionMode = false;

  /// How often the SDK polls chat messages from the API while MQTT is
  /// disconnected.
  ///
  /// Default is 6 seconds. Host apps can override via
  /// [IsmLiveApp.configureInterface].
  static Duration mqttChatFallbackInterval = const Duration(seconds: 6);

  /// When `false`, [IsmLiveStreamController.getStreams] returns immediately
  /// without calling the listing API (init, disconnect, MQTT presence, UI
  /// refresh, etc.).
  ///
  /// Default is `true`. Set via [IsmLiveApp.configureInterface].
  static bool enableInternalStreamListingRefresh = true;

  static IsmLiveButtonConfig? buttonConfig;

  /// API handler for custom stream disconnect operations.
  ///
  /// Provides your own API implementation to replace the SDK's default disconnect endpoints.
  ///
  /// See [StreamDisconnectApiHandler] for detailed documentation and examples.
  static StreamDisconnectApiHandler? streamDisconnectApiHandler;

  static GoLiveClickCallback? onGoLiveClick;

  static GoLiveDisposeCallback? onGoLiveDispose;

  static ScheduleLiveToggleCallback? onScheduleLiveToggle;

  static IsmLiveEcomConfigure? ecomConfigure;

  static IsmLiveCoinsPlansWalletScreenConfigure? coinsPlansWalletScreenConfigure;

  /// Custom AppBar / screen back control. Set via [IsmLiveApp.configureInterface].
  static IsmLiveBackButtonBuilder? backButtonBuilder;

  static IsmLiveGoLiveScreenConfigure? goLiveScreenConfigure;

  /// Optional DeepAR face filters for host / co-publisher publish.
  ///
  /// Default is disabled (`IsmLiveDeepArConfig()`). Set via
  /// [IsmLiveApp.configureInterface].
  static IsmLiveDeepArConfig deepArConfig = const IsmLiveDeepArConfig();

  /// Configuration for the live stream screen UI.
  static IsmLiveStreamScreenConfigure streamScreenConfigure =
      const IsmLiveStreamScreenConfigure();

  static bool enableFreeGift = false;

  static bool restrictProfileSheetOnProfileClick = false;

  /// When `true`, user listing APIs exclude guest-role users (`q=role-guest&op=ne`).
  static bool excludeGuestUsers = false;

  static String? fontFamily;

  /// API handler for custom stream analytics implementation.
  ///
  /// Provides your own API implementation to replace the SDK's default analytics endpoint.
  /// See [StreamAnalyticsApiHandler] for detailed documentation and examples.
  static StreamAnalyticsApiHandler? streamAnalyticsApiHandler;

  /// API handler for custom stream analytics viewers implementation.
  ///
  /// Provides your own API implementation to replace the SDK's default analytics viewers endpoint.
  /// See [StreamAnalyticsViewersApiHandler] for detailed documentation and examples.
  static StreamAnalyticsViewersApiHandler? streamAnalyticsViewersApiHandler;

  static MissingHostTokenStopStreamCallback? missingHostTokenStopStreamCallback;

  static ControlOptionCallback? controlOptionCallback;

  static ControlWidgetBuilder? controlWidgetBuilder;

  /// See [ProductStreamSideOptionsBottomMarginBuilder].
  static ProductStreamSideOptionsBottomMarginBuilder?
      productStreamSideOptionsBottomMargin;

  /// Configuration for right-side stream control icons.
  static IsmLiveSideIconsConfigure sideIconsConfigure =
      const IsmLiveSideIconsConfigure();

  static AttentionDialogButtonCallback? attentionDialogButtonCallback;

  static StreamListingRefreshCallback? streamListingRefreshCallback;

  /// Optional callback invoked when `userToken` is expired.
  /// If it returns a new token, the SDK retries the failed request once.
  static TokenExpiredCallback? tokenExpiredCallback;

  /// Optional analytics delegate to capture SDK events.
  static IsmLiveAnalyticsDelegate? analyticsDelegate;

  /// Optional enum-based allow-list of analytics event names.
  ///
  /// - When `null` or empty: all events are emitted.
  /// - When non-empty: only events present in this set are emitted.
  static Set<IsmLiveAnalyticsEventType>? enabledAnalyticsEventTypes;

  static bool _isFailedApiResult(List<Map<String, dynamic>>? properties) {
    if (properties == null || properties.isEmpty) {
      return false;
    }
    return properties.first['has_error'] == true;
  }

  static bool _usesAllFailedTypesPreset(
    Set<IsmLiveAnalyticsEventType>? enabledTypes,
  ) {
    if (enabledTypes == null || enabledTypes.isEmpty) {
      return false;
    }
    return enabledTypes.containsAll(IsmLiveAnalyticsEvent.allFailedTypes);
  }

  /// Safely emits an analytics event (never throws, never blocks).
  static void trackEvent(
    String eventName, {
    List<Map<String, dynamic>>? properties,
    IsmLiveAnalyticsCategory? category,
  }) {
    final delegate = analyticsDelegate;
    if (delegate == null) return;

    final eventType = IsmLiveAnalyticsEventType.fromWireName(eventName);
    final enabledTypes = enabledAnalyticsEventTypes;
    if (enabledTypes != null &&
        enabledTypes.isNotEmpty &&
        !enabledTypes.contains(eventType)) {
      return;
    }
    // Keep failure-only preset semantics for API results.
    // allFailedTypes includes apiResult, but it should emit only failed calls.
    if (eventType == IsmLiveAnalyticsEventType.apiResult &&
        _usesAllFailedTypesPreset(enabledTypes) &&
        !_isFailedApiResult(properties)) {
      return;
    }
    try {
      delegate.trackEventModel(
        IsmLiveAnalyticsEventModel(
          eventType: eventType,
          category: category ?? IsmLiveAnalyticsEvent.inferCategory(eventName),
          properties: properties,
        ),
      );
    } catch (e, st) {
      IsmLiveLog.error('IsmLive analytics delegate threw: $e', st);
    }
  }

  static BorderRadius? bottomSheetBorderRadius;

  /// Configuration for the Stream Recording Player. Set via [IsmLiveApp.configureInterface].
  static IsmLiveStreamRecordingPlayerConfig? streamRecordingPlayerConfig;

  /// No-op config used when [streamRecordingPlayerConfig] is null so the player
  /// can open for internal/testing (video plays; initial API is via config
  /// [IsmLiveStreamRecordingPlayerConfig.onLoaded]).
  static IsmLiveStreamRecordingPlayerConfig
      get defaultStreamRecordingPlayerConfig =>
          _defaultStreamRecordingPlayerConfig;
  static const IsmLiveStreamRecordingPlayerConfig
      _defaultStreamRecordingPlayerConfig =
      IsmLiveStreamRecordingPlayerConfig();

  /// Global UI preference: initial camera position when connecting to a stream room
  /// Defaults to back camera to preserve existing behavior
  static IsmLiveCameraPosition initialCameraPositionStream =
      IsmLiveCameraPosition.front;

  /// Triggers a rebuild of the pinned product widget by updating the stream controller
  static void updatePinnedProductWidget() {
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().update([IsmLiveStreamView.updateId]);
    }
  }

  Future<void> initialize(
    IsmLiveConfigData config, {
    VoidCallback? onEndStream,
  }) async {
    onStreamEnd = onEndStream;

    // Do not block SDK init on notification permission / plugin setup
    // (same idea as MQTT — may wait on a system dialog or hang on some OEMs).
    unawaited(
      LocalNotificationService().init().catchError((Object e, StackTrace st) {
        IsmLiveLog.error('LocalNotificationService.init failed: $e', st);
      }),
    );

    await IsmLiveHandler.initialize();
    await _dbWrapper.saveValueSecurely(
      IsmLiveLocalKeys.configDetails,
      config.toJson(),
    );

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.sdkInitialize,
      properties: [
        {
          'project_id': config.projectConfig.projectId,
          'account_id': config.projectConfig.accountId,
          'user_id': config.userConfig.userId,
        }
      ],
    );
    IsmLiveLog.info('IsmLiveApp : configDetails data set Successfully');
  }

  static Future<void> endStream(
      {required BuildContext context,
      bool isSchedule = false,
      bool showViewerLeaveDialog = false}) async {
    assert(Get.isRegistered<IsmLiveStreamController>(),
        'StreamController is not initialized');
    IsmLiveLog.error('Calling Leave API from Outside');
    var controller = Get.find<IsmLiveStreamController>();
    if (controller.streamId.isNullOrEmpty) {
      IsmLiveLog.error('StreamId is null or empty ${controller.streamId} ');
      // if (isSchedule) {
      IsmLiveRoute.pop();
      // }
      return;
    }

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.streamEndRequested,
      properties: [
        {
          'stream_id': controller.streamId ?? '',
          'is_host': controller.isHost,
          'is_schedule': isSchedule,
          'show_viewer_leave_dialog': showViewerLeaveDialog,
        }
      ],
    );

    await controller.onExit(
      isHost: controller.isHost,
      streamId: controller.streamId!,
      context: context,
      showViewerLeaveDialog: showViewerLeaveDialog,
    );
  }
}
