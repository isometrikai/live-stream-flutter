import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveEndStream extends StatelessWidget {
  IsmLiveEndStream({
    super.key,
  }) : streamId = Get.arguments['streamId'];
  final String streamId;
  static const String updateId = 'end-stream-view';

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: GetBuilder<IsmLiveStreamController>(
          id: updateId,
          initState: (state) async {
            var controller = Get.find<IsmLiveStreamController>();
            await controller.streamAnalytics(streamId);
            // controller.streamAnalyticsViewers(streamId);
          },
          builder: (controller) => Scaffold(
            body: Padding(
              padding: IsmLiveDimens.edgeInsets8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IsmLiveDimens.boxHeight32,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IsmLiveDimens.boxWidth50,
                      IsmLiveImage.network(
                        controller.user?.userProfileImageUrl ?? '',
                        name: controller.user?.userName ?? 'U',
                        height: IsmLiveDimens.ninty,
                        width: IsmLiveDimens.ninty,
                        isProfileImage: true,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                        ),
                        onPressed: Get.back,
                      ),
                    ],
                  ),
                  IsmLiveDimens.boxHeight16,
                  Text(
                    'Live stream ended!',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IsmLiveDimens.boxHeight16,
                  const Divider(
                    thickness: 0.5,
                  ),
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
                        points: '${controller.streamAnalytis?.hearts ?? 0}',
                        title: 'Hearts',
                        color: Colors.black,
                        assetConstant: IsmLiveAssetConstants.heartSvg,
                      ),
                      IsmLiveEndStreamContainer(
                        points: '${controller.streamAnalytis?.soldCount ?? 0}',
                        title: 'Order',
                        assetConstant: IsmLiveAssetConstants.box,
                      ),
                      IsmLiveEndStreamContainer(
                        points:
                            '${controller.streamAnalytis?.totalViewersCount ?? 0}',
                        title: 'Viewers',
                        assetConstant: IsmLiveAssetConstants.eye,
                      ),
                      IsmLiveEndStreamContainer(
                        points: '${controller.streamAnalytis?.followers ?? 0}',
                        title: 'Followers',
                        assetConstant: IsmLiveAssetConstants.profileUser,
                      ),
                      IsmLiveEndStreamContainer(
                        points: '\$${controller.streamAnalytis?.earnings ?? 0}',
                        title: 'Earnings',
                        assetConstant: IsmLiveAssetConstants.dollar,
                      ),
                      IsmLiveEndStreamContainer(
                        points:
                            '${controller.streamAnalytis?.duration ?? '00:00'}',
                        title: 'Duration',
                        assetConstant: IsmLiveAssetConstants.clock,
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 5,
                    color: Colors.grey.shade300,
                  ),
                  IsmLiveListSheet(
                    scrollController: controller.viewerListController,
                    items: controller.streamViewersList,
                    title: 'Viewer(${controller.streamViewersList.length})',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
