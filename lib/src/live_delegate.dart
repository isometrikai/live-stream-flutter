import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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
