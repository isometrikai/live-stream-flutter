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
    required this.selectedProductsList,
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
  final List<IsmLiveProductModel> selectedProductsList;
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

  /// Callback for GoLive button click.
  /// If set, this callback will be called when the GoLive button is tapped.
  /// If not set, the default behavior will be used.
  static GoLiveClickCallback? onGoLiveClick;

  // ================= E-Commerce Delegates =================
  /// If set, this builder will be used for the Add Product view in go_live_view.dart.
  static AddProductViewBuilder? addProductViewBuilder;
  // Optionally deprecate or remove productSelectionCallback if you want to encourage full view replacement.
  // static ProductSelectionCallback? productSelectionCallback;
  // ========================================================

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
