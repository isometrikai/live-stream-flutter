import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// For e-commerce related delegates, see IsmLiveECommerceDelegate.

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

/// Callback for Pin Product button click.
///
/// [context] - The BuildContext from the SDK UI.
/// [streamId] - The current stream ID.
/// [hasPinnedProduct] - Whether there is currently a product pinned.
/// [buttonLabel] - The label of the button that was tapped.
/// [isHost] - Whether the current user is the host of the stream.
///
/// This callback is called when the Product Action button is tapped in the stream view.
/// Useful for handling product pinning/buying functionality in the host application.
typedef ProductActionCallback = void Function(
  BuildContext context,
  String streamId,
  bool hasPinnedProduct,
  String buttonLabel,
  bool isHost,
);

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

/// Callback for heart message sending.
///
/// This callback is called when a user sends a heart message to the stream.
/// Host applications can use this to implement their own heart message API
/// or analytics tracking.
///
/// [streamId] - The current stream ID.
/// [userId] - The ID of the user sending the heart.
/// [userName] - The name of the user sending the heart.
/// [userImage] - The profile image URL of the user sending the heart.
/// [deviceId] - The device ID of the user.
/// [customType] - The custom type of the heart message (default: 'like').
///
/// Return true if the heart message was successfully processed by the host app,
/// false if the host app wants the SDK to handle it with the default implementation.
///
/// This callback is called before the SDK's default heart message handling.
/// Useful for implementing:
/// - Custom heart message APIs
/// - Analytics tracking
/// - User engagement metrics
/// - Custom heart message processing
/// - Integration with external services
/// - Custom heart message validation
typedef HeartMessageCallback = Future<bool> Function(
  String streamId,
  String userId,
  String userName,
  String userImage,
  String deviceId,
  String customType,
);

/// Callback for stream analytics data.
///
/// This callback is called when the SDK needs to fetch stream analytics data.
/// Host applications can use this to implement their own analytics API
/// and return data in the expected format.
///
/// [streamId] - The current stream ID.
/// [isHost] - Whether the current user is the host of the stream.
///
/// Return the analytics data in IsmLiveStreamAnalyticsModel format,
/// or null if the host app wants the SDK to handle it with the default implementation.
///
/// This callback is called before the SDK's default analytics API call.
/// Useful for implementing:
/// - Custom analytics APIs
/// - Real-time analytics integration
/// - Custom analytics processing
/// - Integration with external analytics services
/// - Custom analytics validation
/// - Analytics data transformation
typedef StreamAnalyticsCallback = Future<IsmLiveStreamAnalyticsModel?> Function(
  String streamId,
  bool isHost,
);

/// Callback for stream analytics viewers data.
///
/// This callback is called when the SDK needs to fetch stream analytics viewers data.
/// Host applications can use this to implement their own analytics viewers API
/// and return data in the expected format.
///
/// [streamId] - The current stream ID.
/// [skip] - Number of records to skip for pagination.
/// [limit] - Number of records to return for pagination.
///
/// Return the analytics viewers data as List<IsmLiveAnalyticViewerModel>,
/// or null if the host app wants the SDK to handle it with the default implementation.
///
/// This callback is called before the SDK's default analytics viewers API call.
/// Useful for implementing:
/// - Custom analytics viewers APIs
/// - Real-time viewers data integration
/// - Custom viewers data processing
/// - Integration with external analytics services
/// - Custom viewers data validation
/// - Viewers data transformation
typedef StreamAnalyticsViewersCallback
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

/// Callback for analytics/bars button click event.
///
/// This callback is triggered when the user taps on the analytics/bars button in the stream.
/// Host applications can use this to implement their own analytics screen or custom behavior.
///
/// [context] - The build context where the tap occurred.
/// [streamId] - The current stream ID.
/// [isHost] - Whether the current user is the host of the stream.
/// [isPkGuest] - Whether the current user is a PK guest.
/// [pkGuestStreamId] - The PK guest stream ID (if applicable).
///
/// Return true if the host app handled the click and wants to prevent the default behavior,
/// false if the host app wants the SDK to handle it with the default analytics sheet.
///
/// This callback is called before the SDK's default analytics sheet handling.
/// Useful for implementing:
/// - Custom analytics screens
/// - Custom data visualization
/// - Integration with external analytics services
/// - Custom user engagement tracking
/// - Host-specific analytics features
/// - Custom permission checks
typedef AnalyticsButtonCallback = Future<bool> Function(
  BuildContext context,
  String streamId,
  bool isHost,
  bool isPkGuest,
  String? pkGuestStreamId,
);

/// Callback for handling schedule modify button clicks
/// Allows host apps to customize schedule modification behavior
/// - Custom schedule editing flows
/// - Integration with external scheduling systems
/// - Custom permission checks for schedule modification
/// - Host-specific schedule management features
typedef ScheduleModifyButtonCallback = Future<bool> Function(
  BuildContext context,
  IsmLiveStreamDataModel streamDetails,
  bool isHost,
);

/// Callback for handling share button clicks
/// Allows host apps to customize share behavior
/// - Custom share functionality
/// - Integration with external sharing services
/// - Custom share content generation
/// - Host-specific sharing features
/// - Custom permission checks for sharing
typedef ShareButtonCallback = Future<bool> Function(
  BuildContext context,
  String streamId,
  bool isHost,
);

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

/// Preferred initial camera position when starting a stream
enum IsmLiveCameraPosition {
  front,
  back,
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

  static IsmLiveHeaderBuilder? streamHeader;

  static IsmLiveHeaderBuilder? bottomBuilder;

  static IsmLiveInputBuilder? inputBuilder;

  static IsmLiveCustomBottomSheetBuilder? customBottomSheetBuilder;

  static Widget? endButton;

  static bool showHeader = true;

  static Alignment headerPosition = Alignment.topLeft;

  static Alignment endStreamPosition = Alignment.topRight;

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

  static bool? productStream;

  static bool? rtmpStream;

  static bool? restreamStream;

  static bool? paidStream;

  static bool? multiLiveStream;

  static bool? recordeStream;

  static bool productionMode = false;

  static IsmLiveButtonConfig? ismLiveButtonConfig;

  static LinearGradient? streamOptionsBgGradient;

  static Future<void> Function(String streamId)? onHostStopStream;

  static Future<void> Function(String streamId)? onLeftStreamAsViewer;

  static GoLiveClickCallback? onGoLiveClick;

  static GoLiveDisposeCallback? onGoLiveDispose;

  static IsmLiveEcomConfigure? ecomConfigure;

  static IsmLiveGoLiveScreenConfigure? goLiveScreenConfigure;

  static bool enableFreeGift = false;

  static bool restrictProfileSheetOnProfileClick = false;

  static String? fontFamily;

  static MessageProcessCallback? messageProcessCallback;

  static StreamViewLoadedCallback? streamViewLoadedCallback;

  static HeartMessageCallback? heartMessageCallback;

  static StreamAnalyticsCallback? streamAnalyticsCallback;

  static StreamAnalyticsViewersCallback? streamAnalyticsViewersCallback;

  static HostTopProfileClickCallback? hostTopProfileClickCallback;

  static GoLiveHeaderBuilder? goLiveHeaderBuilder;

  static GoLiveButtonBuilder? goLiveButtonBuilder;

  static GoLiveSmallButtonBuilder? goLiveSmallButtonBuilder;

  static AnalyticsButtonCallback? analyticsButtonCallback;

  static ScheduleModifyButtonCallback? scheduleModifyButtonCallback;

  static ShareButtonCallback? shareButtonCallback;

  static IsmLiveCartBuilder? cartBuilder;

  static TopViewersListCallback? topViewersListCallback;

  static ModeratorsListCallback? moderatorsListCallback;

  static AttentionDialogButtonCallback? attentionDialogButtonCallback;

  static BorderRadius? bottomSheetBorderRadius;

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
      IsmLiveUtility.initialize(config),
    ]);
    IsmLiveLog.info('IsmLiveApp : configDetails data set Successfully');
  }

  static Future<void> endStream(
      {required BuildContext context, bool isSchedule = false}) async {
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
    controller.onExit(
      isHost: controller.isHost,
      streamId: controller.streamId!,
      context: context,
    );
  }
}

class IsmLiveEcomConfigure {
  IsmLiveEcomConfigure({
    this.addProductViewBuilder,
    this.onProductAction,
    this.pinnedProductBuilder,
    this.hasPinnedProductGetter,
    this.buyNowButtonBuilder,
    this.hostArrowButtonsHeight,
  });

  final AddProductViewBuilder? addProductViewBuilder;
  final ProductActionCallback? onProductAction;
  final Widget? Function(
          BuildContext context, IsmLiveStreamController controller)?
      pinnedProductBuilder;
  final bool Function()? hasPinnedProductGetter;
  final BuyNowButtonBuilder? buyNowButtonBuilder;
  final double? hostArrowButtonsHeight;

  /// Gets the current pinned product status dynamically
  bool get hasPinnedProduct => hasPinnedProductGetter?.call() ?? false;
}

/// Configuration class for GoLive screen customization.
///
/// This class provides a centralized way to configure GoLive screen components
/// including header builder, button builder, text styles, icons, and future GoLive-related features.
/// Similar to IsmLiveEcomConfigure, this allows for better organization and
/// extensibility of GoLive screen configuration.
class IsmLiveGoLiveScreenConfigure {
  IsmLiveGoLiveScreenConfigure({
    this.goLiveHeaderBuilder,
    this.goLiveButtonBuilder,
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

  /// Custom button builder for the GoLive screen.
  ///
  /// If provided, this will replace the default GoLive button/navigation bar.
  /// The builder receives context, stream controller, onGoLivePressed callback,
  /// and isEnabled state for proper customization.
  final GoLiveButtonBuilder? goLiveButtonBuilder;

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
}
