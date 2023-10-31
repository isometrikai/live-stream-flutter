import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyMeetingsView extends StatelessWidget {
  MyMeetingsView({
    super.key,
    required this.configuration,
  });
  final IsmLiveStreamConfig configuration;
  var cont = Get.put(
      MeetingController(
        MeetingViewModel(
          MeetingRepository(
            Client(),
          ),
        ),
      ),
      permanent: true);
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const Center(
            child: Text(
              'LogOut',
              style: TextStyle(color: Colors.black),
            ),
          ),
          title: Text(
            'My Meetings',
            style: IsmLiveStyles.black16,
          ),
          centerTitle: true,
          actions: const [
            IconButton(
              onPressed: IsLiveRouteManagement.goToCreateMeetingScreen,
              icon: Icon(
                Icons.add,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        body: GetBuilder<MeetingController>(
          initState: (_) async {
            cont.configuration = configuration;
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
                    itemBuilder: (context, index) => Container(
                      padding: IsmLiveDimens.edgeInsets4,
                      color: IsmLiveColors.white,
                      height: IsmLiveDimens.fifty,
                      child: Row(
                        children: [
                          Text(controller
                              .myMeetingList[index].meetingDescription),
                          const Text('meeting '),
                          const Spacer(),
                          SizedBox(
                            width: IsmLiveDimens.hundred,
                            child: IsmLiveButton(
                              onTap: () async {
                                var rtcTocken = await controller.joinMeeting(
                                    meetingId: controller
                                        .myMeetingList[index].meetingId);
                                if (rtcTocken != null) {
                                  await controller.connectMeeting(rtcTocken);
                                }
                              },
                              label: 'Join',
                            ),
                          ),
                        ],
                      ),
                    ),
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: controller.myMeetingList.length,
                  ),
          ),
        ),
      );
}
