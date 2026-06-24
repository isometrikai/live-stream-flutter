import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveUtility {
  const IsmLiveUtility._();

  static bool _initialized = false;
  static int _bottomSheetCount = 0;

  static Future<void> initialize(IsmLiveConfigData config) async {
    _initialized = true;
    debugPrint(
        'IsmLiveApp: set actual data initialize:  stated ${config.userConfig.userToken}');
    _config ??= config;
  }

  static void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  static IsmLiveConfigData? _config;

  static GlobalKey<NavigatorState>? _navigatorKey;

  static GlobalKey<NavigatorState> get navigatorKey {
    assert(
      _navigatorKey != null,
      'IsmLiveUtility.navigatorKey is not set. Please provide it during IsmLiveApp initialization.',
    );
    return _navigatorKey!;
  }

  static set navigatorKey(GlobalKey<NavigatorState>? key) {
    _navigatorKey = key;
  }

  static bool get hasValidUserToken =>
      _initialized &&
      _config != null &&
      _config!.userConfig.userToken.isNotEmpty;

  static IsmLiveConfigData get config {
    assert(
      _initialized,
      'IsmLiveUtility is not initialized, initialize it using IsmLiveApp.initialize()',
    );
    return _config!;
  }

  static set config(IsmLiveConfigData? configData) {
    _config = configData;
    if (configData == null) {
      _initialized = false;
    }
  }

  static void updateLater(VoidCallback callback, [bool addDelay = true]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
          addDelay ? const Duration(milliseconds: 10) : Duration.zero, () {
        callback();
      });
    });
  }

  /// Waits until [context]'s route is covered by another route, then becomes
  /// current again. Used to refresh stale data after host navigation (e.g.
  /// withdraw) without requiring a [RouteObserver] in the host app.
  static Future<void> waitForRouteResume(
    BuildContext context, {
    Duration coverTimeout = const Duration(seconds: 2),
    Duration resumeTimeout = const Duration(minutes: 10),
  }) async {
    if (!context.mounted) return;
    final route = ModalRoute.of(context);
    if (route == null) return;

    final coverDeadline = DateTime.now().add(coverTimeout);
    while (context.mounted &&
        route.isCurrent &&
        DateTime.now().isBefore(coverDeadline)) {
      await _waitForNextFrame();
    }

    if (!context.mounted || route.isCurrent) return;

    final resumeDeadline = DateTime.now().add(resumeTimeout);
    while (context.mounted &&
        !route.isCurrent &&
        DateTime.now().isBefore(resumeDeadline)) {
      await _waitForNextFrame();
    }
  }

  static Future<void> _waitForNextFrame() async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  /// Warms the disk/memory cache for a stream cover before opening [IsmLiveStreamView].
  static Future<void> precacheStreamCover(
    String? imageUrl,
    BuildContext context, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return;
    }
    try {
      await precacheImage(CachedNetworkImageProvider(url), context).timeout(
        timeout,
        onTimeout: () {},
      );
    } catch (e, st) {
      IsmLiveLog.error('precacheStreamCover failed: $e', st);
    }
  }

  static String jsonEncodePretty(Object? object) =>
      JsonEncoder.withIndent(' ' * 4).convert(object);

  static Map<String, String> newTokenHeader() => {
        'userToken': config.userConfig.userToken,
        'licenseKey': 'lic-IMKm3wNSIeSnxmdj/lOy4mB55sziy2A1NhU',
        'appSecret':
            'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY1MmY5YWQzZTI0NDc3Y2NlNGEwMjVkNW0AAAAIa2V5c2V0SWRtAAAAJGIxN2IzODBkLTE1M2UtNDAxNy04YThmLTI2YjYxZjVjMjNjOG0AAAAJcHJvamVjdElkbQAAACQ4OGNhZDQ1OC1lOWEwLTQxMDktYTJkNi1kZjUyMGU1NmI0ZjdkAAZzaWduZWRuBgAyh_ZBiwE.u0RqujyPa8EB036aYWH50kME2sMLgjC7faUtYTJxHFM',
        'Content-Type': 'application/json',
      };

  static Map<String, String> tokenHeader() => {
        'userToken': config.userConfig.userToken,
        'licenseKey': config.projectConfig.licenseKey,
        'appSecret': config.projectConfig.appSecret,
        'Content-Type': 'application/json',
      };

  /// Updates the in-memory `userToken` used by the SDK for subsequent API calls.
  ///
  /// This is intentionally a shallow config rebuild because [IsmLiveUserConfig]
  /// is immutable.
  static void updateUserToken(String token) {
    final t = token.trim();
    if (t.isEmpty) return;
    if (!_initialized || _config == null) return;

    final current = _config!;
    final uc = current.userConfig;

    if (uc.userToken == t) return;

    _config = IsmLiveConfigData(
      userConfig: IsmLiveUserConfig(
        userToken: t,
        userId: uc.userId,
        firstName: uc.firstName,
        lastName: uc.lastName,
        userEmail: uc.userEmail,
        userProfile: uc.userProfile,
      ),
      projectConfig: current.projectConfig,
      mqttConfig: current.mqttConfig,
      socketConfig: current.socketConfig,
      secure: current.secure,
      username: current.username,
      password: current.password,
    );
  }

  static Map<String, String> secretHeader() => {
        'Content-Type': 'application/json',
        'userSecret': config.projectConfig.userSecret,
        'licenseKey': config.projectConfig.licenseKey,
        'appSecret': config.projectConfig.appSecret,
      };

  /// Returns true if the internet connection is available.
  static Future<bool> get isNetworkAvailable async {
    final result = await Connectivity().checkConnectivity();

    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
  }

  /// Opens a custom bottom sheet with the provided parameters.
  /// If a custom bottom sheet builder is configured, it will be used;
  /// otherwise, the default IsmLiveCustomButtomSheet will be used.
  static Future<T?> openCustomBottomSheet<T>({
    required String title,
    required String leftLabel,
    required String rightLabel,
    VoidCallback? onLeft,
    VoidCallback? onRight,
    bool isDismissible = true,
    bool? ignoreSafeArea,
    bool enableDrag = true,
    bool isScrollController = false,
    Color? backgroundColor,
  }) async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;

    // Check if custom bottom sheet builder is provided
    final customBuilder = IsmLiveDelegate.customBottomSheetBuilder;
    Widget bottomSheetWidget;

    if (customBuilder != null) {
      bottomSheetWidget = customBuilder(
        context,
        title,
        leftLabel,
        rightLabel,
        onLeft,
        onRight,
      );
    } else {
      // Use default bottom sheet
      bottomSheetWidget = IsmLiveCustomButtomSheet(
        title: title,
        leftLabel: leftLabel,
        rightLabel: rightLabel,
        onLeft: onLeft,
        onRight: onRight,
      );
    }

    return await openBottomSheet<T>(
      bottomSheetWidget,
      isDismissible: isDismissible,
      ignoreSafeArea: ignoreSafeArea,
      enableDrag: enableDrag,
      isScrollController: isScrollController,
      backgroundColor: backgroundColor,
    );
  }

  static Future<T?> openBottomSheet<T>(
    Widget child, {
    bool isDismissible = true,
    bool? ignoreSafeArea,
    bool enableDrag = true,
    bool isScrollController = false,
    Color? backgroundColor,
  }) async {
    hideKeyboard();
    if (Get.isRegistered<IsmLiveStreamController>()) {
      Get.find<IsmLiveStreamController>().showEmojiBoard = false;
    }

    _bottomSheetCount++;

    try {
      final result = await showModalBottomSheet<T>(
        context: IsmLiveUtility.navigatorKey.currentContext!,
        isDismissible: isDismissible,
        isScrollControlled: isScrollController,
        enableDrag: enableDrag,
        // Bottom nav clearance is applied inside sheet widgets via
        // [ismLiveBottomSheetBottomInset] / [ismLiveBottomSheetNavClearance].
        useSafeArea: ignoreSafeArea != true,
        backgroundColor: backgroundColor ?? IsmLiveColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: IsmLiveDelegate.bottomSheetBorderRadius ??
              BorderRadius.vertical(
                top: Radius.circular(IsmLiveDimens.thirty),
              ),
        ),
        builder: (context) => child,
      );

      _bottomSheetCount--;

      // On Android, dismissing a modal bottom sheet restores focus to the
      // previously-focused widget (e.g. the message text field) because the
      // underlying FocusScopeNode remembers its last focused child. This
      // causes the soft keyboard to reopen unexpectedly. A post-frame
      // callback catches the restored focus after the route pop completes.
      if (_bottomSheetCount == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<IsmLiveStreamController>()) {
            final controller = Get.find<IsmLiveStreamController>();
            if (controller.messageFocusNode.hasFocus) {
              controller.messageFocusNode.unfocus();
            }
          }
        });
      }

      return result;
    } catch (e) {
      _bottomSheetCount--;
      rethrow;
    }
  }

  /// Returns true if a modal bottom sheet (from showModalBottomSheet or Get.bottomSheet) is currently the top route.
  static bool get isAnyBottomSheetOpen => _bottomSheetCount > 0;

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
    hideKeyboard();
    showDialog(
      context: IsmLiveUtility.navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => IsmLiveLoader(message: message),
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
    hideKeyboard();
    await showCupertinoDialog(
      context: IsmLiveUtility.navigatorKey.currentContext!,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title ?? (isSuccess ? 'Success' : 'Error'),
        ),
        content: Text(
          _getErrorMessage(data.data),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: IsmLiveRoute.pop,
            isDefaultAction: true,
            child: const Text('Okay'),
          ),
          if (onRetry != null)
            CupertinoDialogAction(
              onPressed: () {
                IsmLiveRoute.pop();
                onRetry();
              },
              isDefaultAction: true,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Show info dialog
  static void showCustomDialog(
    Widget dialog, {
    bool isDismissible = true,
    double? horizontalPadding,
  }) {
    hideKeyboard();

    Future<void> run() async {
      var ctx = IsmLiveUtility.navigatorKey.currentContext;
      if (ctx == null) {
        await WidgetsBinding.instance.endOfFrame;
        ctx = IsmLiveUtility.navigatorKey.currentContext;
      }
      if (ctx == null || !ctx.mounted) {
        IsmLiveLog.error(
          'IsmLiveUtility.showCustomDialog: navigator context unavailable; dialog not shown.',
        );
        return;
      }

      await showDialog<void>(
        context: ctx,
        barrierDismissible: isDismissible,
        builder: (context) => UnconstrainedBox(
          child: SizedBox(
            width: IsmLiveDimens.percentWidth(1) -
                (horizontalPadding ?? IsmLiveDimens.sixteen) * 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.liveTheme?.backgroundColor ??
                    Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(IsmLiveDimens.twentyFour),
              ),
              child: Padding(
                padding: IsmLiveDimens.edgeInsets16,
                child: dialog,
              ),
            ),
          ),
        ),
      );
    }

    run();
  }

  /// Show alert dialog
  static void showAlertDialog({
    String? message,
    String? title,
    Function()? onPress,
  }) async {
    hideKeyboard();
    await showCupertinoDialog(
      context: IsmLiveUtility.navigatorKey.currentContext!,
      builder: (context) => CupertinoAlertDialog(
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
    // Check if we can pop before attempting to pop
    if (IsmLiveRoute.canPop()) {
      IsmLiveRoute.pop<void>();
    }
  }

  /// Close the top dialog (if any), then pop the route below it — e.g. dismiss
  /// the screen that presented the dialog. The extra pop runs after layout so the
  /// navigator stack reflects the dialog removal first.
  static void closeDialogAndPopUnderlyingRoute() {
    closeDialog();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (IsmLiveRoute.canPop()) {
        IsmLiveRoute.pop<void>();
      }
    });
  }

  /// Used after a scheduled-stream edit success dialog: dismiss dialog, pop the
  /// go-live screen, then wake the SDK listing to consume the pending refresh.
  static void closeEditScheduleDialogAndReturn() {
    closeDialogAndPopUnderlyingRoute();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        IsmLiveStreamListing.notifyPendingRefresh();
      });
    });
  }

  /// Check if a dialog is currently open by checking the Navigator's top route
  ///
  /// This method checks if there's a DialogRoute or CupertinoDialogRoute
  /// on top of the Navigator stack. When a dialog is shown, it becomes the
  /// top route, so we check if there's a route on top.
  static bool get isDialogOpen {
    try {
      final navigatorState = IsmLiveUtility.navigatorKey.currentState;
      if (navigatorState == null) return false;

      final context = IsmLiveUtility.navigatorKey.currentContext;
      if (context == null) return false;

      // Check if there's a route that can be popped (indicates a route on top)
      if (!navigatorState.canPop()) return false;

      // When a dialog is shown (via showDialog or showCupertinoDialog),
      // it becomes the top route on the Navigator stack.
      // ModalRoute.of(context) returns the route containing the context,
      // which is the underlying screen, not the dialog route.
      //
      // If ModalRoute.of(context) returns null, it means the context
      // doesn't have a route associated with it, but that doesn't mean
      // there's no dialog - it just means we can't check via this method.
      // In this case, if canPop() is true, there's a route on top.
      final currentRoute = ModalRoute.of(context);

      // If currentRoute is null, check if there's a route on top via canPop
      // This handles cases where the context doesn't have a route
      if (currentRoute == null) {
        // If we can pop, there's a route on top (likely a dialog if opened via showDialog/showCupertinoDialog)
        return navigatorState.canPop();
      }

      // If currentRoute.isCurrent is false, there's a route on top
      // This indicates a modal (like a dialog) is displayed
      if (!currentRoute.isCurrent) {
        // There's a route on top - if it was opened via showDialog/showCupertinoDialog, it's a dialog
        return true;
      }

      // If currentRoute.isCurrent is true, check if it's itself a DialogRoute
      // This handles edge cases where the dialog context might be passed directly
      return currentRoute is DialogRoute ||
          currentRoute is CupertinoDialogRoute;
    } catch (e) {
      return false;
    }
  }

  /// Close dialog only if one is currently open
  static void closeDialogIfOpen() {
    if (isDialogOpen) {
      closeDialog();
    }
  }

  static void popUntilStreamView() {
    try {
      IsmLiveUtility.navigatorKey.currentState?.popUntil(
        (route) => route.settings.name == IsmLiveStreamView.route,
      );
    } catch (e) {
      IsmLiveLog.error('Error in popUntilStreamView: $e');
    }
  }

  /// Close any open snackbar
  static void closeSnackbar() {
    // Snackbars don't use routes, use ScaffoldMessenger instead
    try {
      final context = IsmLiveUtility.navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      // Ignore errors when hiding snackbar
    }
  }

  /// Safely extract error message from response data
  static String _getErrorMessage(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic> && decoded.containsKey('error')) {
        return decoded['error'] as String;
      }
      return data; // Return raw data if no error field found
    } catch (e) {
      // If JSON parsing fails, return the raw data
      return data;
    }
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
    bool closeDialogs = false,
  }) {
    if (message == null || message.isEmpty) return;

    // Only close dialogs if explicitly requested (to avoid closing screens)
    if (closeDialogs) {
      try {
        closeDialog();
      } catch (e) {
        // Ignore errors when closing dialog
      }
    }

    // Hide any existing snackbar (safely - uses ScaffoldMessenger)
    try {
      closeSnackbar();
    } catch (e) {
      // Ignore errors when hiding snackbar
    }

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
    }
    Future.delayed(
      const Duration(seconds: 0),
      () {
        ScaffoldMessenger.of(IsmLiveUtility.navigatorKey.currentContext!)
            .showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: IsmLiveStyles.white16,
            ),
            backgroundColor: backgroundColor,
            action: actionName != null
                ? SnackBarAction(
                    label: actionName,
                    onPressed: onTap ?? IsmLiveRoute.pop,
                    textColor: Colors.white,
                  )
                : null,
            behavior: SnackBarBehavior.floating,
            margin: IsmLiveDimens.edgeInsets10,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(IsmLiveDimens.ten + IsmLiveDimens.five),
            ),
          ),
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
  static Future<List<CameraDescription>>? camerasInitializationFuture;

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

/// Centralized navigation utility for IsmLive, using the host app's navigatorKey for all navigation.
class IsmLiveRoute {
  IsmLiveRoute._();

  /// Push a widget onto the navigation stack.
  static Future<T?> push<T>(Widget child) async =>
      await IsmLiveUtility.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (BuildContext context) => child,
        ),
      );

  /// Push a named route onto the navigation stack.
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) async =>
      await IsmLiveUtility.navigatorKey.currentState?.pushNamed<T>(
        routeName,
        arguments: arguments,
      );

  /// Replace the current route by pushing a widget and removing the previous one.
  static Future<T?> pushReplacement<T, TO>(Widget child, {TO? result}) async =>
      await IsmLiveUtility.navigatorKey.currentState?.pushReplacement<T, TO>(
        MaterialPageRoute(
          builder: (BuildContext context) => child,
        ),
        result: result,
      );

  /// Snappy transition duration (250ms) for smoother open/close than Material 300ms.
  static const Duration _snappyTransitionDuration = Duration(milliseconds: 250);

  /// Builds a slide-from-right route with snappy duration and easeOutCubic curve.
  /// [routeName] is used for [RouteSettings.name] so [popUntil] can match this route.
  static PageRouteBuilder<T> _snappySlideRoute<T>(Widget child,
          {String? routeName}) =>
      PageRouteBuilder<T>(
        settings: routeName != null ? RouteSettings(name: routeName) : null,
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: _snappyTransitionDuration,
        reverseTransitionDuration: _snappyTransitionDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );

  /// Push with snappier transition for smoother open/close (stream view, go-live view, etc.).
  /// [routeName] sets [RouteSettings.name] so [popUntil] can stop at this route.
  static Future<T?> pushWithTransition<T>(Widget child,
          {String? routeName}) async =>
      await IsmLiveUtility.navigatorKey.currentState?.push<T>(
        _snappySlideRoute<T>(child, routeName: routeName),
      );

  /// Replace with snappier transition for smoother open/close.
  static Future<T?> pushReplacementWithTransition<T, TO>(Widget child,
          {TO? result, String? routeName}) async =>
      await IsmLiveUtility.navigatorKey.currentState?.pushReplacement<T, TO>(
        _snappySlideRoute<T>(child, routeName: routeName),
        result: result,
      );

  /// Push the stream view with a snappier transition for smoother open/close.
  /// Uses [IsmLiveStreamView.route] so [popUntil] (e.g. [popUntilStreamView]) can stop at it.
  static Future<T?> pushStreamView<T>(Widget child) async =>
      pushWithTransition<T>(child, routeName: IsmLiveStreamView.route);

  /// Replace with stream view using the same snappier transition.
  static Future<T?> pushReplacementStreamView<T, TO>(Widget child,
          {TO? result}) async =>
      pushReplacementWithTransition<T, TO>(child,
          result: result, routeName: IsmLiveStreamView.route);

  /// Replace the current route by pushing a named route and removing the previous one.
  static Future<T?> pushReplacementNamed<T, TO>(String routeName,
          {TO? result, Object? arguments}) async =>
      await IsmLiveUtility.navigatorKey.currentState
          ?.pushReplacementNamed<T, TO>(
        routeName,
        result: result,
        arguments: arguments,
      );

  /// Pop the top-most route off the navigation stack.
  static void pop<T>([T? result]) {
    final nav = IsmLiveUtility.navigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop(result);
    }
  }

  /// Maybe pop the top-most route if possible.
  static Future<bool> maybePop<T>([T? result]) async =>
      await IsmLiveUtility.navigatorKey.currentState?.maybePop(result) ?? false;

  /// Check if the navigator can pop.
  static bool canPop() =>
      IsmLiveUtility.navigatorKey.currentState?.canPop() ?? false;
}
