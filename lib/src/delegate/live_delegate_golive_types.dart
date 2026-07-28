part of '../live_delegate.dart';

/// Callback for product selection.
///
/// [context] - The BuildContext from the SDK UI.
/// [currentlySelectedProducts] - The products currently selected in the SDK, for pre-selection in the host UI.
/// [onRemoveProduct] - Call this to update the SDK's product list if the host removes products from their UI.
typedef ProductSelectionCallback = Future<List<IsmLiveProductModel>> Function(
  BuildContext context,
  List<IsmLiveProductModel> currentlySelectedProducts,
  void Function(List<IsmLiveProductModel> updatedList) onRemoveProduct,
);

/// Builder for the Add Product view.
///
/// If set, this widget will be used in place of the default _AddProduct widget in go_live_view.dart.
typedef AddProductViewBuilder = Widget Function(BuildContext context);

/// Host-side configuration for Video Effects SDK on the Go Live flow.
///
/// This is intentionally small for the first production integration:
/// - disabled by default
/// - only host local camera tracks use it
/// - SDK applies a built-in default blur effect when enabled
class IsmLiveVideoEffectsConfig {
  const IsmLiveVideoEffectsConfig({
    this.isEnabled = false,
    this.customerId,
  });

  /// Enables the Effects SDK camera pipeline for host local video capture.
  ///
  /// When `false`, the SDK preserves the current camera path unchanged.
  final bool isEnabled;

  /// Customer ID used to authenticate Effects SDK on supported platforms.
  ///
  /// Required when [isEnabled] is `true`.
  final String? customerId;
}

/// Data model containing all user-entered stream details for GoLive callback
class IsmLiveGoLiveData {
  const IsmLiveGoLiveData({
    required this.isScheduledStream,
    required this.streamDetails,
    required this.description,
    required this.pickedImage,
    required this.isHdBroadcast,
    required this.isRecordingBroadcast,
    required this.isRestreamBroadcast,
    required this.isPremium,
    required this.isSchedulingBroadcast,
    required this.usePersistentStreamKey,
    required this.isRtmp,
    required this.selectedGoLiveTabItem,
    required this.selectedGoLiveStream,
    required this.scheduleLiveDate,
    required this.premiumStreamCoins,
    required this.restreamFacebook,
    required this.restreamYoutube,
    required this.restreamInstagram,
    required this.rtmpUrl,
    required this.streamKey,
    required this.rtmpUrlDevice,
    required this.streamKeyDevice,
  });

  final bool isScheduledStream;
  final IsmLiveStreamDataModel? streamDetails;
  final String description;
  final XFile? pickedImage;
  final bool isHdBroadcast;
  final bool isRecordingBroadcast;
  final bool isRestreamBroadcast;
  final bool isPremium;
  final bool isSchedulingBroadcast;
  final bool usePersistentStreamKey;
  final bool isRtmp;
  final IsmGoLiveTabItem selectedGoLiveTabItem;
  final IsmLiveStreamTypes selectedGoLiveStream;
  final DateTime scheduleLiveDate;
  final String premiumStreamCoins;
  final bool restreamFacebook;
  final bool restreamYoutube;
  final bool restreamInstagram;
  final String rtmpUrl;
  final String streamKey;
  final String rtmpUrlDevice;
  final String streamKeyDevice;
}

/// Callback for GoLive button click.
///
/// [context] - The BuildContext from the SDK UI.
/// [isScheduledStream] - Whether the stream is a scheduled stream.
/// [streamDetails] - The current stream details.
/// [goLiveData] - Comprehensive data containing all user-entered stream details.
typedef GoLiveClickCallback = Future<void> Function(
  BuildContext context,
  bool isScheduledStream,
  IsmLiveStreamDataModel? streamDetails,
  IsmLiveGoLiveData goLiveData,
);

/// Callback for GoLive view dispose.
///
/// This callback is called when the GoLive view is disposed.
/// Useful for cleanup operations like disposing controllers, clearing data, etc.
typedef GoLiveDisposeCallback = void Function();

/// Callback for schedule live toggle state changes in GoLive view.
///
/// [isScheduled] - Current toggle value for "Schedule Live".
typedef ScheduleLiveToggleCallback = void Function(bool isScheduled);

/// Callback for message processing and filtering.
///
/// [message] - The incoming message that can be modified or filtered.
/// [streamId] - The current stream ID.
/// [isMqtt] - Whether the message is coming from MQTT (true) or API (false).
/// [isHost] - Whether the current user is the host of the stream.
///
/// Return the processed message:
/// - Return the original message (modified or not) to allow it to be displayed
/// - Return null to prevent the message from being displayed
///
/// This callback is called before any message is added to the stream's message list.
/// Useful for implementing:
/// - Message content modification
/// - Profanity filtering
/// - Spam detection
/// - User-specific message blocking
/// - Content moderation
/// - Custom business rules
/// - Message transformation
typedef MessageProcessCallback = IsmLiveMessageModel? Function(
  IsmLiveMessageModel message,
  String streamId,
  bool isMqtt,
  bool isHost,
);

/// Callback for stream view loaded event.
///
/// This callback is triggered once the stream view screen is loaded and ready.
/// Useful for performing initial setup or work for the stream screen.
///
/// [isHost] - Whether the current user is the host of the stream.
/// [hostDetails] - The host member details (null if current user is not host or host details unavailable).
/// [stream] - The complete stream object containing all stream details.
///
/// This callback is called in the initState of the stream view widget.
/// Useful for implementing:
/// - Initial analytics tracking
/// - Stream-specific configuration
/// - User engagement tracking
/// - Custom UI setup
/// - Stream metadata logging
/// - Performance monitoring
/// - Custom initialization logic
typedef StreamViewLoadedCallback = void Function(
  bool isHost,
  IsmLiveMemberDetailsModel? hostDetails,
  IsmLiveStreamDataModel? stream,
);

/// Callback for stream recording player loaded event.
///
/// This callback is triggered when a recording starts playing (initial load or
/// after swipe to another recording). The host app can perform initial API
/// calls here (e.g. record view count, fetch products for the stream).
///
/// [context] - The build context from the player.
/// [recording] - The recording item that is now playing.
typedef StreamRecordingPlayerLoadedCallback = void Function(
  BuildContext context,
  IsmLiveStreamRecordingItem recording,
);

// Heart control UI can use `controlOptionCallback`. Batched like API flush uses
// `heartBatchFlushCallback` (see [HeartBatchFlushCallback]).

/// API handler for stream analytics data.
///
/// This handler is called when the SDK needs to fetch stream analytics data.
/// **Purpose**: Allows host applications to provide their own analytics API implementation
/// instead of using the SDK's default analytics endpoint.
///
/// [streamId] - The current stream ID.
/// [isHost] - Whether the current user is the host of the stream.
///
/// **Return Value**:
/// - Return `IsmLiveStreamAnalyticsModel` if your API call was successful with the analytics data
/// - Return `null` if you want the SDK to use its default analytics API
///
/// **If this handler is NOT provided**, the SDK will use its default analytics API endpoint.
///
/// **Common use cases**:
/// - Replace SDK's analytics API with your own backend endpoint
/// - Implement custom analytics APIs
/// - Real-time analytics integration
/// - Custom analytics processing and transformation
/// - Integration with external analytics services
/// - Custom analytics validation
///
/// **Example**:
/// ```dart
/// IsmLiveApp.configureInterface(
///   streamAnalyticsApiHandler: (streamId, isHost) async {
///     final data = await myApi.getStreamAnalytics(streamId);
///     return IsmLiveStreamAnalyticsModel(
///       totalViewersCount: data.viewers,
///       hearts: data.hearts,
///       // ... other fields
///     );
///   },
/// );
/// ```
typedef StreamAnalyticsApiHandler = Future<IsmLiveStreamAnalyticsModel?>
    Function(
  String streamId,
  bool isHost,
);

/// API handler for stream analytics viewers data.
///
/// This handler is called when the SDK needs to fetch stream analytics viewers data.
/// **Purpose**: Allows host applications to provide their own analytics viewers API implementation
/// instead of using the SDK's default analytics viewers endpoint.
///
/// [streamId] - The current stream ID.
/// [skip] - Number of records to skip for pagination.
/// [limit] - Number of records to return for pagination.
///
/// **Return Value**:
/// - Return `List<IsmLiveAnalyticViewerModel>` if your API call was successful with the viewers data
/// - Return `null` if you want the SDK to use its default analytics viewers API
///
/// **If this handler is NOT provided**, the SDK will use its default analytics viewers API endpoint.
///
/// **Common use cases**:
/// - Replace SDK's analytics viewers API with your own backend endpoint
/// - Implement custom analytics viewers APIs
/// - Real-time viewers data integration
/// - Custom viewers data processing and transformation
/// - Integration with external analytics services
/// - Custom viewers data validation
///
/// **Example**:
/// ```dart
/// IsmLiveApp.configureInterface(
///   streamAnalyticsViewersApiHandler: (streamId, skip, limit) async {
///     final viewers = await myApi.getStreamViewers(streamId, skip, limit);
///     return viewers.map((v) => IsmLiveAnalyticViewerModel(
///       userName: v.name,
///       profilePic: v.image,
///       // ... other fields
///     )).toList();
///   },
/// );
/// ```
typedef StreamAnalyticsViewersApiHandler
    = Future<List<IsmLiveAnalyticViewerModel>?> Function(
  String streamId,
  int skip,
  int limit,
);

/// Callback for host top profile click action.
///
/// This callback is called when a user taps on the host profile widget in the stream view.
/// Host applications can use this to implement their own host profile view or navigation.
///
/// [context] - The BuildContext from the SDK UI.
/// [isHost] - Whether the current user is the host of the stream.
/// [userIdentifier] - The user identifier of the host.
/// [name] - The name of the host.
/// [imageUrl] - The profile image URL of the host.
/// [description] - The description/bio of the host.
///
/// Return true if the host profile click was successfully handled by the host app,
/// false if the host app wants the SDK to handle it with the default bottom sheet implementation.
///
/// This callback is called before the SDK's default host profile bottom sheet handling.
/// Useful for implementing:
/// - Custom host profile views
/// - Custom navigation to host profile
/// - Custom host interaction flows
/// - Integration with external profile systems
/// - Custom host profile UI
/// - Analytics tracking for host profile views
typedef HostTopProfileClickCallback = Future<bool> Function(
  BuildContext context,
  bool isHost,
  String userIdentifier,
  String name,
  String imageUrl,
  String description,
);

/// Callback used when host token is missing while joining as host.
///
/// Return `true` to allow the SDK to call `stopStream` API.
/// Return `false` to skip the API call (host app handled it externally).
typedef MissingHostTokenStopStreamCallback = Future<bool> Function(
  BuildContext context,
  String streamId,
  String userId,
);

/// Builder for Go Live header.
///
/// This builder allows host applications to provide a custom header widget for the Go Live screen.
/// If not provided, the SDK will use the default header with close button, title, and placeholder.
///
/// [context] - The BuildContext from the SDK UI.
/// [controller] - The IsmLiveStreamController instance for accessing stream state and actions.
///
/// Return a Widget that will be displayed as the header in the Go Live screen.
/// The widget should handle its own layout and styling.
///
/// This builder is called when rendering the Go Live screen header.
/// Useful for implementing:
/// - Custom Go Live screen branding
/// - Custom navigation controls
/// - Custom header layout
/// - Integration with host app's design system
/// - Custom header actions and buttons
/// - Analytics tracking for Go Live interactions
typedef GoLiveHeaderBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamController controller,
);

/// Builder for Go Live button.
///
/// This builder allows host applications to provide a custom Go Live button widget.
/// If not provided, the SDK will use the default IsmGoLiveNavBar implementation.
///
/// [context] - The BuildContext from the SDK UI.
/// [controller] - The IsmLiveStreamController instance for accessing stream state.
/// [onGoLivePressed] - The callback function that should be called when the Go Live button is pressed.
///                     This maintains the same functionality as the default implementation.
/// [isEnabled] - Whether the Go Live button should be enabled or disabled based on validation.
///               Host apps should respect this state and disable their custom button accordingly.
///
/// Return a Widget that will be displayed as the Go Live button/navigation bar.
/// The widget should handle its own layout and styling but must call [onGoLivePressed] when activated.
/// The widget should also respect the [isEnabled] state for proper UX.
///
/// This builder is called when rendering the Go Live screen's bottom navigation area.
/// Useful for implementing:
/// - Custom Go Live button design
/// - Custom button layout and positioning
/// - Integration with host app's design system
/// - Custom button states and animations
/// - Custom validation and error handling UI
/// - Analytics tracking for Go Live button interactions
/// - Custom enabled/disabled states
typedef GoLiveButtonBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamController controller,
  VoidCallback onGoLivePressed,
  bool isEnabled,
);

/// Builder for small Go Live button in scheduled streams.
///
/// This builder allows host applications to provide a custom small Go Live button widget
/// for scheduled streams. This is a simpler, smaller button compared to the main Go Live button.
///
/// [context] - The BuildContext from the SDK UI.
/// [controller] - The IsmLiveStreamController instance for accessing stream state and schedule time.
/// [onGoLivePressed] - The callback function that should be called when the Go Live button is pressed.
/// [isEnabled] - Whether the Go Live button should be enabled or disabled.
///
/// Return a Widget that will be displayed as the small Go Live button.
/// The widget should handle its own layout and styling but must call [onGoLivePressed] when activated.
/// The widget should also respect the [isEnabled] state for proper UX.
///
/// This builder is called when rendering the small Go Live button in scheduled stream view.
/// Useful for implementing:
/// - Custom small Go Live button design
/// - Custom button styling for scheduled streams
/// - Integration with host app's design system
/// - Custom button states and animations
/// - Analytics tracking for scheduled stream Go Live interactions
/// - Schedule time logic and display
typedef GoLiveSmallButtonBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamController controller,
  VoidCallback onGoLivePressed,
  bool isEnabled,
);

/// Builder for custom centered overlay UI in scheduled stream view.
///
/// Host apps can use this to render their own centered content on top of the
/// scheduled-stream overlay without replacing the SDK's existing chat or
/// controls layout.
typedef ScheduleStreamCenterOverlayBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamController controller,
);
