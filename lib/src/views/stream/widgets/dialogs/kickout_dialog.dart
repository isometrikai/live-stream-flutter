import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class IsmLiveKickoutDialog extends StatelessWidget {
  const IsmLiveKickoutDialog({super.key});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.liveTranslations.attention ?? IsmLiveStrings.attention,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          IsmLiveDimens.boxHeight8,
          Text(
            context.liveTranslations.kickoutMessage ?? IsmLiveStrings.kickoutMessage,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          IsmLiveDimens.boxHeight20,
          const IsmLiveButton(
            label: 'Continue',
            onTap: IsmLiveUtility.closeDialog,
          ),
        ],
      );
}
