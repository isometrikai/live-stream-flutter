import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/res/constants/app_constants.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const String route = AppRoutes.home;

  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
        builder: (controller) => IsmLiveApp(
          configuration: IsmLiveConfigData(
            projectConfig: IsmLiveProjectConfig(
              accountId: AppConstants.accountId,
              appSecret: AppConstants.appSecret,
              userSecret: AppConstants.userSecret,
              keySetId: AppConstants.keySetId,
              licenseKey: AppConstants.licenseKey,
              projectId: AppConstants.projectId,
              deviceId: controller.user.deviceId,
            ),
            userConfig: IsmLiveUserConfig(
              userToken: controller.user.userToken,
              userId: controller.user.userId,
              firstName: controller.user.firstName,
              lastName: controller.user.lastName,
              userEmail: controller.user.email,
              userProfile: '',
            ),
            mqttConfig: const IsmLiveMqttConfig(
              hostName: AppConstants.mqttHost,
              port: AppConstants.mqttPort,
            ),
          ),
          onLogout: () {
            controller.logout();
          },
        ),
      );
}
