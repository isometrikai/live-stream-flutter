import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveEmptyScreen extends StatelessWidget {
  const IsmLiveEmptyScreen({
    super.key,
    required this.label,
    required this.placeHolder,
  });

  final String label;
  final String placeHolder;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmLiveImage.svg(
              placeHolder,
              color: context.liveTheme.primaryColor ?? IsmLiveColors.primary,
            ),
            IsmLiveDimens.boxHeight16,
            Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                color: IsmLiveColors.grey,
              ),
            ),
          ],
        ),
      );
}
