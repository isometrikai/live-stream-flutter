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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textIconColor = isDarkMode ? Colors.white : Colors.black;
    final dividerColor = context.liveTheme?.borderColor ??
        (isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade300);

    return PopScope(
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
            IsmLiveDelegate.streamScreenConfigure.endStreamScreen ??
            Scaffold(
              backgroundColor: context.liveTheme?.backgroundColor ??
                  (isDarkMode ? const Color(0xFF121212) : Colors.white),
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
                                  controller.user?.userProfileImageUrl ?? '') ??
                              controller.user?.userProfileImageUrl ??
                              '',
                          name: controller.user?.userName ?? 'U',
                          initials: controller.user?.profileInitials,
                          height: IsmLiveDimens.ninty,
                          width: IsmLiveDimens.ninty,
                          isProfileImage: true,
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textIconColor),
                          onPressed: IsmLiveRoute.pop,
                        ),
                      ],
                    ),
                    IsmLiveDimens.boxHeight16,
                    Text(
                      IsmLiveStrings.liveStreamEnded,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textIconColor,
                      ),
                    ),
                    IsmLiveDimens.boxHeight16,
                    Divider(
                      thickness: 0.5,
                      color: dividerColor,
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
                            title = IsmLiveStrings.hearts;
                            color = textIconColor;
                            break;
                          case IsmLiveAnalyticsOptions.order:
                            points =
                                '${controller.streamAnalytis?.soldCount ?? 0}';
                            title = IsmLiveStrings.order;
                            break;
                          case IsmLiveAnalyticsOptions.viewers:
                            points =
                                '${controller.streamAnalytis?.totalViewersCount ?? 0}';
                            title = IsmLiveStrings.viewers;
                            break;
                          case IsmLiveAnalyticsOptions.followers:
                            points =
                                '${controller.streamAnalytis?.followers ?? 0}';
                            title = IsmLiveStrings.followers;
                            break;
                          case IsmLiveAnalyticsOptions.earnings:
                            final totalEarning = num.tryParse(
                                  '${controller.streamAnalytis?.totalEarning ?? 0}',
                                ) ??
                                0;
                            points = totalEarning.toStringAsFixed(2);
                            title = IsmLiveStrings.earnings;
                            break;
                          case IsmLiveAnalyticsOptions.duration:
                            points = ((controller.streamAnalytis
                                            ?.durationMilliSeconds ??
                                        0) >
                                    0)
                                ? Duration(
                                        milliseconds: controller.streamAnalytis!
                                            .durationMilliSeconds!
                                            .toInt())
                                    .formattedTime
                                : controller.streamDuration.formattedTime;
                            title = IsmLiveStrings.duration;
                            break;
                        }

                        return IsmLiveEndStreamContainer(
                          points: points,
                          title: title,
                          assetConstant: option.icon,
                          color: color ?? textIconColor,
                        );
                      }).toList(),
                    ),
                    Divider(
                      thickness: 5,
                      color: dividerColor,
                    ),
                    Obx(() => IsmLiveListSheetTwo(
                          scrollController: controller.viewerListController,
                          items: controller.analyticsViewers,
                          title:
                              '${IsmLiveStrings.viewer}(${controller.analyticsViewers.length})',
                        )),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
