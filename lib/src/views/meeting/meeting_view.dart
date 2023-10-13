import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyMeetingsView extends StatelessWidget {
  const MyMeetingsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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
            style: IsmLiveStyles.whiteBold16,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {},
              icon: const Icon(
                Icons.add,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        body: GetBuilder<MeetingController>(
            builder: (controller) => Padding(
                  padding: IsmLiveDimens.edgeInsets8_4,
                  child: controller.myMeetingList.isEmpty
                      ? const Center(
                          child: Text('No meetings found'),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) => Container(
                                padding: IsmLiveDimens.edgeInsets4,
                                color: IsmLiveColors.white,
                                height: IsmLiveDimens.fifty,
                                child: Row(
                                  children: [
                                    Text(controller.myMeetingList[index]
                                        .meetingDescription),
                                    const Spacer(),
                                    SizedBox(
                                      width: IsmLiveDimens.hundred,
                                      child: IsmLiveButton(
                                        onTap: () {},
                                        label: 'Join',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: controller.myMeetingList.length),
                )),
      );
}
