import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmliveAnalyticsSheet extends StatelessWidget {
  const IsmliveAnalyticsSheet({super.key, required this.streamId});
  final String streamId;
  static const String updateId = 'analytics-sheet';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) async {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.find<IsmLiveStreamController>().streamAnalytics(streamId);
          });
        },
        builder: (controller) => Padding(
          padding: IsmLiveDimens.edgeInsets8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IsmLiveDimens.boxHeight32,
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
                'Live stream',
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                ),
                children: IsmLiveAnalyticsOptions.optionsList.map((option) {
                  var points = '';
                  var title = '';
                  Color? color;

                  switch (option) {
                    case IsmLiveAnalyticsOptions.hearts:
                      points = '${controller.streamAnalytis?.hearts ?? 0}';
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
                      points = '${controller.streamAnalytis?.followers ?? 0}';
                      title = 'Followers';
                      break;
                    case IsmLiveAnalyticsOptions.earnings:
                      points =
                          '\$${controller.streamAnalytis?.totalEarning ?? 0}';
                      title = 'Earnings';
                      break;
                    case IsmLiveAnalyticsOptions.duration:
                      return GetX<IsmLiveStreamController>(
                        builder: (controller) => IsmLiveEndStreamContainer(
                          points: controller.streamDuration.formattedTime,
                          title: 'Duration',
                          assetConstant: option.icon,
                        ),
                      );
                  }

                  return IsmLiveEndStreamContainer(
                    points: points,
                    title: title,
                    assetConstant: option.icon,
                    color: color,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
}
