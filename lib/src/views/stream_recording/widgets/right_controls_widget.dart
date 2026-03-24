import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

/// Right rail: Products, Share, More.
/// All taps use [IsmLiveStreamRecordingControlOption]; [IsmLiveDelegate.controlOptionCallback]
/// is tried first, then [IsmLiveStreamRecordingPlayerConfig.onControlOption].
class IsmLiveStreamRecordingRightControls extends StatelessWidget {
  const IsmLiveStreamRecordingRightControls({
    super.key,
    required this.config,
    required this.recording,
    this.onPausePlayback,
    this.onResumePlayback,
  });

  final IsmLiveStreamRecordingPlayerConfig config;
  final IsmLiveStreamRecordingItem recording;
  final VoidCallback? onPausePlayback;
  final VoidCallback? onResumePlayback;

  Future<void> _handleOptionTap(
    BuildContext context,
    IsmLiveStreamRecordingControlOption option,
  ) async {
    final onControlOption = config.onControlOption;
    if (onControlOption == null) return;
    onPausePlayback?.call();
    try {
      await onControlOption.call(context, option, recording);
    } finally {
      onResumePlayback?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = config.getCurrentUserId?.call();
    final streamerUserId = recording.userId;
    final isSelfStream = currentUserId != null &&
        currentUserId.isNotEmpty &&
        streamerUserId != null &&
        streamerUserId.isNotEmpty &&
        currentUserId == streamerUserId;

    Widget buildControl(
      IsmLiveStreamRecordingControlWidgetSlot slot,
      IsmLiveStreamOption option,
      VoidCallback onTap,
    ) {
      final defaultChild = _ControlItem(option: option, onTap: onTap);
      return config.controlWidgetBuilder?.call(
            context,
            slot,
            recording,
            config,
            defaultChild,
            onTap: onTap,
          ) ??
          defaultChild;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildControl(
          IsmLiveStreamRecordingControlWidgetSlot.rightProduct,
          IsmLiveStreamOption.product,
          () => _handleOptionTap(
            context,
            IsmLiveStreamRecordingControlOption.product,
          ),
        ),
        IsmLiveDimens.boxHeight8,
        buildControl(
          IsmLiveStreamRecordingControlWidgetSlot.rightShare,
          IsmLiveStreamOption.share,
          () => _handleOptionTap(
            context,
            IsmLiveStreamRecordingControlOption.share,
          ),
        ),
        if (!isSelfStream) ...[
          IsmLiveDimens.boxHeight8,
          buildControl(
            IsmLiveStreamRecordingControlWidgetSlot.rightSettings,
            IsmLiveStreamOption.settings,
            () => _handleOptionTap(
              context,
              IsmLiveStreamRecordingControlOption.settings,
            ),
          ),
        ],
      ],
    );
  }
}

/// Single right-side control: same look as stream [IsmLiveControlsWidget] (CustomIconButton + optional count/label).
class _ControlItem extends StatelessWidget {
  const _ControlItem({
    this.option,
    this.icon,
    required this.onTap,
  }) : assert(option != null || icon != null);

  final IsmLiveStreamOption? option;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.white;

    final Widget iconWidget = option != null
        ? IsmLiveImage.svg(
            height: IsmLiveDimens.forty,
            width: IsmLiveDimens.forty,
            option!.icon,
            color: iconColor,
          )
        : Icon(icon!, color: iconColor, size: IsmLiveDimens.forty);

    return Padding(
      padding: EdgeInsets.only(bottom: IsmLiveDimens.eight),
      child: CustomIconButton(
        dimension: IsmLiveDimens.fifty,
        icon: iconWidget,
        onTap: onTap,
        gradient: IsmLiveDelegate.streamOptionsBgGradient,
      ),
    );
  }
}
