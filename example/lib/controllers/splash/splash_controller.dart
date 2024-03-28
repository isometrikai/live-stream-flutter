import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  DBWrapper get dbWrapper => Get.find<DBWrapper>();

  @override
  void onInit() {
    super.onInit();
    IsmLiveUtility.updateLater(() {
      Get.updateLocale(const Locale('en', 'IN'));
    });
    startOnInit();
  }

  var isLoggedIn = false;

  void startOnInit() async {
    isLoggedIn = dbWrapper.getBoolValue(LocalKeys.isLoggedIn);
    late Function route;
    if (isLoggedIn) {
      route = RouteManagement.goToHome;
    } else {
      route = RouteManagement.goToAuthWrapper;
    }
    IsmLiveUtility.updateLater(() {
      route();
    });
  }
}
