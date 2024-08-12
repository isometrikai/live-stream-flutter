import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class IsmLiveScheduleDialog extends StatelessWidget {
  const IsmLiveScheduleDialog({super.key, required this.message});
  final DateTime message;
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Stream Schedule',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          IsmLiveDimens.boxHeight8,
          Text(
            'at ${DateFormat('yyyy MMMM dd, h:mm').format(message)}',
            style: context.textTheme.bodyMedium,
          ),
          IsmLiveDimens.boxHeight20,
          const IsmLiveButton(
            label: 'Continue',
            onTap: IsmLiveUtility.closeDialog,
          ),
        ],
      );
}
