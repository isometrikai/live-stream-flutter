import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  static const String route = AppRoutes.splash;

  @override
  Widget build(BuildContext context) => GetBuilder<SplashController>(
        builder: (controller) => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlutterLogo(),
                SizedBox(height: 30),
                Text('Flutter'),
              ],
            ),
          ),
        ),
      );
}
