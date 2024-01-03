import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YourLiveSheet extends StatelessWidget {
  const YourLiveSheet({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IsmLiveDimens.boxHeight16,
            Text(
              'You\'re Live',
              style: IsmLiveStyles.blackBold16,
            ),
            IsmLiveDimens.boxHeight8,
            Padding(
              padding: IsmLiveDimens.edgeInsets40_0,
              child: const Text(
                'We\'ve sent a notification to your followers your fans will start to join soon',
                textAlign: TextAlign.center,
              ),
            ),
            IsmLiveDimens.boxHeight16,
            IsmLiveButton(
              label: 'Ok',
              onTap: () {
                Get.back();
                onTap();
              },
            ),
          ],
        ),
      );
}
