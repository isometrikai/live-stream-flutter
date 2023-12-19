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
        builder: (controller) => IsmLiveStream(
          configuration: IsmLiveStreamConfig(
            communicationConfig: IsmLiveCommunicationConfig(
              deviceId: controller.user.deviceId,
              appSecret: AppConstants.appSecret,
              licenseKey: AppConstants.licenseKey,
              userSecret: AppConstants.userSecret,
            ),
            userConfig: IsmLiveUserConfig(
              userToken: controller.user.userToken,
              userId: controller.user.userId,
              firstName: controller.user.firstName,
              lastName: controller.user.lastName,
              userEmail: controller.user.email,
              userProfile: '',
            ),
          ),
        ),
      );
}
