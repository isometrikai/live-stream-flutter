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

  @Deprecated('Use streamScreenConfigure.streamHeader instead.')
  static IsmLiveStreamHeaderBuilder? get streamHeader =>
      streamScreenConfigure.streamHeader;

  @Deprecated('Use streamScreenConfigure.streamHeader instead.')
  static set streamHeader(IsmLiveStreamHeaderBuilder? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(streamHeader: value);
  }

  @Deprecated('Use streamScreenConfigure.streamBottomBuilder instead.')
  static IsmLiveStreamBottomBuilder? get streamBottomBuilder =>
      streamScreenConfigure.streamBottomBuilder;

  @Deprecated('Use streamScreenConfigure.streamBottomBuilder instead.')
  static set streamBottomBuilder(IsmLiveStreamBottomBuilder? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(streamBottomBuilder: value);
  }

  @Deprecated('Use streamScreenConfigure.streamBottomBuilder instead.')
  static IsmLiveHeaderBuilder? get bottomBuilder => streamBottomBuilder;

  @Deprecated('Use streamScreenConfigure.streamBottomBuilder instead.')
  static set bottomBuilder(IsmLiveHeaderBuilder? value) =>
      streamBottomBuilder = value;

  @Deprecated('Use streamScreenConfigure.inputBuilder instead.')
  static IsmLiveInputBuilder? get inputBuilder =>
      streamScreenConfigure.inputBuilder;

  @Deprecated('Use streamScreenConfigure.inputBuilder instead.')
  static set inputBuilder(IsmLiveInputBuilder? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(inputBuilder: value);
  }

  static IsmLiveCustomBottomSheetBuilder? customBottomSheetBuilder;

  @Deprecated('Use streamScreenConfigure.chatMessageBuilder instead.')
  static IsmLiveChatMessageBuilder? get chatMessageBuilder =>
      streamScreenConfigure.chatMessageBuilder;

  @Deprecated('Use streamScreenConfigure.chatMessageBuilder instead.')
  static set chatMessageBuilder(IsmLiveChatMessageBuilder? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(chatMessageBuilder: value);
  }

  @Deprecated('Use streamScreenConfigure.chatItemBgColorCallback instead.')
  static IsmLiveChatItemBgColorCallback? get chatItemBgColorCallback =>
      streamScreenConfigure.chatItemBgColorCallback;

  @Deprecated('Use streamScreenConfigure.chatItemBgColorCallback instead.')
  static set chatItemBgColorCallback(IsmLiveChatItemBgColorCallback? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(chatItemBgColorCallback: value);
  }

  @Deprecated('Use streamScreenConfigure.endButton instead.')
  static Widget? get endButton => streamScreenConfigure.endButton;

  @Deprecated('Use streamScreenConfigure.endButton instead.')
  static set endButton(Widget? value) {
    streamScreenConfigure = streamScreenConfigure.copyWith(endButton: value);
  }

  @Deprecated('Use streamScreenConfigure.showStreamHeader instead.')
  static bool get showStreamHeader => streamScreenConfigure.showStreamHeader;

  @Deprecated('Use streamScreenConfigure.showStreamHeader instead.')
  static set showStreamHeader(bool value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(showStreamHeader: value);
  }

  @Deprecated('Use streamScreenConfigure.showStreamHeader instead.')
  static bool get showHeader => showStreamHeader;

  @Deprecated('Use streamScreenConfigure.showStreamHeader instead.')
  static set showHeader(bool value) => showStreamHeader = value;

  @Deprecated('Use streamScreenConfigure.resolvedStreamHeaderPosition instead.')
  static Alignment get streamHeaderPosition =>
      streamScreenConfigure.resolvedStreamHeaderPosition;

  @Deprecated('Use streamScreenConfigure.streamHeaderPosition instead.')
  static set streamHeaderPosition(Alignment value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(streamHeaderPosition: value);
  }

  @Deprecated('Use streamScreenConfigure.resolvedStreamHeaderPosition instead.')
  static Alignment get headerPosition => streamHeaderPosition;

  @Deprecated('Use streamScreenConfigure.streamHeaderPosition instead.')
  static set headerPosition(Alignment value) => streamHeaderPosition = value;

  @Deprecated(
    'Use streamScreenConfigure.resolvedEndStreamWidgetPosition instead.',
  )
  static Alignment get endStreamWidgetPosition =>
      streamScreenConfigure.resolvedEndStreamWidgetPosition;

  @Deprecated('Use streamScreenConfigure.endStreamWidgetPosition instead.')
  static set endStreamWidgetPosition(Alignment value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(endStreamWidgetPosition: value);
  }

  @Deprecated(
    'Use streamScreenConfigure.resolvedEndStreamWidgetPosition instead.',
  )
  static Alignment get endStreamPosition => endStreamWidgetPosition;

  @Deprecated('Use streamScreenConfigure.endStreamWidgetPosition instead.')
  static set endStreamPosition(Alignment value) =>
      endStreamWidgetPosition = value;

  @Deprecated(
    'Use streamScreenConfigure.useGridLayoutForMultipleParticipants instead.',
  )
  static bool get useGridLayoutForMultipleParticipants =>
      streamScreenConfigure.resolvedUseGridLayoutForMultipleParticipants;

  @Deprecated(
    'Use streamScreenConfigure.useGridLayoutForMultipleParticipants instead.',
  )
  static set useGridLayoutForMultipleParticipants(bool value) {
    streamScreenConfigure = streamScreenConfigure.copyWith(
      useGridLayoutForMultipleParticipants: value,
    );
  }

  @Deprecated(
    'Use streamScreenConfigure.showParticipantFullNamesInPublisherGrid instead.',
  )
  static bool get showParticipantFullNamesInPublisherGrid =>
      streamScreenConfigure.resolvedShowParticipantFullNamesInPublisherGrid;

  @Deprecated(
    'Use streamScreenConfigure.showParticipantFullNamesInPublisherGrid instead.',
  )
  static set showParticipantFullNamesInPublisherGrid(bool value) {
    streamScreenConfigure = streamScreenConfigure.copyWith(
      showParticipantFullNamesInPublisherGrid: value,
    );
  }

  static List<IsmLiveStreamOption> viewersOption = [];

  static List<IsmLiveStreamOption> hostOptions = [];

  static List<IsmLiveStreamOption> rtmpOptions = [];

  static List<IsmLiveStreamOption> scheduleOptions = [];

  static List<IsmLiveStreamOption> copublisherOptions = [];

  static List<IsmLiveStreamOption> pkOptions = [];

  static List<IsmLiveAnalyticsOptions> liveAnalyticsOptions = [];

  static Widget? homeScreen;

  @Deprecated('Use streamScreenConfigure.logoWidget instead.')
  static Widget? get logoWidget => streamScreenConfigure.logoWidget;

  @Deprecated('Use streamScreenConfigure.logoWidget instead.')
  static set logoWidget(Widget? value) {
    streamScreenConfigure = streamScreenConfigure.copyWith(logoWidget: value);
  }

  @Deprecated('Use streamScreenConfigure.endStreamScreen instead.')
  static Widget? get endStreamScreen => streamScreenConfigure.endStreamScreen;

  @Deprecated('Use streamScreenConfigure.endStreamScreen instead.')
  static set endStreamScreen(Widget? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(endStreamScreen: value);
  }

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

  @Deprecated('Use buttonConfig instead.')
  static IsmLiveButtonConfig? get ismLiveButtonConfig => buttonConfig;

  @Deprecated('Use buttonConfig instead.')
  static set ismLiveButtonConfig(IsmLiveButtonConfig? value) =>
      buttonConfig = value;

  @Deprecated(
    'Use IsmLiveDelegate.sideIconsConfigure.controlOptionBgGradient instead.',
  )
  static LinearGradient? get controlOptionBgGradient =>
      sideIconsConfigure.controlOptionBgGradient;

  @Deprecated(
    'Use IsmLiveDelegate.sideIconsConfigure.controlOptionBgGradient instead.',
  )
  static set controlOptionBgGradient(LinearGradient? value) {
    sideIconsConfigure = sideIconsConfigure.copyWith(
      controlOptionBgGradient: value,
    );
  }

  @Deprecated(
    'Use IsmLiveDelegate.sideIconsConfigure.controlOptionBgGradient instead.',
  )
  static LinearGradient? get streamOptionsBgGradient => controlOptionBgGradient;

  @Deprecated(
    'Use IsmLiveDelegate.sideIconsConfigure.controlOptionBgGradient instead.',
  )
  static set streamOptionsBgGradient(LinearGradient? value) =>
      controlOptionBgGradient = value;

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

  /// Configuration for the live stream screen UI.
  static IsmLiveStreamScreenConfigure streamScreenConfigure =
      const IsmLiveStreamScreenConfigure();

  static bool enableFreeGift = false;

  static bool restrictProfileSheetOnProfileClick = false;

  /// When `true`, user listing APIs exclude guest-role users (`q=role-guest&op=ne`).
  static bool excludeGuestUsers = false;

  static String? fontFamily;

  @Deprecated('Use streamScreenConfigure.messageProcessCallback instead.')
  static MessageProcessCallback? get messageProcessCallback =>
      streamScreenConfigure.messageProcessCallback;

  @Deprecated('Use streamScreenConfigure.messageProcessCallback instead.')
  static set messageProcessCallback(MessageProcessCallback? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(messageProcessCallback: value);
  }

  @Deprecated('Use streamScreenConfigure.streamScreenLoadedCallback instead.')
  static StreamViewLoadedCallback? get streamScreenLoadedCallback =>
      streamScreenConfigure.streamScreenLoadedCallback;

  @Deprecated('Use streamScreenConfigure.streamScreenLoadedCallback instead.')
  static set streamScreenLoadedCallback(StreamViewLoadedCallback? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(streamScreenLoadedCallback: value);
  }

  @Deprecated('Use streamScreenConfigure.streamScreenLoadedCallback instead.')
  static StreamViewLoadedCallback? get streamViewLoadedCallback =>
      streamScreenLoadedCallback;

  @Deprecated('Use streamScreenConfigure.streamScreenLoadedCallback instead.')
  static set streamViewLoadedCallback(StreamViewLoadedCallback? value) =>
      streamScreenLoadedCallback = value;

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

  @Deprecated('Use streamScreenConfigure.hostTopProfileClickCallback instead.')
  static HostTopProfileClickCallback? get hostTopProfileClickCallback =>
      streamScreenConfigure.hostTopProfileClickCallback;

  @Deprecated('Use streamScreenConfigure.hostTopProfileClickCallback instead.')
  static set hostTopProfileClickCallback(HostTopProfileClickCallback? value) {
    streamScreenConfigure = streamScreenConfigure.copyWith(
      hostTopProfileClickCallback: value,
    );
  }

  static MissingHostTokenStopStreamCallback? missingHostTokenStopStreamCallback;

  @Deprecated('Use streamScreenConfigure.goLiveSmallButtonBuilder instead.')
  static GoLiveSmallButtonBuilder? get goLiveSmallButtonBuilder =>
      streamScreenConfigure.goLiveSmallButtonBuilder;

  @Deprecated('Use streamScreenConfigure.goLiveSmallButtonBuilder instead.')
  static set goLiveSmallButtonBuilder(GoLiveSmallButtonBuilder? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(goLiveSmallButtonBuilder: value);
  }

  @Deprecated(
    'Use streamScreenConfigure.scheduleStreamCenterOverlayBuilder instead.',
  )
  static ScheduleStreamCenterOverlayBuilder?
      get scheduleStreamCenterOverlayBuilder =>
          streamScreenConfigure.scheduleStreamCenterOverlayBuilder;

  @Deprecated(
    'Use streamScreenConfigure.scheduleStreamCenterOverlayBuilder instead.',
  )
  static set scheduleStreamCenterOverlayBuilder(
    ScheduleStreamCenterOverlayBuilder? value,
  ) {
    streamScreenConfigure = streamScreenConfigure.copyWith(
      scheduleStreamCenterOverlayBuilder: value,
    );
  }

  static ControlOptionCallback? controlOptionCallback;

  static ControlWidgetBuilder? controlWidgetBuilder;

  /// See [ProductStreamSideOptionsBottomMarginBuilder].
  static ProductStreamSideOptionsBottomMarginBuilder?
      productStreamSideOptionsBottomMargin;

  /// Configuration for right-side stream control icons.
  static IsmLiveSideIconsConfigure sideIconsConfigure =
      const IsmLiveSideIconsConfigure();

  @Deprecated('Use streamScreenConfigure.cartBuilder instead.')
  static IsmLiveCartBuilder? get cartBuilder =>
      streamScreenConfigure.cartBuilder;

  @Deprecated('Use streamScreenConfigure.cartBuilder instead.')
  static set cartBuilder(IsmLiveCartBuilder? value) {
    streamScreenConfigure = streamScreenConfigure.copyWith(cartBuilder: value);
  }

  @Deprecated('Use streamScreenConfigure.topViewersListCallback instead.')
  static TopViewersListCallback? get topViewersListCallback =>
      streamScreenConfigure.topViewersListCallback;

  @Deprecated('Use streamScreenConfigure.topViewersListCallback instead.')
  static set topViewersListCallback(TopViewersListCallback? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(topViewersListCallback: value);
  }

  @Deprecated('Use streamScreenConfigure.moderatorsListCallback instead.')
  static ModeratorsListCallback? get moderatorsListCallback =>
      streamScreenConfigure.moderatorsListCallback;

  @Deprecated('Use streamScreenConfigure.moderatorsListCallback instead.')
  static set moderatorsListCallback(ModeratorsListCallback? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(moderatorsListCallback: value);
  }

  static AttentionDialogButtonCallback? attentionDialogButtonCallback;

  static StreamListingRefreshCallback? streamListingRefreshCallback;

  @Deprecated('Use streamScreenConfigure.onStreamScrollCallback instead.')
  static OnStreamScrollCallback? get onStreamScrollCallback =>
      streamScreenConfigure.onStreamScrollCallback;

  @Deprecated('Use streamScreenConfigure.onStreamScrollCallback instead.')
  static set onStreamScrollCallback(OnStreamScrollCallback? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(onStreamScrollCallback: value);
  }

  @Deprecated('Use streamScreenConfigure.addCoinsClickCallback instead.')
  static AddCoinsClickCallback? get addCoinsClickCallback =>
      streamScreenConfigure.addCoinsClickCallback;

  @Deprecated('Use streamScreenConfigure.addCoinsClickCallback instead.')
  static set addCoinsClickCallback(AddCoinsClickCallback? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(addCoinsClickCallback: value);
  }

  @Deprecated('Use streamScreenConfigure.giftClickCallback instead.')
  static GiftClickCallback? get giftClickCallback =>
      streamScreenConfigure.giftClickCallback;

  @Deprecated('Use streamScreenConfigure.giftClickCallback instead.')
  static set giftClickCallback(GiftClickCallback? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(giftClickCallback: value);
  }

  /// Optional callback invoked when `userToken` is expired.
  /// If it returns a new token, the SDK retries the failed request once.
  static TokenExpiredCallback? tokenExpiredCallback;

  /// Optional hook when batched heart (like) taps are flushed to the backend.
  ///
  /// See [HeartBatchFlushCallback].
  @Deprecated('Use streamScreenConfigure.heartBatchFlushCallback instead.')
  static HeartBatchFlushCallback? get heartBatchFlushCallback =>
      streamScreenConfigure.heartBatchFlushCallback;

  @Deprecated('Use streamScreenConfigure.heartBatchFlushCallback instead.')
  static set heartBatchFlushCallback(HeartBatchFlushCallback? value) {
    streamScreenConfigure =
        streamScreenConfigure.copyWith(heartBatchFlushCallback: value);
  }

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
    await Future.wait([
      LocalNotificationService().init(),
      IsmLiveHandler.initialize(),
      _dbWrapper.saveValueSecurely(
          IsmLiveLocalKeys.configDetails, config.toJson()),
    ]);
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