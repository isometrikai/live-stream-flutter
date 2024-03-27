import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/agent_auth/agent_controller.dart';
import 'package:appscrip_live_stream_component_example/utils/navigators/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class AgentOtpView extends StatelessWidget {
  const AgentOtpView({super.key});
  static const String route = AppRoutes.agentOtp;

  @override
  Widget build(BuildContext context) => GetBuilder<AgentAuthControlletr>(
        builder: (controller) => Scaffold(
          body: Padding(
            padding: IsmLiveDimens.edgeInsets16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PinCodeTextField(
                  enableActiveFill: true,
                  enablePinAutofill: false,
                  controller: controller.otpController,
                  appContext: context,
                  length: 6,
                  onChanged: (value) {
                    // Handle OTP input changes
                  },
                  onCompleted: (value) {
                    // Handle OTP input completion
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                    activeColor: Colors.blue,
                    selectedColor: Colors.blue,
                    inactiveColor: Colors.grey,
                  ),
                ),
                IsmLiveDimens.boxHeight32,
                IsmLiveButton(
                  label: 'Submit',
                  onTap: () {
                    controller.agentLogin();
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
