import 'package:appscrip_live_stream_component_example/utils/navigators/app_pages.dart';
import 'package:flutter/widgets.dart'; // Added for BuildContext

abstract class RouteManagement {
  /// Go to the SignIn Screen
  static void goToLogin(BuildContext context, [bool fromSignup = false]) {
    if (fromSignup) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  static void goToSignUp(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.signup);
  }

  /// Go to the Home Screen
  static void goToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }
}
