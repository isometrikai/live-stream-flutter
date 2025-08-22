import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:appscrip_live_stream_component/src/models/stream/analytis_viewer_model.dart';
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
/// [streamId] - The current stream ID.
/// [isHost] - Whether the current user is the host of the stream.
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
  String streamId,
  bool isHost,
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

  static IsmLiveEcomConfigure? ecomConfigure;

  static bool enableFreeGift = false;

  static bool restrictProfileSheetOnProfileClick = false;

  static String? fontFamily;

  static MessageProcessCallback? messageProcessCallback;

  static StreamViewLoadedCallback? streamViewLoadedCallback;

  static HeartMessageCallback? heartMessageCallback;

  static StreamAnalyticsCallback? streamAnalyticsCallback;

  static StreamAnalyticsViewersCallback? streamAnalyticsViewersCallback;

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

  static Future<void> endStream({required BuildContext context}) async {
    assert(Get.isRegistered<IsmLiveStreamController>(),
        'StreamController is not initialized');
    IsmLiveLog.error('Calling Leave API from Outside');
    var controller = Get.find<IsmLiveStreamController>();
    if (controller.streamId.isNullOrEmpty) {
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
    this.onGoLiveClick,
    this.onGoLiveDispose,
    this.onProductAction,
    this.pinnedProductBuilder,
    this.hasPinnedProductGetter,
  });

  final AddProductViewBuilder? addProductViewBuilder;
  final GoLiveClickCallback? onGoLiveClick;
  final GoLiveDisposeCallback? onGoLiveDispose;
  final ProductActionCallback? onProductAction;
  final Widget? Function(
          BuildContext context, IsmLiveStreamController controller)?
      pinnedProductBuilder;
  final bool Function()? hasPinnedProductGetter;

  /// Gets the current pinned product status dynamically
  bool get hasPinnedProduct => hasPinnedProductGetter?.call() ?? false;
}
