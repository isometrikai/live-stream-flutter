import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// PK countdown overlay; visibility and ticks avoid [IsmLiveStreamView] rebuilds.
class IsmLivePkTimerOverlay extends StatelessWidget {
  const IsmLivePkTimerOverlay({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        if (!Get.isRegistered<IsmLivePkController>() ||
            !Get.isRegistered<IsmLiveStreamController>()) {
          return const SizedBox.shrink();
        }
        final pk = Get.find<IsmLivePkController>();
        final stream = Get.find<IsmLiveStreamController>();
        if (!pk.pkBattleStarted || stream.participantTracks.length <= 1) {
          return const SizedBox.shrink();
        }
        return const IsmLivePkTimerContainer();
      });
}

class IsmLivePkTimerContainer extends StatelessWidget {
  const IsmLivePkTimerContainer({super.key});

  static const Alignment _alignment = Alignment(0, -0.4);

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.bodyLarge?.copyWith(
      color: Colors.yellow,
    );
    return RepaintBoundary(
      child: Stack(
        children: [
          const Align(
            alignment: _alignment,
            child: IsmLiveImage.svg(
              IsmLiveAssetConstants.timerContainer,
            ),
          ),
          Align(
            alignment: _alignment,
            child: _PkCountdownLabel(textStyle: textStyle),
          ),
        ],
      ),
    );
  }
}

class _PkCountdownLabel extends StatelessWidget {
  const _PkCountdownLabel({this.textStyle});

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => Obx(
        () => Text(
          Get.find<IsmLivePkController>().pkDuration.formattedTimeInMin,
          style: textStyle,
        ),
      );
}
