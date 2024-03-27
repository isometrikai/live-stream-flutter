import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyMeetingsView extends StatelessWidget {
  MyMeetingsView({
    super.key,
  });
  var controller = Get.put(
    MeetingController(
      MeetingViewModel(
        MeetingRepository(
          Get.find(),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: IsmLiveTheme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: IsmLiveTheme.of(context).backgroundColor,
          elevation: 0,
          leadingWidth: IsmLiveDimens.eighty,
          leading: TextButton(
            onPressed: () => IsmLiveApp.logout(false),
            child: const Text(
              'LogOut',
              style: TextStyle(color: Colors.black),
            ),
          ),
          title: Text(
            'My Meetings',
            style: IsmLiveStyles.black16,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: IsmLiveRouteManagement.goToCreateMeetingScreen,
              icon: Icon(
                Icons.add,
                color: IsmLiveTheme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        body: GetBuilder<MeetingController>(
          initState: (state) async {
            var cont = Get.find<MeetingController>();
            cont.configuration = IsmLiveConfig.of(context);
            await cont.getMeetingList();
          },
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
                    itemBuilder: (context, index) {
                      final item = controller.myMeetingList[index].meetingId;
                      return Dismissible(
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          child: const Center(child: Text('Delete')),
                        ),
                        key: UniqueKey(),
                        onDismissed: (direction) async {
                          var isDeleted = await controller.deleteMeeting(
                              isLoading: false, meetingId: item);
                          if (isDeleted) {
                            controller.myMeetingList.removeAt(index);
                            controller.update();
                          } else {
                            controller.update();
                          }
                        },
                        child: Container(
                          padding: IsmLiveDimens.edgeInsets4,
                          color: IsmLiveColors.white,
                          height: IsmLiveDimens.fifty,
                          child: Row(
                            children: [
                              Text(controller
                                  .myMeetingList[index].meetingDescription),
                              const Spacer(),
                              SizedBox(
                                width: IsmLiveDimens.hundred,
                                child: IsmLiveButton(
                                  onTap: () async {
                                    var rtcTocken =
                                        await controller.joinMeeting(
                                            meetingId: controller
                                                .myMeetingList[index]
                                                .meetingId);

                                    IsmLiveLog(controller
                                        .myMeetingList[index].audioOnly);
                                    if (rtcTocken != null) {
                                      await controller.connectMeeting(
                                          rtcTocken,
                                          controller
                                              .myMeetingList[index].meetingId,
                                          controller
                                              .myMeetingList[index].audioOnly);
                                    }
                                  },
                                  label: 'Join',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: controller.myMeetingList.length,
                  ),
          ),
        ),
      );
}
