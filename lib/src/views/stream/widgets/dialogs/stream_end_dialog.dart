import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveStreamEndDialog extends StatelessWidget {
  const IsmLiveStreamEndDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          context.liveTranslations?.attention ?? IsmLiveStrings.attention,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        IsmLiveDimens.boxHeight8,
        Text(
          context.liveTranslations?.streamEnded ?? IsmLiveStrings.streamEnded,
          style: context.textTheme.bodyMedium?.copyWith(
            color: subtitleColor,
          ),
          textAlign: TextAlign.center,
        ),
        IsmLiveDimens.boxHeight20,
        IsmLiveButton(
          label: IsmLiveStrings.okay,
          onTap: () {
            // Check if host app wants to handle the attention dialog button click
            final attentionDialogCallback =
                IsmLiveDelegate.attentionDialogButtonCallback;
            if (attentionDialogCallback != null) {
              // Call host app callback in parallel with dialog close
              unawaited(attentionDialogCallback(context));
            }

            // Always close the dialog (in parallel with callback if provided)
            IsmLiveUtility.closeDialog();
          },
        ),
      ],
    );
  }
}
