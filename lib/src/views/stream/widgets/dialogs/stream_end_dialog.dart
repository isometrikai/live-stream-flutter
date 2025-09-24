import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveStreamEndDialog extends StatelessWidget {
  const IsmLiveStreamEndDialog({super.key});

  @override
  Widget build(BuildContext context) => Column(
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
            context.liveTranslations?.streamEnded ?? IsmLiveStrings.streamEnded,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          IsmLiveDimens.boxHeight20,
          IsmLiveButton(
            label: 'Okay',
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
