import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
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
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.liveTranslations?.streamTranslations
                            ?.moderationWarning ??
                        IsmLiveStrings.moderationWarning,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: IsmLiveColors.white,
                    ),
                  ),
                  IsmLiveDimens.boxHeight10,
                  SizedBox(
                    width: Get.width * 0.5,
                    child: IsmLiveButton(
                      label: 'Got it',
                      onTap: () {
                        controller.isModerationWarningVisible = false;
                        controller.update([updateId]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
