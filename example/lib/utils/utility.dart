import 'package:appscrip_live_stream_component_example/res/constants/app_constants.dart';
import 'package:flutter/widgets.dart';

class Utility {
  const Utility._();

  static void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  /// Token common Header for All api
  static Map<String, String> secretHeader() => {
        'Content-Type': 'application/json',
        'userSecret': AppConstants.userSecret,
        'licenseKey': AppConstants.licenseKey,
        'appSecret': AppConstants.appSecret,
      };
}
