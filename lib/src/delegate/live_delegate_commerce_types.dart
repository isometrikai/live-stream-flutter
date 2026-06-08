part of '../live_delegate.dart';

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