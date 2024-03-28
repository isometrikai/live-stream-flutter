import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgentPhoneView extends StatelessWidget {
  const AgentPhoneView({super.key});

  static const String route = AppRoutes.agentPhone;

  @override
  Widget build(BuildContext context) => GetBuilder<AgentAuthControlletr>(
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: true,
          body: Padding(
            padding: IsmLiveDimens.edgeInsets16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IsmLiveDimens.box0,
                const Spacer(),
                Text(
                  'Enter Your Phone',
                  style: context.textTheme.titleLarge,
                ),
                IsmLiveDimens.boxHeight32,
                IsmLiveInputField(
                  controller: controller.phoneNoController,
                  hintText: 'Enter phone',
                  textInputType: TextInputType.phone,
                ),
                const Spacer(),
                IsmLiveButton(
                  label: 'Send otp',
                  onTap: () {
                    if (controller.phoneNoController.isNotEmpty) {
                      controller.sentOtp();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      );
}
