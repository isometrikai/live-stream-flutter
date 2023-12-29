import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveLoader extends StatelessWidget {
  const IsmLiveLoader({
    super.key,
    this.isDialog = true,
    this.message,
  });

  final bool isDialog;
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Card(
          elevation: isDialog ? null : 0,
          color: isDialog ? null : Colors.transparent,
          child: Padding(
            padding: isDialog && message != null ? IsmLiveDimens.edgeInsets12 : IsmLiveDimens.edgeInsets8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: IsmLiveColors.primary,
                ),
                if (isDialog && message != null) ...[
                  IsmLiveDimens.boxWidth16,
                  Text(
                    message!,
                    style: context.textTheme.labelLarge,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}
