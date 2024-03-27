import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/utils/navigators/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgentPhoneView extends StatelessWidget {
  const AgentPhoneView({super.key});
  static const String route = AppRoutes.agentPhone;

  @override
  Widget build(BuildContext context) => GetBuilder<AgentAuthControlletr>(
        builder: (controller) => Scaffold(
          body: Padding(
            padding: IsmLiveDimens.edgeInsets16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IsmLiveInputField(
                  controller: controller.phoneNoController,
                  hintText: 'Phone Number',
                  textInputType: TextInputType.phone,
                ),
                IsmLiveDimens.boxHeight32,
                IsmLiveButton(
                  label: 'Send otp',
                  onTap: () {
                    if (controller.phoneNoController.isNotEmpty) {
                      controller.sentOtp();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
