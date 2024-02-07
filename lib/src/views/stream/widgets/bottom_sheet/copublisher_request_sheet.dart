import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCopublisherSheet extends StatelessWidget {
  const IsmLiveCopublisherSheet({
    super.key,
    required this.imageUrlLeft,
    required this.imageUrlRight,
    required this.buttonLable,
    this.onTap,
  });
  final String imageUrlLeft;
  final String imageUrlRight;
  final String buttonLable;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16_30_10_5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: Get.width / 2,
              child: Stack(
                children: [
                  Positioned(
                    right: 10,
                    child: IsmLiveImage.network(
                      imageUrlRight,
                      height: IsmLiveDimens.hundred,
                      width: IsmLiveDimens.hundred,
                      isProfileImage: true,
                    ),
                  ),
                  IsmLiveImage.network(
                    imageUrlLeft,
                    height: IsmLiveDimens.hundred,
                    width: IsmLiveDimens.hundred,
                    isProfileImage: true,
                  ),
                ],
              ),
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              //TODO
              IsmLiveStrings.requestCopublisher,
              style: context.textTheme.titleMedium,
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              //TODO
              IsmLiveStrings.copublisherDiscription,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight20,
            IsmLiveButton(
              label: buttonLable,
              onTap: onTap,
            ),
          ],
        ),
      );
}
