import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkInviteSheet extends StatelessWidget {
  const IsmLivePkInviteSheet({
    super.key,
    required this.images,
    required this.label,
    required this.title,
    required this.description,
    this.onTap,
  });
  final List<String> images;
  final String label;
  final VoidCallback? onTap;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16.copyWith(
          top: IsmLiveDimens.thirtyTwo,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: IsmLiveDimens.twoHundred,
              height: IsmLiveDimens.hundred,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: [
                      IsmLiveImage.network(
                        images[0],
                        name: title,
                        height: IsmLiveDimens.hundred,
                        width: IsmLiveDimens.hundred,
                        isProfileImage: true,
                      ),
                      IsmLiveImage.network(
                        images[1],
                        name: title,
                        height: IsmLiveDimens.hundred,
                        width: IsmLiveDimens.hundred,
                        isProfileImage: true,
                      ),
                    ],
                  ),

                  ///TODO
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 50,
                      width: 50,
                      color: Colors.amber,
                    ),
                  )
                ],
              ),
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              title,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              description,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight20,
            if (onTap == null)
              Row(
                children: [
                  SizedBox(
                    width: IsmLiveDimens.hundred,
                    child: const IsmLiveButton(
                      label: 'Reject',
                      showBorder: true,
                    ),
                  ),
                  SizedBox(
                    width: IsmLiveDimens.hundred,
                    child: IsmLiveButton(
                      label: 'Accept',
                      onTap: () {
                        Get.find<IsmLiveStreamController>()
                            .animationController
                            .forward();
                      },
                    ),
                  )
                ],
              )
            else
              LinearProgressIndicator(
                minHeight: IsmLiveDimens.ten,
                value: 0.3,
                borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
              ),
          ],
        ),
      );
}
