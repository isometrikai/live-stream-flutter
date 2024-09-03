import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmLiveMeetingView extends StatefulWidget {
  const IsmLiveMeetingView({super.key});

  @override
  State<IsmLiveMeetingView> createState() => _IsmLiveMeetingViewState();
}

class _IsmLiveMeetingViewState extends State<IsmLiveMeetingView> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
    if (!Get.isRegistered<IsmLiveMeetingController>()) {
      IsmLiveMeetingBinding().dependencies();
    }
    IsmLiveUtility.updateLater(() {
      Get.find<IsmLiveMqttController>().setup(shouldInitializeMqtt: true);
    });
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveMeetingController>(
        initState: (_) {
          Get.find<IsmLiveMeetingController>().initialize(context);
        },
        builder: (controller) => Scaffold(
          backgroundColor: context.liveTheme?.backgroundColor,
          appBar: AppBar(
            backgroundColor: context.liveTheme?.backgroundColor,
            elevation: 0,
            title: Text(
              'All Calls',
              style: context.textTheme.titleLarge,
            ),
            actions: [
              // IconButton(
              //   onPressed: IsmLiveRouteManagement.goToCreateMeetingScreen,
              //   icon: Icon(
              //     Icons.add,
              //     color: IsmliveTheme?.of(context).primaryColor,
              //   ),
              // ),
              IsmLiveTapHandler(
                onTap: () {
                  if (controller.userConfig == null) {
                    return;
                  }
                  IsmLiveUtility.openBottomSheet(
                    IsmLiveLogoutBottomSheet(
                        user: controller.userConfig!.getDetails()),
                  );
                },
                child: IsmLiveImage.network(
                  controller.userConfig?.userProfile ?? '',
                  name: controller.userConfig?.firstName ?? 'U',
                  isProfileImage: true,
                  dimensions: IsmLiveDimens.forty,
                ),
              ),
              IsmLiveDimens.boxWidth10,
            ],
          ),
          body: GetBuilder<IsmLiveMeetingController>(
            builder: (controller) => SmartRefresher(
              controller: controller.refreshController,
              onRefresh: () async {
                await controller.getMeetingList();

                controller.refreshController.refreshCompleted();
              },
              child: controller.myMeetingList.isEmpty
                  ? const Center(
                      child: Text('No meetings found'),
                    )
                  : ListView.separated(
                      padding: IsmLiveDimens.edgeInsets16,
                      itemCount: controller.myMeetingList.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (_, index) {
                        final meeting = controller.myMeetingList[
                            index % controller.myMeetingList.length];
                        return Dismissible(
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            child: const Center(child: Text('Delete')),
                          ),
                          key: UniqueKey(),
                          onDismissed: (direction) async {
                            var isDeleted = await controller.deleteMeeting(
                              isLoading: false,
                              meetingId: meeting.meetingId,
                            );
                            if (isDeleted) {
                              controller.myMeetingList.removeAt(index);
                              controller.update();
                            } else {
                              controller.update();
                            }
                          },
                          child: IsmLiveTapHandler(
                            onTap: () async {
                              var rtcTocken = await controller.joinMeeting(
                                meetingId: meeting.meetingId,
                              );

                              if (rtcTocken != null) {
                                await controller.connectMeeting(
                                  rtcTocken,
                                  meeting.meetingId,
                                  meeting.audioOnly,
                                );
                              }
                            },
                            child: Row(
                              children: [
                                IsmLiveImage.network(
                                  meeting.meetingImageUrl,
                                  name: meeting.initiatorName,
                                  dimensions: IsmLiveDimens.forty,
                                  isProfileImage: true,
                                ),
                                IsmLiveDimens.boxWidth8,
                                Text(meeting.initiatorName),
                                const Spacer(),
                                Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          meeting.creationTime)
                                      .formattedTime,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      );
}
