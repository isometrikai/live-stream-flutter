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
            width: MediaQuery.of(context).size.width * 0.8,
            child: SafeArea(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: IsmLiveColors.black.withAlpha(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        IsmLiveStrings.broadcastingRulesTitle,
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: IsmLiveColors.white,
                        ),
                      ),
                      IsmLiveDimens.boxHeight16,
                      Text(
                        IsmLiveStrings.welcomeToStreamRulesText,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: IsmLiveColors.white.withAlpha(200),
                        ),
                      ),
                      IsmLiveDimens.boxHeight16,
                      Text(
                        IsmLiveStrings.viewerConductTitle,
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: IsmLiveColors.white,
                        ),
                      ),
                      IsmLiveDimens.boxHeight16,
                      Text(
                        IsmLiveStrings.broadcastingRulesText,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: IsmLiveColors.white.withAlpha(200),
                        ),
                      ),
                      IsmLiveDimens.boxHeight16,
                      Text(
                        IsmLiveStrings.noSpammingText,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: IsmLiveColors.white.withAlpha(200),
                        ),
                      ),
                      IsmLiveDimens.boxHeight10,
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
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
          ),
        ),
      );
}
