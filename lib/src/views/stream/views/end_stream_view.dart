import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveEndStream extends StatelessWidget {
  const IsmLiveEndStream({
    super.key,
  });

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Scaffold(
          appBar:
              AppBar(automaticallyImplyLeading: false, elevation: 0, actions: [
            IconButton(
              icon: const Icon(
                Icons.close,
              ),
              onPressed: Get.back,
            ),
          ]),
          body: GetBuilder<IsmLiveStreamController>(
            builder: (controller) => Padding(
              padding: IsmLiveDimens.edgeInsets16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IsmLiveImage.network(
                    controller.user?.userProfileImageUrl ?? '',
                    name: controller.user?.userName ?? 'U',
                    height: IsmLiveDimens.hundred,
                    width: IsmLiveDimens.hundred,
                    isProfileImage: true,
                  ),
                  IsmLiveDimens.boxHeight10,
                  Text(
                    'Live stream ended!',
                    style: context.textTheme.headlineMedium,
                  ),
                  IsmLiveDimens.boxHeight16,
                  const Divider(),
                  IsmLiveDimens.boxHeight20,
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                    ),
                    children: [
                      IsmLiveEndStreamContainer(
                        points: '${controller.hearts}',
                        title: 'Hearts',
                        assetConstant: IsmLiveAssetConstants.heart,
                      ),
                      IsmLiveEndStreamContainer(
                        points: '${controller.orders}',
                        title: 'Order',
                        assetConstant: IsmLiveAssetConstants.box,
                      ),
                      IsmLiveEndStreamContainer(
                        points: '${controller.streamViewersList.length}',
                        title: 'Viewers',
                        assetConstant: IsmLiveAssetConstants.eye,
                      ),
                      IsmLiveEndStreamContainer(
                        points: '${controller.followers}',
                        title: 'Followers',
                        assetConstant: IsmLiveAssetConstants.profileUser,
                      ),
                      IsmLiveEndStreamContainer(
                        points: '\$${controller.earnings}',
                        title: 'Earnings',
                        assetConstant: IsmLiveAssetConstants.dollar,
                      ),
                      IsmLiveEndStreamContainer(
                        points: controller.duration.formattedTime,
                        title: 'Duration',
                        assetConstant: IsmLiveAssetConstants.clock,
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: 5,
                  ),
                  // IsmLiveListSheet(
                  //   list: controller.streamViewersList,
                  //   isHost: false,
                  // ),
                ],
              ),
            ),
          ),
        ),
      );
}
