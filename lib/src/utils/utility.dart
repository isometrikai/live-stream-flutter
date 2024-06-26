import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveUtility {
  const IsmLiveUtility._();

  static bool _initialized = false;

  static Future<void> initialize(IsmLiveConfigData config) async {
    _initialized = true;
    _config ??= config;
  }

  static void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  static IsmLiveConfigData? _config;

  static IsmLiveConfigData get config {
    assert(
      _initialized,
      'IsmLiveUtility is not initialized, initialize it using IsmLiveApp.initialize()',
    );
    return _config!;
  }

  static void updateLater(VoidCallback callback, [bool addDelay = true]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(addDelay ? const Duration(milliseconds: 10) : Duration.zero, () {
        callback();
      });
    });
  }

  static String jsonEncodePretty(Object? object) => JsonEncoder.withIndent(' ' * 4).convert(object);

  static Map<String, String> tokenHeader() => {
        'userToken': config.userConfig.userToken,
        'licenseKey': config.projectConfig.licenseKey,
        'appSecret': config.projectConfig.appSecret,
        'Content-Type': 'application/json',
      };

  static Map<String, String> secretHeader() => {
        'Content-Type': 'application/json',
        'userSecret': config.projectConfig.userSecret,
        'licenseKey': config.projectConfig.licenseKey,
        'appSecret': config.projectConfig.appSecret,
      };

  /// Returns true if the internet connection is available.
  static Future<bool> get isNetworkAvailable async {
    final result = await Connectivity().checkConnectivity();
    return result.any((e) => [
          ConnectivityResult.mobile,
          ConnectivityResult.wifi,
          ConnectivityResult.ethernet,
        ].contains(e));
  }

  static Future<T?> openBottomSheet<T>(
    Widget child, {
    bool isDismissible = true,
    bool? ignoreSafeArea,
    bool enableDrag = true,
    bool isScrollController = false,
    Color? backgroundColor,
  }) async {
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().showEmojiBoard = false;
    }
    return await Get.bottomSheet<T>(
      SafeArea(child: child),
      isDismissible: isDismissible,
      isScrollControlled: isScrollController,
      ignoreSafeArea: ignoreSafeArea,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? IsmLiveColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(IsmLiveDimens.thirty),
        ),
      ),
    );
  }

  static Future<TimeOfDay> pickTime({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) async =>
      (await showTimePicker(
        context: context,
        initialTime: initialTime,
        initialEntryMode: TimePickerEntryMode.inputOnly,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      )) ??
      initialTime;

  /// Show loader
  static void showLoader([String? message]) async {
    await Get.dialog(
      IsmLiveLoader(message: message),
      barrierDismissible: false,
    );
  }

  /// Close loader
  static void closeLoader() {
    closeDialog();
  }

  /// Show error dialog from response model
  static Future<void> showInfoDialog(
    IsmLiveResponseModel data, {
    bool isSuccess = false,
    String? title,
    VoidCallback? onRetry,
  }) async {
    await Get.dialog(
      CupertinoAlertDialog(
        title: Text(
          title ?? (isSuccess ? 'Success' : 'Error'),
        ),
        content: Text(
          jsonDecode(data.data)['error'] as String,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: Get.back,
            isDefaultAction: true,
            child: Text(
              'Okay',
              style: IsmLiveStyles.black16,
              // style: IsmLiveStyles.black16.copyWith(color: ColorsValue.primary),
            ),
          ),
          if (onRetry != null)
            CupertinoDialogAction(
              onPressed: () {
                Get.back();
                onRetry();
              },
              isDefaultAction: true,
              child: Text(
                'Retry',
                style: IsmLiveStyles.black16,
                // style:
                //     IsmLiveStyles.black16.copyWith(color: ColorsValue.primary),
              ),
            ),
        ],
      ),
    );
  }

  /// Show info dialog
  static void showDialog(
    Widget dialog, {
    bool isDismissible = true,
    double? horizontalPadding,
  }) async {
    await Get.dialog(
      UnconstrainedBox(
        child: SizedBox(
          width: IsmLiveDimens.percentWidth(1) - (horizontalPadding ?? IsmLiveDimens.sixteen) * 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Get.context?.liveTheme?.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(IsmLiveDimens.twentyFour),
            ),
            child: Padding(
              padding: IsmLiveDimens.edgeInsets16,
              child: dialog,
            ),
          ),
        ),
      ),
      barrierDismissible: isDismissible,
      useSafeArea: true,
    );
  }

  /// Show alert dialog
  static void showAlertDialog({
    String? message,
    String? title,
    Function()? onPress,
  }) async {
    await Get.dialog(
      CupertinoAlertDialog(
        title: Text('$title'),
        content: Text('$message'),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: onPress,
            child: Text('yes'.tr),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: closeDialog,
            child: Text('no'.tr),
          )
        ],
      ),
    );
  }

  /// Close any open dialog.
  static void closeDialog() {
    if (Get.isDialogOpen ?? false) Get.back<void>();
  }

  /// Close any open snackbar
  static void closeSnackbar() {
    if (Get.isSnackbarOpen) Get.back<void>();
  }

  /// Show a message to the user.
  ///
  /// [message] : Message you need to show to the user.
  /// [type] : Type of the message for different background color.
  /// [onTap] : An event for onTap.
  /// [actionName] : The name for the action.

  static void showMessage({
    String? message,
    IsmLiveSnackbarType type = IsmLiveSnackbarType.information,
    Function()? onTap,
    String? actionName,
  }) {
    if (message == null || message.isEmpty) return;
    closeDialog();
    closeSnackbar();
    var backgroundColor = Colors.black;
    switch (type) {
      case IsmLiveSnackbarType.error:
        backgroundColor = Colors.red;
        break;
      case IsmLiveSnackbarType.information:
        backgroundColor = Colors.blue;
        break;
      case IsmLiveSnackbarType.success:
        backgroundColor = Colors.green;
        break;
      default:
        backgroundColor = Colors.black;
        break;
    }
    Future.delayed(
      const Duration(seconds: 0),
      () {
        Get.rawSnackbar(
          messageText: Text(
            message,
            style: IsmLiveStyles.white16,
          ),
          mainButton: actionName != null
              ? TextButton(
                  onPressed: onTap ?? Get.back,
                  child: Text(
                    actionName,
                    style: IsmLiveStyles.white16,
                  ),
                )
              : null,
          backgroundColor: backgroundColor,
          margin: IsmLiveDimens.edgeInsets10,
          borderRadius: IsmLiveDimens.ten + IsmLiveDimens.five,
          snackStyle: SnackStyle.FLOATING,
        );
      },
    );
  }

  static String twoDigits(int n) => n.toString().padLeft(2, '0');

  /// Method For Convert Duration To String
  static String durationToString({required Duration duration}) {
    var twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    var twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    var hour = num.parse(twoDigits(duration.inHours));
    if (hour > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  static List<CameraDescription> cameras = [];

  /// Image Type List For Every Platform
  static List<String> imageTypeList = [
    'ase',
    'art',
    'bmp',
    'blp',
    'cd5',
    'cit',
    'cpt',
    'cr2',
    'cut',
    'dds',
    'dib',
    'djvu',
    'egt',
    'exif',
    'gif',
    'gpl',
    'grf',
    'icns',
    'ico',
    'iff',
    'jng',
    'jpeg',
    'jpg',
    'jfif',
    'jp2',
    'jps',
    'lbm',
    'max',
    'miff',
    'mng',
    'msp',
    'nitf',
    'ota',
    'pbm',
    'pc1',
    'pc2',
    'pc3',
    'pcf',
    'pcx',
    'pdn',
    'pgm',
    'PI1',
    'PI2',
    'PI3',
    'pict',
    'pct',
    'pnm',
    'pns',
    'ppm',
    'psb',
    'psd',
    'pdd',
    'psp',
    'px',
    'pxm',
    'pxr',
    'qfx',
    'raw',
    'rle',
    'sct',
    'sgi',
    'rgb',
    'int',
    'bw',
    'tga',
    'tiff',
    'tif',
    'vtf',
    'xbm',
    'xcf',
    'xpm',
    '3dv',
    'amf',
    'ai',
    'awg',
    'cgm',
    'cdr',
    'cmx',
    'dxf',
    'e2d',
    'egt',
    'eps',
    'fs',
    'gbr',
    'odg',
    'svg',
    'stl',
    'vrml',
    'x3d',
    'sxd',
    'v2d',
    'vnd',
    'wmf',
    'emf',
    'art',
    'xar',
    'png',
    'webp',
    'jxr',
    'hdp',
    'wdp',
    'cur',
    'ecw',
    'iff',
    'lbm',
    'liff',
    'nrrd',
    'pam',
    'pcx',
    'pgf',
    'sgi',
    'rgb',
    'rgba',
    'bw',
    'int',
    'inta',
    'sid',
    'ras',
    'sun',
    'tga'
  ];

  /// Video Type List For Every Platform
  static List<String> videoTypeList = [
    'webm',
    'mkv',
    'flv',
    'vob',
    'ogv',
    'ogg',
    'rrc',
    'gifv',
    'mng',
    'mov',
    'avi',
    'qt',
    'wmv',
    'yuv',
    'rm',
    'asf',
    'amv',
    'mp4',
    'm4p',
    'm4v',
    'mpg',
    'mp2',
    'mpeg',
    'mpe',
    'mpv',
    'm4v',
    'svi',
    '3gp',
    '3g2',
    'mxf',
    'roq',
    'nsv',
    'flv',
    'f4v',
    'f4p',
    'f4a',
    'f4b',
    'mod',
    'hevc'
  ];

  /// this is for change decode string to encode string
  static String encodeString(String value) => utf8.fuse(base64).encode(value);

  /// this is for change encoded string to decode string
  static String decodeString(String value) {
    try {
      return utf8.fuse(base64).decode(value);
    } catch (e) {
      return value;
    }
  }
}
