import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class IsmLiveModerationWarning extends StatelessWidget {
  const IsmLiveModerationWarning({super.key});

  static const String updateId = 'ismlive-moderation-warning';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        builder: (controller) => Offstage(
          offstage: !controller.isModerationWarningVisible,
          child: SizedBox(
            width: Get.width * 0.8,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Bottom Sheet Background
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  // push down to make room for circle
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  // top padding for content
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        IsmLiveStrings.youAreLiveNow,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        IsmLiveStrings.moderationWarning,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPress: () {
                            controller.isModerationWarningVisible = false;
                            controller.update([updateId]);
                          },
                          height: IsmLiveDimens.fifty,
                          title: IsmLiveStrings.tvContinue,
                        ),
                      ),
                    ],
                  ),
                ),
                // Circle Icon Overlapping Top
                CircleAvatar(
                  radius: 40,
                  child: SvgPicture.asset(
                    IsmLiveAssetConstants.iamatLogo,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
