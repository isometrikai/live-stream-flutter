import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveEndStream extends StatelessWidget {
  const IsmLiveEndStream({
    super.key,
    required this.streamId,
  });
  final String streamId;
  static const String updateId = 'end-stream-view';

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: GetBuilder<IsmLiveStreamController>(
          id: updateId,
          initState: (state) async {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final controller = Get.find<IsmLiveStreamController>();
              controller
                ..streamAnalytics(streamId)
                ..streamAnalyticsViewers(streamId: streamId);
            });
          },
          builder: (controller) =>
              IsmLiveDelegate.endStreamScreen ??
              Scaffold(
                body: Padding(
                  padding: IsmLiveDimens.edgeInsets8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IsmLiveDimens.boxHeight50,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IsmLiveDimens.boxWidth50,
                          IsmLiveImage.network(
                            IsmLiveDelegate.getUserProfileUrl?.call(
                                    controller.user?.userProfileImageUrl ??
                                        '') ??
                                controller.user?.userProfileImageUrl ??
                                '',
                            name: controller.user?.userName ?? 'U',
                            height: IsmLiveDimens.ninty,
                            width: IsmLiveDimens.ninty,
                            isProfileImage: true,
                          ),
                          const IconButton(
                            icon: Icon(
                              Icons.close,
                              color: IsmLiveColors.lightGray,
                            ),
                            onPressed: IsmLiveRoute.pop,
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
                        children:
                            IsmLiveAnalyticsOptions.optionsList.map((option) {
                          var points = '';
                          var title = '';
                          Color? color;

                          switch (option) {
                            case IsmLiveAnalyticsOptions.hearts:
                              points =
                                  '${controller.streamAnalytis?.hearts ?? 0}';
                              title = 'Hearts';
                              color = Colors.black;
                              break;
                            case IsmLiveAnalyticsOptions.order:
                              points =
                                  '${controller.streamAnalytis?.soldCount ?? 0}';
                              title = 'Order';
                              break;
                            case IsmLiveAnalyticsOptions.viewers:
                              points =
                                  '${controller.streamAnalytis?.totalViewersCount ?? 0}';
                              title = 'Viewers';
                              break;
                            case IsmLiveAnalyticsOptions.followers:
                              points =
                                  '${controller.streamAnalytis?.followers ?? 0}';
                              title = 'Followers';
                              break;
                            case IsmLiveAnalyticsOptions.earnings:
                              points =
                                  '${controller.streamAnalytis?.totalEarning ?? 0}';
                              title = 'Earnings';
                              break;
                            case IsmLiveAnalyticsOptions.duration:
                              points = ((controller.streamAnalytis
                                              ?.durationMilliSeconds ??
                                          0) >
                                      0)
                                  ? Duration(
                                          milliseconds: controller
                                              .streamAnalytis!
                                              .durationMilliSeconds!
                                              .toInt())
                                      .formattedTime
                                  : controller.streamDuration.formattedTime;
                              title = 'Duration';
                              break;
                          }

                          return IsmLiveEndStreamContainer(
                            points: points,
                            title: title,
                            assetConstant: option.icon,
                            color: color,
                          );
                        }).toList(),
                      ),
                      Divider(
                        thickness: 5,
                        color: Colors.grey.shade300,
                      ),
                      Obx(() => IsmLiveListSheetTwo(
                            scrollController: controller.viewerListController,
                            items: controller.analyticsViewers,
                            title:
                                'Viewer(${controller.analyticsViewers.length})',
                          )),
                    ],
                  ),
                ),
              ),
        ),
      );
}
