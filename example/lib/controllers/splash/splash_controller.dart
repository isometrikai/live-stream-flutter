import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(const Locale('en', 'IN'));
    });
    startOnInit();
  }

  var isLoggedIn = false;

  void startOnInit() async {
    await Future.delayed(const Duration(seconds: 3));
    if (isLoggedIn) {
      RouteManagement.goToHome();
    } else {
      RouteManagement.goToLogin();
    }
  }
}
