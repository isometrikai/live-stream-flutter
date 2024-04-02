import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveModeratorDialog extends StatelessWidget {
  const IsmLiveModeratorDialog({
    super.key,
    required this.hostName,
    required this.streamId,
  });

  final String hostName;
  final String streamId;

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              context.liveTranslations?.attention ?? IsmLiveStrings.attention,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            IsmLiveDimens.boxHeight8,
            Text(
              (context.liveTranslations?.addedModerator ?? IsmLiveStrings.addedModerator).trParams(
                {'name': hostName},
              ),
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight32,
            IsmLiveButton(
              label: 'Join Now',
              onTap: () {
                IsmLiveUtility.closeDialog();
                final controller = Get.find<IsmLiveStreamController>();
                final stream = controller.streams.cast<IsmLiveStreamModel?>().firstWhere(
                      (e) => e?.streamId == streamId,
                      orElse: () => null,
                    );
                if (stream == null) {
                  return;
                }
                controller.initializeStream(isHost: false, streamId: streamId);
                controller.initializeAndJoinStream(stream, false);
              },
            ),
            IsmLiveDimens.boxHeight8,
            Row(
              children: [
                Flexible(
                  child: IsmLiveButton.secondary(
                    label: 'Reject',
                    onTap: () {
                      IsmLiveUtility.closeDialog();
                      final controller = Get.find<IsmLiveStreamController>();
                      controller.leaveModerator(streamId);
                    },
                  ),
                ),
                IsmLiveDimens.boxWidth8,
                const Flexible(
                  child: IsmLiveButton.secondary(
                    label: 'Join Later',
                    onTap: IsmLiveUtility.closeDialog,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
