import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveUtility {
  const IsmLiveUtility._();

  static void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  static Map<String, String> commonHeader(
          {required String token,
          required String licenseKey,
          required String appSecret}) =>
      {
        'userToken': token,
        'licenseKey': licenseKey,
        'appSecret': appSecret,
      };
  static Map<String, String> header(
          {required String userSecret,
          required String licenseKey,
          required String appSecret}) =>
      {
        'userSecret': userSecret,
        'licenseKey': licenseKey,
        'appSecret': appSecret,
      };

  /// Returns true if the internet connection is available.
  static Future<bool> get isNetworkAvailable async {
    final result = await Connectivity().checkConnectivity();
    return [
      ConnectivityResult.mobile,
      ConnectivityResult.wifi,
      ConnectivityResult.ethernet
    ].contains(result);
  }

  static Future<T?> openBottomSheet<T>(
    Widget child, {
    Color? backgroundColor,
    bool isDismissible = true,
    ShapeBorder? shape,
  }) async =>
      await Get.bottomSheet<T>(
        child,
        barrierColor: Colors.black.withOpacity(0.7),
        backgroundColor: backgroundColor,
        isDismissible: isDismissible,
        shape: shape,
        isScrollControlled: true,
      );

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
  static void showLoader() async {
    await Get.dialog(
      const IsmLiveLoader(),
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
    String message,
  ) async {
    await Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Info'),
        content: Text(
          message,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: Get.back,
            child: const Text('Okay'),
          ),
        ],
      ),
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
    IsmLiveMessageType type = IsmLiveMessageType.information,
    Function()? onTap,
    String? actionName,
  }) {
    if (message == null || message.isEmpty) return;
    closeDialog();
    closeSnackbar();
    var backgroundColor = Colors.black;
    switch (type) {
      case IsmLiveMessageType.error:
        backgroundColor = Colors.red;
        break;
      case IsmLiveMessageType.information:
        backgroundColor = Colors.blue;
        break;
      case IsmLiveMessageType.success:
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
}
