import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
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
                Text(
                  'Enter Verification Code',
                  style: context.textTheme.titleLarge,
                ),
                IsmLiveDimens.boxHeight20,
                Text(
                  'Enter the verification code sent to ${controller.phoneNoController.text}',
                  style: context.textTheme.bodyLarge,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
                IsmLiveDimens.boxHeight20,
                Padding(
                  padding: IsmLiveDimens.edgeInsets16_0,
                  child: PinCodeTextField(
                    enableActiveFill: true,
                    enablePinAutofill: false,
                    controller: controller.otpController,
                    appContext: context,
                    length: 6,
                    onCompleted: (value) {
                      controller.agentLogin();
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(20),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: IsmLiveColors.white,
                      activeColor: IsmLiveColors.black,
                      selectedColor: IsmLiveColors.black,
                      inactiveColor: IsmLiveColors.grey,
                      selectedFillColor: IsmLiveColors.white,
                      inactiveFillColor: IsmLiveColors.white,
                    ),
                  ),
                ),
                IsmLiveDimens.boxHeight32,
                IsmLiveButton(
                  label: 'Verify',
                  onTap: controller.agentLogin,
                ),
              ],
            ),
          ),
        ),
      );
}
