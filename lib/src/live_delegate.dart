import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
// For e-commerce related delegates, see IsmLiveECommerceDelegate.

export 'analytics/live_analytics.dart';

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

/// Callback for handling any control option tap
/// Allows host apps to customize any control button behavior
/// - Custom control button functionality
/// - Integration with external services
/// - Custom permission checks
/// - Host-specific control features
///
/// [context] - The build context where the tap occurred
/// [option] - The control option that was tapped
/// [streamId] - The current stream ID
/// [isHost] - Whether the current user is the host
/// [isCopublishing] - Whether the user is copublishing
///
/// Return true if the host app handled the click and wants to prevent the default behavior,
/// false if the host app wants the SDK to handle it with the default behavior.
typedef ControlOptionCallback = Future<bool> Function(
  BuildContext context,
  IsmLiveStreamOption option,
  String streamId,
  bool isHost,
  bool isCopublishing,
);

/// Builder for custom control widgets
/// Allows host apps to replace default control widgets with custom ones
///
/// [context] - The build context
/// [option] - The control option
/// [onTap] - The tap callback
/// [isHost] - Whether the current user is the host
/// [isCopublishing] - Whether the user is copublishing
/// [streamId] - The current stream ID
///
/// Return a custom widget or null to use the default widget
typedef ControlWidgetBuilder = Widget? Function(
  BuildContext context,
  IsmLiveStreamOption option,
  VoidCallback onTap,
  bool isHost,
  bool isCopublishing,
  String streamId,
);

/// Bottom inset in logical pixels for the product-stream side options column
/// (vertical control strip). Used only when [IsmLiveDelegate.productStream] is
/// true, the keyboard is closed, and the stream is not in schedule mode.
///
/// Return a non-negative value to set the bottom [EdgeInsets] margin. Return
/// `null` to use the SDK default (28% of [MediaQuery] screen height).
///
/// Set via `IsmLiveApp.configureInterface(sideIconsConfigure:
/// IsmLiveSideIconsConfigure(productStreamSideOptionsBottomMargin: …))`.
/// When the delegate field is `null`, the default fraction is applied without calling this.
typedef ProductStreamSideOptionsBottomMarginBuilder = double? Function(
  BuildContext context,
);

/// Horizontal alignment for the right-side stream control icons.
enum IsmLiveSideIconsHorizontalAlignment {
  start,
  center,
  end,
}

/// Configuration for right-side stream control icons.
///
/// Use this object in `IsmLiveApp.configureInterface(sideIconsConfigure: ...)`
/// to customize width and horizontal alignment of control icons.
class IsmLiveSideIconsConfigure {
  const IsmLiveSideIconsConfigure({
    this.width,
    this.horizontalAlignment = IsmLiveSideIconsHorizontalAlignment.end,
    this.viewersOptions = const [],
    this.hostOptions = const [],
    this.rtmpOptions = const [],
    this.copublisherOptions = const [],
    this.pkOptions = const [],
    this.controlOptionCallback,
    this.controlWidgetBuilder,
    this.productStreamSideOptionsBottomMargin,
  });

  /// Width of side icons container in logical pixels.
  ///
  /// If null, SDK fallback width is used.
  final double? width;

  /// Horizontal alignment of icons inside the side icons container.
  final IsmLiveSideIconsHorizontalAlignment horizontalAlignment;

  /// Side icons shown to viewers.
  final List<IsmLiveStreamOption> viewersOptions;

  /// Side icons shown to host users.
  final List<IsmLiveStreamOption> hostOptions;

  /// Side icons shown in RTMP streams.
  final List<IsmLiveStreamOption> rtmpOptions;

  /// Side icons shown to copublishers.
  final List<IsmLiveStreamOption> copublisherOptions;

  /// Side icons shown in PK streams.
  final List<IsmLiveStreamOption> pkOptions;

  /// Unified side-icon tap callback.
  final ControlOptionCallback? controlOptionCallback;

  /// Custom side-icon widget builder.
  final ControlWidgetBuilder? controlWidgetBuilder;

  /// Custom bottom margin for side options in product stream mode.
  final ProductStreamSideOptionsBottomMarginBuilder?
      productStreamSideOptionsBottomMargin;
}

/// Builder for custom "Buy now" button in product streams.
///
/// This builder is called when rendering the "Buy now" button for viewers in product streams.
/// Host applications can use this to implement their own custom button design and styling.
///
/// [context] - The build context where the button is being rendered.
/// [streamId] - The current stream ID.
/// [hasPinnedProduct] - Whether there is a pinned product in the stream.
/// [isHost] - Whether the current user is the host of the stream.
/// [onTap] - The callback function to call when the button is tapped (preserves existing functionality).
///
/// The [onTap] callback should be called when the custom button is tapped to maintain
/// the existing product action functionality.
///
/// This builder is called when rendering the product stream "Buy now" button.
/// Useful for implementing:
/// - Custom button designs matching host app's theme
/// - Custom button animations and states
/// - Integration with host app's design system
/// - Custom button layouts and positioning
/// - Custom loading states during purchase
/// - Custom accessibility features
/// - Brand-specific styling and colors
typedef BuyNowButtonBuilder = Widget Function(
  BuildContext context,
  String streamId,
  bool hasPinnedProduct,
  bool isHost,
  VoidCallback onTap,
);

/// Builder for host product navigation arrow buttons in product streams.
///
/// This builder allows host applications to provide custom left/right arrow
/// controls shown when the host has a pinned product.
///
/// [context] - The build context where the buttons are rendered.
/// [streamId] - The current stream identifier.
/// [hasPinnedProduct] - Whether a product is currently pinned in the stream.
/// [onPreviousTap] - Callback for the previous (left) arrow action.
/// [onNextTap] - Callback for the next (right) arrow action.
///
/// Call [onPreviousTap] and [onNextTap] from the custom widget to preserve
/// the default pin-item navigation behavior.
typedef HostArrowButtonsBuilder = Widget Function(
  BuildContext context,
  String streamId,
  bool hasPinnedProduct,
  VoidCallback onPreviousTap,
  VoidCallback onNextTap,
);

/// Builder for custom shopping cart widget in stream header.
///
/// This builder allows host applications to provide a custom shopping cart widget
/// that appears in the stream header beside the moderator icon.
/// If not provided, the SDK will use the default cart icon implementation.
///
/// [context] - The build context where the cart widget is being rendered.
/// [controller] - The IsmLiveStreamController instance for accessing stream state and cart data.
///
/// Return a Widget that will be displayed as the shopping cart in the stream header.
/// The widget should handle its own layout and styling.
///
/// This builder is called when rendering the stream header for viewers in product streams.
/// Useful for implementing:
/// - Custom cart icon design and styling
/// - Cart item count display
/// - Custom cart interaction behavior
/// - Integration with host app's shopping cart system
/// - Custom animations and states
/// - Analytics tracking for cart interactions
/// - Custom cart management features
///
/// Note: The widget will only be displayed when:
/// - User is not the host of the stream, AND
/// - Stream has products linked (productsLinked = true)
/// - Or when host app provides a custom builder (always shows when builder is provided)
typedef IsmLiveCartBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamController controller,
);

/// Callback for top viewers list tap event.
///
/// This callback is triggered when the user taps on the viewers count/list in the stream header.
/// Host applications can use this to implement their own custom viewers UI and management.
///
/// [context] - The build context where the tap occurred.
/// [viewerList] - The current list of viewers (may be empty, actual list is in streamViewersList).
/// [streamId] - The current stream ID.
/// [isHost] - Whether the current user is the host of the stream.
/// [isModerator] - Whether the current user is a moderator of the stream.
/// [streamViewersList] - The complete list of stream viewers from the controller.
///
/// Return true if the host app handled the viewers tap and wants to prevent the default behavior,
/// false if the host app wants the SDK to handle it with the default viewers sheet.
///
/// This callback is called before the SDK's default viewers sheet handling.
/// Useful for implementing:
/// - Custom viewers list UI
/// - Custom viewer management features
/// - Integration with host app's user management system
/// - Custom viewer interaction features
/// - Custom viewer profile handling
/// - Custom moderation features
/// - Analytics tracking for viewer interactions
typedef TopViewersListCallback = Future<bool> Function(
  BuildContext context,
  List<dynamic> viewerList,
  String streamId,
  bool isHost,
  bool isModerator,
  List<IsmLiveViewerModel> streamViewersList,
);

/// Callback for moderators list tap event.
///
/// This callback is triggered when the user taps on the moderators count/list in the stream header.
/// Host applications can use this to implement their own custom moderators UI and management.
///
/// [context] - The build context where the tap occurred.
/// [streamId] - The current stream ID.
/// [isHost] - Whether the current user is the host of the stream.
/// [isModerator] - Whether the current user is a moderator of the stream.
/// [moderatorsList] - The complete list of stream moderators from the controller.
/// [hostDetails] - The host member details (null if host details unavailable).
///
/// Return true if the host app handled the moderators tap and wants to prevent the default behavior,
/// false if the host app wants the SDK to handle it with the default moderators sheet.
///
/// This callback is called before the SDK's default moderators sheet handling.
/// Useful for implementing:
/// - Custom moderators list UI
/// - Custom moderator management features
/// - Integration with host app's user management system
/// - Custom moderator interaction features
/// - Custom moderator profile handling
/// - Custom moderation control features
/// - Analytics tracking for moderator interactions
typedef ModeratorsListCallback = Future<bool> Function(
  BuildContext context,
  String streamId,
  bool isHost,
  bool isModerator,
  List<UserDetails> moderatorsList,
  IsmLiveMemberDetailsModel? hostDetails,
);

/// Callback for attention dialog button tap event.
///
/// This callback is triggered when the user taps the "Okay" button in the stream end attention dialog.
/// Host applications can use this to implement their own custom behavior when the stream ends.
///
/// [context] - The build context where the tap occurred.
///
/// Return true if your app successfully handled the attention dialog action, false to let SDK handle with default implementation.
///
/// This callback is called when the "Okay" button is tapped in the stream end attention dialog.
/// Useful for implementing:
/// - Custom navigation after stream ends
/// - Custom analytics tracking for stream end events
/// - Integration with host app's navigation flow
/// - Custom cleanup or post-stream actions
/// - Custom user feedback collection
/// - Custom redirect to other screens
///
/// Note: The dialog will be closed automatically regardless of the callback result.
typedef AttentionDialogButtonCallback = Future<bool> Function(
  BuildContext context,
);

/// Enum to identify the type of stream disconnection
enum IsmLiveStreamDisconnectType {
  /// Host is ending/stopping the stream
  host,

  /// Viewer is leaving the stream
  viewer,

  /// PK guest is leaving the stream
  pkGuest,

  /// Copublisher is leaving the stream
  copublisher,
}

/// API handler callback for stream disconnect/exit operations.
///
/// This is a unified callback that **replaces the default SDK API calls** for all types of stream disconnections.
/// It replaces the separate `onHostStopStream` and `onLeftStreamAsViewer` callbacks.
///
/// **Purpose**: Allows host applications to provide their own API implementation for stream disconnect operations
/// instead of using the SDK's default API endpoints.
///
/// [streamId] - The current stream ID.
/// [disconnectType] - The type of disconnection (host, viewer, pkGuest, copublisher).
///
/// **Return Value**:
/// - Return `true` if your API call was successful and the SDK should proceed with cleanup
/// - Return `false` if your API call failed and the SDK should abort the disconnect process
///
/// **If this callback is NOT provided**, the SDK will use its default API implementations:
/// - For `host`: calls the SDK's `stopStream` API endpoint
/// - For `viewer`: calls the SDK's `leaveStream` API endpoint
/// - For `pkGuest`: calls the SDK's `pkEnd` operation
/// - For `copublisher`: calls the SDK's `leaveMember` operation
///
/// **Common use cases**:
/// - Replace SDK API calls with your own backend endpoints
/// - Add custom authentication/authorization logic
/// - Implement custom analytics tracking for stream exits
/// - Add business logic specific to your application
/// - Integrate with external services or webhooks
/// - Implement custom retry logic and error handling
/// - Centralize all disconnect API calls in one handler
///
/// **Example**:
/// ```dart
/// IsmLiveApp.configureInterface(
///   streamDisconnectApiHandler: (streamId, disconnectType) async {
///     // Replace SDK's API with your own
///     final response = await myApi.disconnectStream(streamId, disconnectType);
///     return response.success; // true = proceed, false = abort
///   },
/// );
/// ```
typedef StreamDisconnectApiHandler = Future<bool> Function(
  String streamId,
  IsmLiveStreamDisconnectType disconnectType,
);

/// Preferred initial camera position when starting a stream
enum IsmLiveCameraPosition {
  front,
  back,
}

/// Direction for host arrow button clicks
enum IsmLiveArrowDirection {
  previous,
  next,
}

/// Callback for host arrow button clicks (pin item navigation)
///
/// This callback is triggered when the user taps on the left or right arrow buttons
/// in the host interface for product navigation.
///
/// [context] - The BuildContext from the SDK UI.
/// [direction] - The direction of the arrow that was clicked (previous or next).
///
/// This callback is called when arrow buttons are tapped in the host interface.
/// Useful for implementing:
/// - Custom product navigation
/// - Custom content switching
/// - Integration with host app's navigation system
/// - Custom analytics tracking for arrow interactions
/// - Custom UI state management
/// - Custom business logic for arrow actions
typedef PinItemCallback = void Function(
  BuildContext context,
  IsmLiveArrowDirection direction,
);

/// Callback for "Buy now" button clicks
///
/// This callback is triggered when the user taps on the "Buy now" button
/// in the product stream interface.
///
/// This callback is called when the "Buy now" button is tapped.
/// Useful for implementing:
/// - Custom purchase flow
/// - Integration with host app's e-commerce system
/// - Custom analytics tracking for purchase interactions
/// - Custom UI state management
/// - Custom business logic for purchase actions
typedef BuyNowCallback = void Function();

/// Callback for "Add Coins" button clicks
///
/// This callback is triggered when the user taps on the "Add Coins" button
/// in the gifts sheet interface.
///
/// [context] - The BuildContext from the SDK UI.
///
/// This callback is called when the "Add Coins" button is tapped.
/// Useful for implementing:
/// - Custom navigation to coins/wallet screen
/// - Integration with host app's payment system
/// - Custom analytics tracking for add coins interactions
/// - Custom UI state management
/// - Custom business logic for add coins actions
///
/// If this callback is NOT provided, the SDK will use its default navigation
/// to the coins plan wallet screen.
typedef AddCoinsClickCallback = void Function(BuildContext context);

/// Callback for gift item click events in the gifts sheet.
///
/// This callback is triggered whenever a user taps on a gift in the gifts grid.
///
/// [context] - The BuildContext from the SDK UI.
/// [gift] - The selected gift item.
///
/// This is a notification-style callback and **does not** override the default
/// gift sending behavior. The SDK will continue to handle balance checks,
/// dialogs, and sending the gift as usual.
///
/// Useful for:
/// - Custom analytics for gift interactions
/// - Logging or tracking user behavior
/// - Triggering auxiliary UI in the host app
typedef GiftClickCallback = void Function(
  BuildContext context,
  IsmLiveGiftsCategoryModel gift,
);

/// Callback when the SDK flushes accumulated heart (like) taps to the backend.
///
/// **The SDK always awaits `sendHeartMessage` first** (same API as without this
/// callback). This hook runs **after** that call succeeds, in the background, so
/// the like API is never skipped or delayed by host-app work.
///
/// Notification-style only (like [GiftClickCallback]): use for analytics, logging,
/// or auxiliary UI. Errors in the callback are logged and do not affect sending.
///
/// [streamId] - The active stream ID.
/// [likesCount] - Batch size (same value the SDK sends as `metaData.likeCounts` via
/// the standard `sendMessage` / post-message API in `sendHeartMessage`).
///
/// **If this callback is not set**, the SDK posts batched likes to the internal
/// `POST /live/v1/stream/like` endpoint (`sentViaMqtt: true`) after `sendHeartMessage`.
typedef HeartBatchFlushCallback = Future<void> Function(
  String streamId,
  int likesCount,
);

/// Callback for stream listing refresh events.
///
/// This callback is triggered when stream listing data needs to be refreshed
/// due to MQTT events like streamStartPresence or streamStopped.
/// If this callback is provided, the internal stream listing refresh will be skipped.
///
/// [eventType] - The type of event that triggered the refresh (streamStartPresence, streamStopped).
/// [streamId] - The stream ID related to the event (null for streamStartPresence).
/// [payload] - The full MQTT payload for additional context.
typedef StreamListingRefreshCallback = void Function(
  String eventType,
  String? streamId,
  Map<String, dynamic> payload,
);

/// Callback for stream scroll events.
///
/// This callback is triggered when the user scrolls to a different stream in the stream view.
/// This is a notification-only callback that does not block or affect the SDK's scroll behavior.
/// The callback is called asynchronously (fire and forget) to notify the host app of the scroll event.
///
/// [context] - The build context where the scroll occurred.
/// [currentStreamId] - The ID of the stream being left.
/// [nextStreamIndex] - The index of the stream being scrolled to.
/// [nextStream] - The stream data model of the stream being scrolled to.
/// [isHost] - Whether the current user is the host of the current stream.
///
/// This callback is called when a stream scroll is initiated, but does not wait for completion.
/// Useful for implementing:
/// - Custom analytics tracking for stream scrolling
/// - Logging stream transitions
/// - Notifying external services about scroll events
/// - Triggering background tasks
/// - Custom event tracking
/// - Stream engagement metrics
typedef OnStreamScrollCallback = void Function(
  BuildContext context,
  String currentStreamId,
  int nextStreamIndex,
  IsmLiveStreamDataModel nextStream,
  bool isHost,
);

/// Called when the backend indicates the `userToken` has expired (401/406 cases).
///
/// Host app should return a fresh token string. Returning `null`/empty means
/// "could not refresh" and the SDK will not retry.
typedef TokenExpiredCallback = FutureOr<String?> Function();

/// Control option types for the Stream Recording Player.
/// Used by [IsmLiveStreamRecordingPlayerConfig.onControlOption].
enum IsmLiveStreamRecordingControlOption {
  product,
  share,
  settings,
  deleteStream,
  reportStream,
  navigateToCart,
  navigateToSocialPost,
  openUserProfile,
}

/// Slots in the Stream Recording Player UI that can be overridden by the host.
///
/// Use [IsmLiveStreamRecordingPlayerConfig.controlWidgetBuilder] to replace
/// a specific widget while keeping the rest of the SDK layout intact.
enum IsmLiveStreamRecordingControlWidgetSlot {
  // Top controls
  topProfile,
  topCart,
  topClose,

  // Right controls
  rightProduct,
  rightShare,
  rightSettings,

  // Bottom controls
  bottomPlayPause,
  bottomSeekBar,
  bottomDuration,
}

/// Called when the user triggers a control action in the recording player.
/// [option] identifies the action (product, share, delete, etc.).
typedef IsmLiveStreamRecordingControlOptionCallback = FutureOr<void> Function(
  BuildContext context,
  IsmLiveStreamRecordingControlOption option,
  IsmLiveStreamRecordingItem recording,
);

/// Builder that can override specific widgets in the Stream Recording Player.
///
/// Return `null` to keep [defaultChild].
typedef IsmLiveStreamRecordingControlWidgetBuilder = Widget? Function(
  BuildContext context,
  IsmLiveStreamRecordingControlWidgetSlot slot,
  IsmLiveStreamRecordingItem recording,
  IsmLiveStreamRecordingPlayerConfig config,
  Widget defaultChild, {
  VoidCallback? onTap,
  VideoPlayerController? videoController,
});

/// Builder for the top controls in the Stream Recording Player.
typedef IsmLiveStreamRecordingTopControlsBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamRecordingItem recording,
  IsmLiveStreamRecordingPlayerConfig config,
  VoidCallback onClose,
);

/// Builder for the bottom controls in the Stream Recording Player.
typedef IsmLiveStreamRecordingBottomControlsBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamRecordingItem recording,
  IsmLiveStreamRecordingPlayerConfig config,
  VideoPlayerController? videoController,
  VoidCallback onPlayPause,
);

/// Builder for the right controls in the Stream Recording Player.
typedef IsmLiveStreamRecordingRightControlsBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamRecordingItem recording,
  IsmLiveStreamRecordingPlayerConfig config,
);

/// Configuration for the Stream Recording Player.
///
/// Use [onLoaded] for initial-load logic (e.g. record view count, fetch products).
/// Use [onControlOption] for all control actions (product, share, more, etc.).
class IsmLiveStreamRecordingPlayerConfig {
  const IsmLiveStreamRecordingPlayerConfig({
    this.getCurrentUserId,
    this.onLoaded,
    this.onControlOption,
    this.controlWidgetBuilder,
    this.topControlsBuilder,
    this.bottomControlsBuilder,
    this.rightControlsBuilder,
  });

  /// Optional. For "my stream" vs others.
  final String? Function()? getCurrentUserId;

  /// Optional. Called when a recording has loaded and started playing (initial or after swipe).
  /// Host can perform initial API calls here (e.g. record view count, fetch products).
  final StreamRecordingPlayerLoadedCallback? onLoaded;

  /// Optional. Single handler for control option taps (product, share, settings,
  /// deleteStream, reportStream, navigateToCart, navigateToSocialPost, openUserProfile).
  final IsmLiveStreamRecordingControlOptionCallback? onControlOption;

  /// Optional. Override individual control widgets (top/bottom/right) without
  /// replacing the whole controls widget.
  final IsmLiveStreamRecordingControlWidgetBuilder? controlWidgetBuilder;

  /// Optional. If provided, replaces [IsmLiveStreamRecordingTopControls] widget.
  final IsmLiveStreamRecordingTopControlsBuilder? topControlsBuilder;

  /// Optional. If provided, replaces [IsmLiveStreamRecordingBottomControls] widget.
  final IsmLiveStreamRecordingBottomControlsBuilder? bottomControlsBuilder;

  /// Optional. If provided, replaces [IsmLiveStreamRecordingRightControls] widget.
  final IsmLiveStreamRecordingRightControlsBuilder? rightControlsBuilder;
}

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

  static IsmLiveStreamHeaderBuilder? streamHeader;

  static IsmLiveHeaderBuilder? bottomBuilder;

  static IsmLiveInputBuilder? inputBuilder;

  static IsmLiveCustomBottomSheetBuilder? customBottomSheetBuilder;

  static IsmLiveChatMessageBuilder? chatMessageBuilder;

  static IsmLiveChatItemBgColorCallback? chatItemBgColorCallback;

  static Widget? endButton;

  static bool showHeader = true;

  static Alignment headerPosition = Alignment.topLeft;

  static Alignment endStreamPosition = Alignment.topRight;

  /// When `false` (default), two or more live participants use full-width
  /// horizontal strips stacked vertically (entire viewport split by row).
  /// When `true`, uses the legacy 2–3 column grid. Set via
  /// `IsmLiveApp.configureInterface`.
  static bool useGridLayoutForMultipleParticipants = false;

  /// When `true`, each tile in the multi-participant publisher area shows the
  /// participant [IsmLiveMemberDetailsModel.fullName] (with LiveKit name as
  /// fallback) on a semi-transparent strip at the bottom-left. Only applies
  /// when two or more publishers are shown. Default `false`. Set via
  /// `IsmLiveApp.configureInterface`.
  static bool showParticipantFullNamesInPublisherGrid = false;

  static List<IsmLiveStreamOption> viewersOption = [];

  static List<IsmLiveStreamOption> hostOptions = [];

  static List<IsmLiveStreamOption> rtmpOptions = [];

  static List<IsmLiveStreamOption> copublisherOptions = [];

  static List<IsmLiveStreamOption> pkOptions = [];

  static List<IsmLiveAnalyticsOptions> liveAnalyticsOptions = [];

  static Widget? homeScreen;

  static Widget? logoWidget;

  static Widget? endStreamScreen;

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

  static IsmLiveButtonConfig? ismLiveButtonConfig;

  static LinearGradient? streamOptionsBgGradient;

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

  static IsmLiveGoLiveScreenConfigure? goLiveScreenConfigure;

  /// Configuration for the live stream screen UI.
  static IsmLiveStreamScreenConfigure streamScreenConfigure =
      const IsmLiveStreamScreenConfigure();

  static bool enableFreeGift = false;

  static bool restrictProfileSheetOnProfileClick = false;

  static String? fontFamily;

  static MessageProcessCallback? messageProcessCallback;

  static StreamViewLoadedCallback? streamViewLoadedCallback;

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

  static HostTopProfileClickCallback? hostTopProfileClickCallback;

  static MissingHostTokenStopStreamCallback? missingHostTokenStopStreamCallback;

  static GoLiveSmallButtonBuilder? goLiveSmallButtonBuilder;

  static ScheduleStreamCenterOverlayBuilder? scheduleStreamCenterOverlayBuilder;

  static ControlOptionCallback? controlOptionCallback;

  static ControlWidgetBuilder? controlWidgetBuilder;

  /// See [ProductStreamSideOptionsBottomMarginBuilder].
  static ProductStreamSideOptionsBottomMarginBuilder?
      productStreamSideOptionsBottomMargin;

  /// Configuration for right-side stream control icons.
  static IsmLiveSideIconsConfigure sideIconsConfigure =
      const IsmLiveSideIconsConfigure();

  static IsmLiveCartBuilder? cartBuilder;

  static TopViewersListCallback? topViewersListCallback;

  static ModeratorsListCallback? moderatorsListCallback;

  static AttentionDialogButtonCallback? attentionDialogButtonCallback;

  static StreamListingRefreshCallback? streamListingRefreshCallback;

  static OnStreamScrollCallback? onStreamScrollCallback;

  static AddCoinsClickCallback? addCoinsClickCallback;

  static GiftClickCallback? giftClickCallback;

  /// Optional callback invoked when `userToken` is expired.
  /// If it returns a new token, the SDK retries the failed request once.
  static TokenExpiredCallback? tokenExpiredCallback;

  /// Optional hook when batched heart (like) taps are flushed to the backend.
  ///
  /// See [HeartBatchFlushCallback].
  static HeartBatchFlushCallback? heartBatchFlushCallback;

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

class IsmLiveEcomConfigure {
  IsmLiveEcomConfigure({
    this.addProductViewBuilder,
    this.pinnedProductBuilder,
    this.hasPinnedProductGetter,
    this.buyNowButtonBuilder,
    this.hostArrowButtonsBuilder,
    this.hostArrowButtonsSize,
    this.pinItemCallback,
    this.buyNowCallback,
  });

  final AddProductViewBuilder? addProductViewBuilder;
  final Widget? Function(
          BuildContext context, IsmLiveStreamController controller)?
      pinnedProductBuilder;
  final bool Function()? hasPinnedProductGetter;
  final BuyNowButtonBuilder? buyNowButtonBuilder;
  final HostArrowButtonsBuilder? hostArrowButtonsBuilder;
  final double? hostArrowButtonsSize;
  final PinItemCallback? pinItemCallback;
  final BuyNowCallback? buyNowCallback;

  /// Gets the current pinned product status dynamically
  bool get hasPinnedProduct => hasPinnedProductGetter?.call() ?? false;
}

/// Builder for a full-width widget at the bottom of the live stream screen,
/// rendered directly below the message input row.
///
/// Return `null` to hide the widget for the current state (e.g. when the
/// keyboard is open).
typedef StreamBottomWidgetBuilder = Widget? Function(
  BuildContext context,
  String streamId,
  bool isHost,
  bool isKeyboardOpen,
);

/// Builder for a custom widget at the end of the live timer row in the stream
/// header (after LIVE label, timer, and coins).
///
/// Only used when [streamHeaderInfoSectionBuilder] returns `null` (default UI).
/// Return `null` to hide the trailing widget.
typedef StreamHeaderTimerTrailingWidgetBuilder = Widget? Function(
  BuildContext context,
  String streamId,
  bool isHost,
  String streamCoins,
  bool isPaidStream,
);

/// Builder that replaces the stream header info section (live timer row and
/// description / PK result banner).
///
/// Return `null` to show the default timer and description UI. Return a widget
/// to show custom content instead. The stream duration timer in
/// [IsmLiveStreamController] keeps running while custom content is shown; only
/// the display is swapped.
typedef StreamHeaderInfoSectionBuilder = Widget? Function(
  BuildContext context,
  String streamId,
  bool isHost,
  String streamCoins,
  bool isPaidStream,
  String description,
  bool pkCompleted,
  bool isBattleTie,
  String? winnerName,
);

/// Builder for the message field send action button.
///
/// [disabled] reflects whether the message field is disabled.
/// [messageText] is the current input text from the message field controller.
/// [onSend] invokes the default send-message behavior when sending is allowed.
///
/// [isInsideInputField] is `true` when the send control is rendered as the
/// input suffix icon; `false` when it is rendered beside the input field.
typedef MessageSendButtonBuilder = Widget Function(
  BuildContext context,
  String streamId,
  bool isHost,
  bool disabled,
  String messageText,
  VoidCallback? onSend,
  bool isInsideInputField,
);

/// Configuration for the live stream screen UI.
///
/// Set via `IsmLiveApp.configureInterface(streamScreenConfigure: ...)`.
class IsmLiveStreamScreenConfigure {
  const IsmLiveStreamScreenConfigure({
    this.streamBottomWidgetBuilder,
    this.streamHeaderTimerTrailingWidgetBuilder,
    this.streamHeaderInfoSectionBuilder,
    this.messageSendIconInsideInputField,
    this.messageSendButtonBuilder,
  });

  /// Full-width widget shown at the bottom of the stream screen, below the
  /// message input row.
  final StreamBottomWidgetBuilder? streamBottomWidgetBuilder;

  /// Custom widget appended at the end of the stream header timer row.
  final StreamHeaderTimerTrailingWidgetBuilder?
      streamHeaderTimerTrailingWidgetBuilder;

  /// Custom widget replacing the timer row and description / PK banner.
  final StreamHeaderInfoSectionBuilder? streamHeaderInfoSectionBuilder;

  /// When `true`, the send action is shown inside [IsmLiveInputField] as a
  /// suffix icon (visible only when the field has text). When `false`, it is
  /// shown as a separate button next to the input.
  ///
  /// When `null`, defaults to [IsmLiveDelegate.productStream] == `true` for
  /// backward compatibility.
  final bool? messageSendIconInsideInputField;

  /// Custom builder for the message send button (inside or outside the input).
  ///
  /// When `null`, the SDK uses the default send icon / [CustomIconButton].
  final MessageSendButtonBuilder? messageSendButtonBuilder;

  /// Resolves whether the send icon is inside the input field.
  ///
  /// Uses [messageSendIconInsideInputField] when set; otherwise mirrors legacy
  /// [IsmLiveDelegate.productStream] behavior.
  bool resolveMessageSendIconInsideInputField() =>
      messageSendIconInsideInputField ??
      IsmLiveDelegate.productStream == true;
}

/// Configuration class for GoLive screen customization.
///
/// This class provides a centralized way to configure GoLive screen components
/// including header builder, button builder, text styles, icons, and future GoLive-related features.
/// Similar to IsmLiveEcomConfigure, this allows for better organization and
/// extensibility of GoLive screen configuration.
class IsmLiveGoLiveScreenConfigure {
  const IsmLiveGoLiveScreenConfigure({
    this.isHdStreamFeatureEnabled,
    this.isScheduleStreamFeatureEnabled,
    this.isProductStreamFeatureEnabled,
    this.isRtmpStreamFeatureEnabled,
    this.isRestreamStreamFeatureEnabled,
    this.isPaidStreamFeatureEnabled,
    this.isMultiLiveStreamFeatureEnabled,
    this.isRecordedStreamFeatureEnabled,
    this.onGoLiveButtonTap,
    this.onGoLiveViewDispose,
    this.goLiveHeaderBuilder,
    this.goLiveButtonBuilder,
    this.scheduleStreamCenterOverlayBuilder,
    this.onScheduleLiveToggle,
    this.defaultHdBroadcastToggleValue,
    this.defaultRecordBroadcastToggleValue,
    this.defaultRestreamBroadcastToggleValue,
    this.defaultBroadcastDescription,
    this.radioTileTextStyle,
    this.addCoverTextStyle,
    this.addIcon,
    this.tabSelectedTextStyle,
    this.tabUnselectedTextStyle,
    this.titleTextStyle,
  });

  /// Custom header builder for the GoLive screen.
  ///
  /// If provided, this will replace the default header in the GoLive view.
  /// The builder receives the context and stream controller for customization.
  final GoLiveHeaderBuilder? goLiveHeaderBuilder;

  /// Feature flag to show/hide HD stream support in UI.
  final bool? isHdStreamFeatureEnabled;

  /// Feature flag to show/hide schedule stream support in UI.
  final bool? isScheduleStreamFeatureEnabled;

  /// Feature flag to show/hide product stream support in UI.
  final bool? isProductStreamFeatureEnabled;

  /// Feature flag to show/hide RTMP stream support in UI.
  final bool? isRtmpStreamFeatureEnabled;

  /// Feature flag to show/hide restream support in UI.
  final bool? isRestreamStreamFeatureEnabled;

  /// Feature flag to show/hide paid stream support in UI.
  final bool? isPaidStreamFeatureEnabled;

  /// Feature flag to show/hide multi-live support in UI.
  final bool? isMultiLiveStreamFeatureEnabled;

  /// Feature flag to show/hide recorded stream support in UI.
  final bool? isRecordedStreamFeatureEnabled;

  /// Callback for GoLive button click.
  final GoLiveClickCallback? onGoLiveButtonTap;

  /// Callback for GoLive screen dispose.
  final GoLiveDisposeCallback? onGoLiveViewDispose;

  /// Custom button builder for the GoLive screen.
  ///
  /// If provided, this will replace the default GoLive button/navigation bar.
  /// The builder receives context, stream controller, onGoLivePressed callback,
  /// and isEnabled state for proper customization.
  final GoLiveButtonBuilder? goLiveButtonBuilder;

  /// Optional callback invoked when `Schedule Live` toggle value changes.
  final ScheduleLiveToggleCallback? onScheduleLiveToggle;

  /// Custom centered overlay builder for scheduled stream view.
  ///
  /// If provided, this widget is rendered in the center of the scheduled
  /// stream overlay while preserving the SDK's existing layout and controls.
  final ScheduleStreamCenterOverlayBuilder? scheduleStreamCenterOverlayBuilder;

  /// Optional default value for `HD Broadcast` toggle on fresh GoLive flow.
  ///
  /// This is ignored while editing an existing/scheduled stream.
  final bool? defaultHdBroadcastToggleValue;

  /// Optional default value for `Record Broadcast` toggle on fresh GoLive flow.
  ///
  /// This is ignored while editing an existing/scheduled stream.
  final bool? defaultRecordBroadcastToggleValue;

  /// Optional default value for `Restream Broadcast` toggle on fresh GoLive flow.
  ///
  /// This is ignored while editing an existing/scheduled stream.
  final bool? defaultRestreamBroadcastToggleValue;

  /// Optional default text for the stream description on a fresh GoLive flow.
  ///
  /// This is ignored while editing an existing/scheduled stream.
  final String? defaultBroadcastDescription;

  /// Custom text style for radio tile components (switches, toggles).
  ///
  /// If provided, this function will be called to generate text styles for text elements
  /// in IsmLiveRadioListTile and similar radio/toggle components in the GoLive screen.
  /// The function receives the context and isDark parameter to allow theme-aware styling.
  /// If not provided, the default text style will be used.
  final TextStyle Function(BuildContext context, bool isDark)?
      radioTileTextStyle;

  /// Custom text style for "Add cover" and similar action text elements.
  ///
  /// If provided, this will be used for action text elements like "Add cover",
  /// "Add description", and similar interactive text elements in the GoLive screen.
  /// If not provided, the default text style will be used.
  final TextStyle? addCoverTextStyle;

  /// Custom icon for "Add" actions in GoLive screen.
  ///
  /// If provided, this will be used for add action icons like "Add Cover",
  /// "Add products", and similar interactive elements in the GoLive screen.
  /// If not provided, the default Icons.add_circle_outline_rounded will be used.
  final IconData? addIcon;

  /// Custom text style for selected bottom tab label in GoLive screen.
  ///
  /// If provided, this style will be applied to the selected tab text in the
  /// bottom tab selector (e.g., "Go Live", "Live from device").
  final TextStyle? tabSelectedTextStyle;

  /// Custom text style for unselected bottom tab label in GoLive screen.
  ///
  /// If provided, this style will be applied to the unselected tab text in the
  /// bottom tab selector.
  final TextStyle? tabUnselectedTextStyle;

  /// Custom text style for title elements in GoLive screen.
  ///
  /// If provided, this style will be applied to title text elements in the
  /// GoLive screen such as main titles, section headers, and other prominent text.
  /// If not provided, the default text style will be used.
  final TextStyle? titleTextStyle;

  IsmLiveGoLiveScreenConfigure copyWith({
    bool? isHdStreamFeatureEnabled,
    bool? isScheduleStreamFeatureEnabled,
    bool? isProductStreamFeatureEnabled,
    bool? isRtmpStreamFeatureEnabled,
    bool? isRestreamStreamFeatureEnabled,
    bool? isPaidStreamFeatureEnabled,
    bool? isMultiLiveStreamFeatureEnabled,
    bool? isRecordedStreamFeatureEnabled,
    GoLiveClickCallback? onGoLiveButtonTap,
    GoLiveDisposeCallback? onGoLiveViewDispose,
    GoLiveHeaderBuilder? goLiveHeaderBuilder,
    GoLiveButtonBuilder? goLiveButtonBuilder,
    ScheduleStreamCenterOverlayBuilder? scheduleStreamCenterOverlayBuilder,
    ScheduleLiveToggleCallback? onScheduleLiveToggle,
    bool? defaultHdBroadcastToggleValue,
    bool? defaultRecordBroadcastToggleValue,
    bool? defaultRestreamBroadcastToggleValue,
    String? defaultBroadcastDescription,
    TextStyle Function(BuildContext context, bool isDark)? radioTileTextStyle,
    TextStyle? addCoverTextStyle,
    IconData? addIcon,
    TextStyle? tabSelectedTextStyle,
    TextStyle? tabUnselectedTextStyle,
    TextStyle? titleTextStyle,
  }) =>
      IsmLiveGoLiveScreenConfigure(
        isHdStreamFeatureEnabled:
            isHdStreamFeatureEnabled ?? this.isHdStreamFeatureEnabled,
        isScheduleStreamFeatureEnabled: isScheduleStreamFeatureEnabled ??
            this.isScheduleStreamFeatureEnabled,
        isProductStreamFeatureEnabled:
            isProductStreamFeatureEnabled ?? this.isProductStreamFeatureEnabled,
        isRtmpStreamFeatureEnabled:
            isRtmpStreamFeatureEnabled ?? this.isRtmpStreamFeatureEnabled,
        isRestreamStreamFeatureEnabled: isRestreamStreamFeatureEnabled ??
            this.isRestreamStreamFeatureEnabled,
        isPaidStreamFeatureEnabled:
            isPaidStreamFeatureEnabled ?? this.isPaidStreamFeatureEnabled,
        isMultiLiveStreamFeatureEnabled: isMultiLiveStreamFeatureEnabled ??
            this.isMultiLiveStreamFeatureEnabled,
        isRecordedStreamFeatureEnabled: isRecordedStreamFeatureEnabled ??
            this.isRecordedStreamFeatureEnabled,
        onGoLiveButtonTap: onGoLiveButtonTap ?? this.onGoLiveButtonTap,
        onGoLiveViewDispose: onGoLiveViewDispose ?? this.onGoLiveViewDispose,
        goLiveHeaderBuilder: goLiveHeaderBuilder ?? this.goLiveHeaderBuilder,
        goLiveButtonBuilder: goLiveButtonBuilder ?? this.goLiveButtonBuilder,
        scheduleStreamCenterOverlayBuilder:
            scheduleStreamCenterOverlayBuilder ??
                this.scheduleStreamCenterOverlayBuilder,
        onScheduleLiveToggle: onScheduleLiveToggle ?? this.onScheduleLiveToggle,
        defaultHdBroadcastToggleValue:
            defaultHdBroadcastToggleValue ?? this.defaultHdBroadcastToggleValue,
        defaultRecordBroadcastToggleValue: defaultRecordBroadcastToggleValue ??
            this.defaultRecordBroadcastToggleValue,
        defaultRestreamBroadcastToggleValue:
            defaultRestreamBroadcastToggleValue ??
                this.defaultRestreamBroadcastToggleValue,
        defaultBroadcastDescription:
            defaultBroadcastDescription ?? this.defaultBroadcastDescription,
        radioTileTextStyle: radioTileTextStyle ?? this.radioTileTextStyle,
        addCoverTextStyle: addCoverTextStyle ?? this.addCoverTextStyle,
        addIcon: addIcon ?? this.addIcon,
        tabSelectedTextStyle: tabSelectedTextStyle ?? this.tabSelectedTextStyle,
        tabUnselectedTextStyle:
            tabUnselectedTextStyle ?? this.tabUnselectedTextStyle,
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      );
}
