import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveScheduleDialog extends StatelessWidget {
  const IsmLiveScheduleDialog({super.key, required this.message});
  final DateTime message;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          IsmLiveStrings.streamSchedule,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        IsmLiveDimens.boxHeight8,
        Text(
          'At ${message.formattedDate}',
          style: context.textTheme.bodyMedium?.copyWith(color: textColor),
        ),
        IsmLiveDimens.boxHeight20,
        const IsmLiveButton(
          label: IsmLiveStrings.okay,
          onTap: IsmLiveUtility.closeDialogAndPopUnderlyingRoute,
        ),
      ],
    );
  }
}

class IsmLiveEditScheduleDialog extends StatelessWidget {
  const IsmLiveEditScheduleDialog({super.key, required this.message});
  final DateTime message;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final secondaryTextColor = textColor.withValues(alpha: 0.85);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          IsmLiveStrings.scheduleUpdated,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        IsmLiveDimens.boxHeight8,
        Text(
          '${IsmLiveStrings.scheduleUpdatedDescription} ${message.formattedDate}.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: secondaryTextColor,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        IsmLiveDimens.boxHeight20,
        IsmLiveButton(
          label: IsmLiveStrings.okay,
          onTap: IsmLiveUtility.closeEditScheduleDialogAndReturn,
        ),
      ],
    );
  }
}
