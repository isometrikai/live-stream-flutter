import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkInviteSheet extends StatelessWidget {
  IsmLivePkInviteSheet({
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
  Timer? timer;
  bool isAccepted = false;
  static const String updateId = 'pk-invite-sheet';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
      id: updateId,
      builder: (controller) => Padding(
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
                      const Align(
                        alignment: Alignment.center,
                        child: IsmLiveImage.svg(
                          IsmLiveAssetConstants.linking,
                        ),
                      ),
                    ],
                  ),
                ),
                IsmLiveDimens.boxHeight10,
                Text(
                  isAccepted ? 'Linking' : title,
                  style: context.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                IsmLiveDimens.boxHeight10,
                Text(
                  isAccepted
                      ? 'The PK challenge between you and @tavvi will start soon. Please wait…'
                      : description,
                  style: context.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                IsmLiveDimens.boxHeight20,
                if (isAccepted == false)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: Get.width * 0.4,
                        child: IsmLiveButton(
                          label: 'Reject',
                          onTap: Get.back,
                          showBorder: true,
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.4,
                        child: IsmLiveButton(
                          label: 'Accept',
                          onTap: () {
                            isAccepted = true;
                            controller.update([updateId]);
                            controller.pkLoading(timer);
                          },
                        ),
                      )
                    ],
                  )
                else
                  Obx(
                    () => LinearProgressIndicator(
                      minHeight: IsmLiveDimens.ten,
                      value: controller.pkLoadingValue,
                      borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
                    ),
                  ),
              ],
            ),
          ));
}
