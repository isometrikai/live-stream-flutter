/// Host app analytics integration.
///
/// Provide a single delegate to receive important SDK events in a consistent
/// format, compatible with common analytics services.
abstract class IsmLiveAnalyticsDelegate {
  const IsmLiveAnalyticsDelegate();

  /// Analytics callback for SDK events.
  void trackEventModel(IsmLiveAnalyticsEventModel event);
}

/// High-level category for analytics events.
enum IsmLiveAnalyticsCategory {
  userAction('user_action'),
  system('system'),
  api('api'),
  error('error');

  const IsmLiveAnalyticsCategory(this.value);
  final String value;
}

/// Strongly typed analytics event identifier for host-app filtering.
///
/// Use [wireName] when you need the canonical string value.
enum IsmLiveAnalyticsEventType {
  unknown,
  sdkInitialize,
  sdkInitializeAttempt,
  sdkInitializeSuccess,
  sdkInitializeFailure,
  streamConnectAttempt,
  streamInitializeAndJoinAttempt,
  streamInitializeAndJoinSuccess,
  streamInitializeAndJoinFailure,
  controllerInitializeAndJoinAttempt,
  controllerInitializeAndJoinSuccess,
  controllerInitializeAndJoinFailure,
  controllerRejoinAutoDetected,
  controllerPreventDisposeEnabled,
  controllerInitializeIndex,
  controllerJoinStreamAttempt,
  controllerJoinStreamSuccess,
  controllerJoinStreamFailure,
  streamScroll,
  streamEndRequested,
  addCoinsClick,
  giftClick,
  joinStreamAttempt,
  joinStreamEarlyReturnScheduledNotStarted,
  joinStreamTokenFetchHost,
  joinStreamTokenFetchViewer,
  joinStreamMissingHostToken,
  joinStreamStopStreamCalled,
  joinStreamConnectStreamAttempt,
  joinStreamConnectStreamSuccess,
  joinStreamConnectStreamFailure,
  connectStreamAttemptDetailed,
  connectStreamMqttSubscribeAttempt,
  connectStreamMqttSubscribeFailure,
  connectStreamDeferredNavigationAttempt,
  connectStreamDeferredNavigationSuccess,
  connectStreamDeferredNavigationFailure,
  connectRoomAndInitializeAttempt,
  connectRoomAndInitializeSuccess,
  connectRoomAndInitializeFailure,
  roomInitStart,
  previousRoomDisconnectAttempt,
  previousRoomDisconnectDone,
  preconnectAbortedStreamDisposed,
  roomConnectAttempt,
  roomConnectSuccess,
  roomConnectFailure,
  roomConnectDiscardedStale,
  postConnectApiKickoff,
  goToStreamViewAttempt,
  goToStreamViewSuccess,
  goToStreamViewFailure,
  connectFlowOuterFailure,
  apiResult,
  mqttConnected,
  mqttDisconnected,
  mqttAutoReconnectStarted,
  mqttAutoReconnectSuccess,
  mqttAutoReconnectUpdatesSub,
  mqttManualReconnectAttempt,
  mqttManualReconnectSuccess,
  mqttManualReconnectFailure,
  mqttInitializeFailure,
  mqttSubscribeStream,
  mqttSubscribeStreamNotConnected,
  mqttSubscribeStreamFailure,
  mqttSubscriptionFailed,
  mqttTopicsResubscribed,
  screenView,
  recordingVideoLoadFailure;

  String get wireName {
    switch (this) {
      case IsmLiveAnalyticsEventType.unknown:
        return '';
      case IsmLiveAnalyticsEventType.sdkInitialize:
        return IsmLiveAnalyticsEvent.sdkInitialize;
      case IsmLiveAnalyticsEventType.sdkInitializeAttempt:
        return IsmLiveAnalyticsEvent.sdkInitializeAttempt;
      case IsmLiveAnalyticsEventType.sdkInitializeSuccess:
        return IsmLiveAnalyticsEvent.sdkInitializeSuccess;
      case IsmLiveAnalyticsEventType.sdkInitializeFailure:
        return IsmLiveAnalyticsEvent.sdkInitializeFailure;
      case IsmLiveAnalyticsEventType.streamConnectAttempt:
        return IsmLiveAnalyticsEvent.streamConnectAttempt;
      case IsmLiveAnalyticsEventType.streamInitializeAndJoinAttempt:
        return IsmLiveAnalyticsEvent.streamInitializeAndJoinAttempt;
      case IsmLiveAnalyticsEventType.streamInitializeAndJoinSuccess:
        return IsmLiveAnalyticsEvent.streamInitializeAndJoinSuccess;
      case IsmLiveAnalyticsEventType.streamInitializeAndJoinFailure:
        return IsmLiveAnalyticsEvent.streamInitializeAndJoinFailure;
      case IsmLiveAnalyticsEventType.controllerInitializeAndJoinAttempt:
        return IsmLiveAnalyticsEvent.controllerInitializeAndJoinAttempt;
      case IsmLiveAnalyticsEventType.controllerInitializeAndJoinSuccess:
        return IsmLiveAnalyticsEvent.controllerInitializeAndJoinSuccess;
      case IsmLiveAnalyticsEventType.controllerInitializeAndJoinFailure:
        return IsmLiveAnalyticsEvent.controllerInitializeAndJoinFailure;
      case IsmLiveAnalyticsEventType.controllerRejoinAutoDetected:
        return IsmLiveAnalyticsEvent.controllerRejoinAutoDetected;
      case IsmLiveAnalyticsEventType.controllerPreventDisposeEnabled:
        return IsmLiveAnalyticsEvent.controllerPreventDisposeEnabled;
      case IsmLiveAnalyticsEventType.controllerInitializeIndex:
        return IsmLiveAnalyticsEvent.controllerInitializeIndex;
      case IsmLiveAnalyticsEventType.controllerJoinStreamAttempt:
        return IsmLiveAnalyticsEvent.controllerJoinStreamAttempt;
      case IsmLiveAnalyticsEventType.controllerJoinStreamSuccess:
        return IsmLiveAnalyticsEvent.controllerJoinStreamSuccess;
      case IsmLiveAnalyticsEventType.controllerJoinStreamFailure:
        return IsmLiveAnalyticsEvent.controllerJoinStreamFailure;
      case IsmLiveAnalyticsEventType.streamScroll:
        return IsmLiveAnalyticsEvent.streamScroll;
      case IsmLiveAnalyticsEventType.streamEndRequested:
        return IsmLiveAnalyticsEvent.streamEndRequested;
      case IsmLiveAnalyticsEventType.addCoinsClick:
        return IsmLiveAnalyticsEvent.addCoinsClick;
      case IsmLiveAnalyticsEventType.giftClick:
        return IsmLiveAnalyticsEvent.giftClick;
      case IsmLiveAnalyticsEventType.joinStreamAttempt:
        return IsmLiveAnalyticsEvent.joinStreamAttempt;
      case IsmLiveAnalyticsEventType.joinStreamEarlyReturnScheduledNotStarted:
        return IsmLiveAnalyticsEvent.joinStreamEarlyReturnScheduledNotStarted;
      case IsmLiveAnalyticsEventType.joinStreamTokenFetchHost:
        return IsmLiveAnalyticsEvent.joinStreamTokenFetchHost;
      case IsmLiveAnalyticsEventType.joinStreamTokenFetchViewer:
        return IsmLiveAnalyticsEvent.joinStreamTokenFetchViewer;
      case IsmLiveAnalyticsEventType.joinStreamMissingHostToken:
        return IsmLiveAnalyticsEvent.joinStreamMissingHostToken;
      case IsmLiveAnalyticsEventType.joinStreamStopStreamCalled:
        return IsmLiveAnalyticsEvent.joinStreamStopStreamCalled;
      case IsmLiveAnalyticsEventType.joinStreamConnectStreamAttempt:
        return IsmLiveAnalyticsEvent.joinStreamConnectStreamAttempt;
      case IsmLiveAnalyticsEventType.joinStreamConnectStreamSuccess:
        return IsmLiveAnalyticsEvent.joinStreamConnectStreamSuccess;
      case IsmLiveAnalyticsEventType.joinStreamConnectStreamFailure:
        return IsmLiveAnalyticsEvent.joinStreamConnectStreamFailure;
      case IsmLiveAnalyticsEventType.connectStreamAttemptDetailed:
        return IsmLiveAnalyticsEvent.connectStreamAttemptDetailed;
      case IsmLiveAnalyticsEventType.connectStreamMqttSubscribeAttempt:
        return IsmLiveAnalyticsEvent.connectStreamMqttSubscribeAttempt;
      case IsmLiveAnalyticsEventType.connectStreamMqttSubscribeFailure:
        return IsmLiveAnalyticsEvent.connectStreamMqttSubscribeFailure;
      case IsmLiveAnalyticsEventType.connectStreamDeferredNavigationAttempt:
        return IsmLiveAnalyticsEvent.connectStreamDeferredNavigationAttempt;
      case IsmLiveAnalyticsEventType.connectStreamDeferredNavigationSuccess:
        return IsmLiveAnalyticsEvent.connectStreamDeferredNavigationSuccess;
      case IsmLiveAnalyticsEventType.connectStreamDeferredNavigationFailure:
        return IsmLiveAnalyticsEvent.connectStreamDeferredNavigationFailure;
      case IsmLiveAnalyticsEventType.connectRoomAndInitializeAttempt:
        return IsmLiveAnalyticsEvent.connectRoomAndInitializeAttempt;
      case IsmLiveAnalyticsEventType.connectRoomAndInitializeSuccess:
        return IsmLiveAnalyticsEvent.connectRoomAndInitializeSuccess;
      case IsmLiveAnalyticsEventType.connectRoomAndInitializeFailure:
        return IsmLiveAnalyticsEvent.connectRoomAndInitializeFailure;
      case IsmLiveAnalyticsEventType.roomInitStart:
        return IsmLiveAnalyticsEvent.roomInitStart;
      case IsmLiveAnalyticsEventType.previousRoomDisconnectAttempt:
        return IsmLiveAnalyticsEvent.previousRoomDisconnectAttempt;
      case IsmLiveAnalyticsEventType.previousRoomDisconnectDone:
        return IsmLiveAnalyticsEvent.previousRoomDisconnectDone;
      case IsmLiveAnalyticsEventType.preconnectAbortedStreamDisposed:
        return IsmLiveAnalyticsEvent.preconnectAbortedStreamDisposed;
      case IsmLiveAnalyticsEventType.roomConnectAttempt:
        return IsmLiveAnalyticsEvent.roomConnectAttempt;
      case IsmLiveAnalyticsEventType.roomConnectSuccess:
        return IsmLiveAnalyticsEvent.roomConnectSuccess;
      case IsmLiveAnalyticsEventType.roomConnectFailure:
        return IsmLiveAnalyticsEvent.roomConnectFailure;
      case IsmLiveAnalyticsEventType.roomConnectDiscardedStale:
        return IsmLiveAnalyticsEvent.roomConnectDiscardedStale;
      case IsmLiveAnalyticsEventType.postConnectApiKickoff:
        return IsmLiveAnalyticsEvent.postConnectApiKickoff;
      case IsmLiveAnalyticsEventType.goToStreamViewAttempt:
        return IsmLiveAnalyticsEvent.goToStreamViewAttempt;
      case IsmLiveAnalyticsEventType.goToStreamViewSuccess:
        return IsmLiveAnalyticsEvent.goToStreamViewSuccess;
      case IsmLiveAnalyticsEventType.goToStreamViewFailure:
        return IsmLiveAnalyticsEvent.goToStreamViewFailure;
      case IsmLiveAnalyticsEventType.connectFlowOuterFailure:
        return IsmLiveAnalyticsEvent.connectFlowOuterFailure;
      case IsmLiveAnalyticsEventType.apiResult:
        return IsmLiveAnalyticsEvent.apiResult;
      case IsmLiveAnalyticsEventType.mqttConnected:
        return IsmLiveAnalyticsEvent.mqttConnected;
      case IsmLiveAnalyticsEventType.mqttDisconnected:
        return IsmLiveAnalyticsEvent.mqttDisconnected;
      case IsmLiveAnalyticsEventType.mqttAutoReconnectStarted:
        return IsmLiveAnalyticsEvent.mqttAutoReconnectStarted;
      case IsmLiveAnalyticsEventType.mqttAutoReconnectSuccess:
        return IsmLiveAnalyticsEvent.mqttAutoReconnectSuccess;
      case IsmLiveAnalyticsEventType.mqttAutoReconnectUpdatesSub:
        return IsmLiveAnalyticsEvent.mqttAutoReconnectUpdatesSub;
      case IsmLiveAnalyticsEventType.mqttManualReconnectAttempt:
        return IsmLiveAnalyticsEvent.mqttManualReconnectAttempt;
      case IsmLiveAnalyticsEventType.mqttManualReconnectSuccess:
        return IsmLiveAnalyticsEvent.mqttManualReconnectSuccess;
      case IsmLiveAnalyticsEventType.mqttManualReconnectFailure:
        return IsmLiveAnalyticsEvent.mqttManualReconnectFailure;
      case IsmLiveAnalyticsEventType.mqttInitializeFailure:
        return IsmLiveAnalyticsEvent.mqttInitializeFailure;
      case IsmLiveAnalyticsEventType.mqttSubscribeStream:
        return IsmLiveAnalyticsEvent.mqttSubscribeStream;
      case IsmLiveAnalyticsEventType.mqttSubscribeStreamNotConnected:
        return IsmLiveAnalyticsEvent.mqttSubscribeStreamNotConnected;
      case IsmLiveAnalyticsEventType.mqttSubscribeStreamFailure:
        return IsmLiveAnalyticsEvent.mqttSubscribeStreamFailure;
      case IsmLiveAnalyticsEventType.mqttSubscriptionFailed:
        return IsmLiveAnalyticsEvent.mqttSubscriptionFailed;
      case IsmLiveAnalyticsEventType.mqttTopicsResubscribed:
        return IsmLiveAnalyticsEvent.mqttTopicsResubscribed;
      case IsmLiveAnalyticsEventType.screenView:
        return IsmLiveAnalyticsEvent.screenView;
      case IsmLiveAnalyticsEventType.recordingVideoLoadFailure:
        return IsmLiveAnalyticsEvent.recordingVideoLoadFailure;
    }
  }

  static IsmLiveAnalyticsEventType fromWireName(String wireName) {
    for (final type in IsmLiveAnalyticsEventType.values) {
      if (type.wireName == wireName) {
        return type;
      }
    }
    return IsmLiveAnalyticsEventType.unknown;
  }
}

/// Model used by [IsmLiveAnalyticsDelegate.trackEventModel].
class IsmLiveAnalyticsEventModel {
  const IsmLiveAnalyticsEventModel({
    required this.eventType,
    required this.category,
    this.properties,
  });

  /// Strongly typed SDK event for host-side filtering.
  final IsmLiveAnalyticsEventType eventType;
  final IsmLiveAnalyticsCategory category;
  final List<Map<String, dynamic>>? properties;

  /// Canonical string event name, for logging/transport use cases.
  String get eventName => eventType.wireName;

  /// Helper for host-app filtering using enum values.
  ///
  /// Example:
  /// `event.isEvent(IsmLiveAnalyticsEventType.sdkInitializeSuccess)`.
  bool isEvent(IsmLiveAnalyticsEventType sdkEventName) =>
      eventType == sdkEventName;

  @override
  String toString() =>
      'IsmLiveAnalyticsEventModel(eventType: $eventType, eventName: $eventName, category: $category, properties: $properties)';
}

/// Canonical event names emitted by the SDK via [IsmLiveAnalyticsDelegate].
///
/// Host apps should treat these as stable identifiers.
class IsmLiveAnalyticsEvent {
  const IsmLiveAnalyticsEvent._();

  // Initialization
  static const String sdkInitialize = 'ism_live_sdk_initialize';
  static const String sdkInitializeAttempt = 'ism_live_sdk_initialize_attempt';
  static const String sdkInitializeSuccess = 'ism_live_sdk_initialize_success';
  static const String sdkInitializeFailure = 'ism_live_sdk_initialize_failure';

  // Stream lifecycle
  static const String streamConnectAttempt = 'ism_live_stream_connect_attempt';
  static const String streamInitializeAndJoinAttempt =
      'ism_live_stream_initialize_and_join_attempt';
  static const String streamInitializeAndJoinSuccess =
      'ism_live_stream_initialize_and_join_success';
  static const String streamInitializeAndJoinFailure =
      'ism_live_stream_initialize_and_join_failure';

  // Stream controller flow (internal, more granular)
  static const String controllerInitializeAndJoinAttempt =
      'ism_live_controller_initialize_and_join_attempt';
  static const String controllerInitializeAndJoinSuccess =
      'ism_live_controller_initialize_and_join_success';
  static const String controllerInitializeAndJoinFailure =
      'ism_live_controller_initialize_and_join_failure';
  static const String controllerRejoinAutoDetected =
      'ism_live_controller_rejoin_auto_detected';
  static const String controllerPreventDisposeEnabled =
      'ism_live_controller_prevent_dispose_enabled';
  static const String controllerInitializeIndex =
      'ism_live_controller_initialize_index';
  static const String controllerJoinStreamAttempt =
      'ism_live_controller_join_stream_attempt';
  static const String controllerJoinStreamSuccess =
      'ism_live_controller_join_stream_success';
  static const String controllerJoinStreamFailure =
      'ism_live_controller_join_stream_failure';
  static const String streamScroll = 'ism_live_stream_scroll';
  static const String streamEndRequested = 'ism_live_stream_end_requested';

  // Commerce / engagement
  static const String addCoinsClick = 'ism_live_add_coins_click';
  static const String giftClick = 'ism_live_gift_click';

  // Join/connect detailed flow
  static const String joinStreamAttempt = 'ism_live_join_stream_attempt';
  static const String joinStreamEarlyReturnScheduledNotStarted =
      'ism_live_join_stream_early_return_scheduled_not_started';
  static const String joinStreamTokenFetchHost =
      'ism_live_join_stream_token_host';
  static const String joinStreamTokenFetchViewer =
      'ism_live_join_stream_token_viewer';
  static const String joinStreamMissingHostToken =
      'ism_live_join_stream_missing_host_token';
  static const String joinStreamStopStreamCalled =
      'ism_live_join_stream_stop_stream_called';
  static const String joinStreamConnectStreamAttempt =
      'ism_live_join_stream_connect_stream_attempt';
  static const String joinStreamConnectStreamSuccess =
      'ism_live_join_stream_connect_stream_success';
  static const String joinStreamConnectStreamFailure =
      'ism_live_join_stream_connect_stream_failure';

  static const String connectStreamAttemptDetailed =
      'ism_live_connect_stream_attempt_detailed';
  static const String connectStreamMqttSubscribeAttempt =
      'ism_live_connect_stream_mqtt_subscribe_attempt';
  static const String connectStreamMqttSubscribeFailure =
      'ism_live_connect_stream_mqtt_subscribe_failure';
  static const String connectStreamDeferredNavigationAttempt =
      'ism_live_connect_stream_deferred_navigation_attempt';
  static const String connectStreamDeferredNavigationSuccess =
      'ism_live_connect_stream_deferred_navigation_success';
  static const String connectStreamDeferredNavigationFailure =
      'ism_live_connect_stream_deferred_navigation_failure';
  static const String connectRoomAndInitializeAttempt =
      'ism_live_connect_room_and_initialize_attempt';
  static const String connectRoomAndInitializeSuccess =
      'ism_live_connect_room_and_initialize_success';
  static const String connectRoomAndInitializeFailure =
      'ism_live_connect_room_and_initialize_failure';

  // Deep connect flow (very granular but low-overhead)
  static const String roomInitStart = 'ism_live_room_init_start';
  static const String previousRoomDisconnectAttempt =
      'ism_live_previous_room_disconnect_attempt';
  static const String previousRoomDisconnectDone =
      'ism_live_previous_room_disconnect_done';
  static const String preconnectAbortedStreamDisposed =
      'ism_live_preconnect_aborted_stream_disposed';
  static const String roomConnectAttempt = 'ism_live_room_connect_attempt';
  static const String roomConnectSuccess = 'ism_live_room_connect_success';
  static const String roomConnectFailure = 'ism_live_room_connect_failure';
  static const String roomConnectDiscardedStale =
      'ism_live_room_connect_discarded_stale';
  static const String postConnectApiKickoff =
      'ism_live_post_connect_api_kickoff';
  static const String goToStreamViewAttempt =
      'ism_live_go_to_stream_view_attempt';
  static const String goToStreamViewSuccess =
      'ism_live_go_to_stream_view_success';
  static const String goToStreamViewFailure =
      'ism_live_go_to_stream_view_failure';
  static const String connectFlowOuterFailure =
      'ism_live_connect_flow_outer_failure';

  // API result logging (sanitized)
  static const String apiResult = 'ism_live_api_result';

  // MQTT connectivity
  static const String mqttConnected = 'ism_live_mqtt_connected';
  static const String mqttDisconnected = 'ism_live_mqtt_disconnected';
  static const String mqttAutoReconnectStarted =
      'ism_live_mqtt_auto_reconnect_started';
  static const String mqttAutoReconnectSuccess =
      'ism_live_mqtt_auto_reconnect_success';
  static const String mqttAutoReconnectUpdatesSub =
      'ism_live_mqtt_auto_reconnect_updates_sub';
  static const String mqttManualReconnectAttempt =
      'ism_live_mqtt_manual_reconnect_attempt';
  static const String mqttManualReconnectSuccess =
      'ism_live_mqtt_manual_reconnect_success';
  static const String mqttManualReconnectFailure =
      'ism_live_mqtt_manual_reconnect_failure';
  static const String mqttInitializeFailure =
      'ism_live_mqtt_initialize_failure';
  static const String mqttSubscribeStream = 'ism_live_mqtt_subscribe_stream';
  static const String mqttSubscribeStreamNotConnected =
      'ism_live_mqtt_subscribe_stream_not_connected';
  static const String mqttSubscribeStreamFailure =
      'ism_live_mqtt_subscribe_stream_failure';
  static const String mqttSubscriptionFailed =
      'ism_live_mqtt_subscription_failed';
  static const String mqttTopicsResubscribed =
      'ism_live_mqtt_topics_resubscribed';

  // Navigation / screen transitions
  static const String screenView = 'ism_live_screen_view';

  // Stream recording playback
  static const String recordingVideoLoadFailure =
      'ism_live_recording_video_load_failure';

  /// All analytics event keys as canonical strings.
  static const Set<String> all = <String>{
    // Initialization
    sdkInitialize,
    sdkInitializeAttempt,
    sdkInitializeSuccess,
    sdkInitializeFailure,

    // Stream lifecycle (entry-point level)
    streamConnectAttempt,
    streamInitializeAndJoinAttempt,
    streamInitializeAndJoinSuccess,
    streamInitializeAndJoinFailure,

    // Controller flow
    controllerInitializeAndJoinAttempt,
    controllerInitializeAndJoinSuccess,
    controllerInitializeAndJoinFailure,
    controllerRejoinAutoDetected,
    controllerPreventDisposeEnabled,
    controllerInitializeIndex,
    controllerJoinStreamAttempt,
    controllerJoinStreamSuccess,
    controllerJoinStreamFailure,

    // Stream events
    streamScroll,
    streamEndRequested,

    // Commerce / engagement
    addCoinsClick,
    giftClick,

    // Join / connect detailed flow
    joinStreamAttempt,
    joinStreamEarlyReturnScheduledNotStarted,
    joinStreamTokenFetchHost,
    joinStreamTokenFetchViewer,
    joinStreamMissingHostToken,
    joinStreamStopStreamCalled,
    joinStreamConnectStreamAttempt,
    joinStreamConnectStreamSuccess,
    joinStreamConnectStreamFailure,

    // Connect stream internals
    connectStreamAttemptDetailed,
    connectStreamMqttSubscribeAttempt,
    connectStreamMqttSubscribeFailure,
    connectStreamDeferredNavigationAttempt,
    connectStreamDeferredNavigationSuccess,
    connectStreamDeferredNavigationFailure,
    connectRoomAndInitializeAttempt,
    connectRoomAndInitializeSuccess,
    connectRoomAndInitializeFailure,

    // Deep connect flow
    roomInitStart,
    previousRoomDisconnectAttempt,
    previousRoomDisconnectDone,
    preconnectAbortedStreamDisposed,
    roomConnectAttempt,
    roomConnectSuccess,
    roomConnectFailure,
    roomConnectDiscardedStale,
    postConnectApiKickoff,
    goToStreamViewAttempt,
    goToStreamViewSuccess,
    goToStreamViewFailure,
    connectFlowOuterFailure,

    // API
    apiResult,

    // MQTT
    mqttConnected,
    mqttDisconnected,
    mqttAutoReconnectStarted,
    mqttAutoReconnectSuccess,
    mqttAutoReconnectUpdatesSub,
    mqttManualReconnectAttempt,
    mqttManualReconnectSuccess,
    mqttManualReconnectFailure,
    mqttInitializeFailure,
    mqttSubscribeStream,
    mqttSubscribeStreamNotConnected,
    mqttSubscribeStreamFailure,
    mqttSubscriptionFailed,
    mqttTopicsResubscribed,

    // Navigation
    screenView,

    // Stream recording playback
    recordingVideoLoadFailure,
  };

  /// Enum-typed variant of [all].
  static final Set<IsmLiveAnalyticsEventType> allTypes =
      IsmLiveAnalyticsEventType.values
          .where((e) => e != IsmLiveAnalyticsEventType.unknown)
          .toSet();

  /// Enum-typed failure-only preset.
  ///
  /// Tracks only failure/error analytics events.
  static const Set<IsmLiveAnalyticsEventType> allFailedTypes =
      <IsmLiveAnalyticsEventType>{
        IsmLiveAnalyticsEventType.sdkInitializeFailure,
        IsmLiveAnalyticsEventType.streamInitializeAndJoinFailure,
        IsmLiveAnalyticsEventType.controllerInitializeAndJoinFailure,
        IsmLiveAnalyticsEventType.controllerJoinStreamFailure,
        IsmLiveAnalyticsEventType.joinStreamConnectStreamFailure,
        IsmLiveAnalyticsEventType.connectStreamMqttSubscribeFailure,
        IsmLiveAnalyticsEventType.connectStreamDeferredNavigationFailure,
        IsmLiveAnalyticsEventType.connectRoomAndInitializeFailure,
        IsmLiveAnalyticsEventType.connectFlowOuterFailure,
        IsmLiveAnalyticsEventType.goToStreamViewFailure,
        IsmLiveAnalyticsEventType.roomConnectFailure,
        IsmLiveAnalyticsEventType.joinStreamMissingHostToken,
        IsmLiveAnalyticsEventType.preconnectAbortedStreamDisposed,
        IsmLiveAnalyticsEventType.roomConnectDiscardedStale,
        IsmLiveAnalyticsEventType.mqttManualReconnectFailure,
        IsmLiveAnalyticsEventType.mqttInitializeFailure,
        IsmLiveAnalyticsEventType.mqttSubscribeStreamFailure,
        IsmLiveAnalyticsEventType.mqttSubscriptionFailed,
        IsmLiveAnalyticsEventType.recordingVideoLoadFailure,
        IsmLiveAnalyticsEventType.apiResult,
      };

  /// Returns the default category for a known SDK event name.
  static IsmLiveAnalyticsCategory inferCategory(String eventName) {
    if (eventName == apiResult) {
      return IsmLiveAnalyticsCategory.api;
    }
    if (eventName.contains('failure') ||
        eventName.contains('failed') ||
        eventName.contains('exception') ||
        eventName.contains('crash') ||
        eventName.contains('missing') ||
        eventName.contains('aborted') ||
        eventName.contains('discarded')) {
      return IsmLiveAnalyticsCategory.error;
    }
    if (eventName == addCoinsClick ||
        eventName == giftClick ||
        eventName == streamScroll ||
        eventName == streamEndRequested) {
      return IsmLiveAnalyticsCategory.userAction;
    }
    return IsmLiveAnalyticsCategory.system;
  }
}
