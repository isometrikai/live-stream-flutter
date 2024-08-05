import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/main.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const String route = AppRoutes.home;

  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
        initState: (state) {
          // IsmLiveStreamListing.child = Scaffold(
          //     body: Center(
          //         child: GestureDetector(
          //   child: const Text('tariq the creater'),
          //   onTap: () {
          //     var contn = Get.find<IsmLiveStreamController>();
          //     contn.getStreams();
          //   },
          // )));
        },
        builder: (controller) => IsmLiveApp(
          configuration: kConfigData.value ?? controller.configData,
          enableLog: true,
          onLogout: controller.logout,
        ),
      );
}
