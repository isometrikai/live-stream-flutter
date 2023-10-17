import 'dart:developer';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

class MyMeetingsView extends StatefulWidget {
  const MyMeetingsView({super.key});

  @override
  State<MyMeetingsView> createState() => _MyMeetingsViewState();
}

class _MyMeetingsViewState extends State<MyMeetingsView> {
  @override
  void initState() {
    super.initState();

    if (lkPlatformIs(PlatformType.android)) {
      _checkPremissions();
    }
  }

  var controller = Get.put(MeetingController(
      MeetingViewModel(MeetingRepository(IsmLiveApiWrapper()))));

  Future<void> _checkPremissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isPermanentlyDenied) {
      log('Bluetooth Permission disabled');
    }

    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      log('Bluetooth Connect Permission disabled');
    }

    status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      log('Camera Permission disabled');
    }

    status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      log('Microphone Permission disabled');
    }
  }

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
          builder: (controller) => Padding(
            padding: IsmLiveDimens.edgeInsets16_15,
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
                          Text(controller
                              .myMeetingList[index].meetingDescription),
                          const Text('meeting '),
                          const Spacer(),
                          SizedBox(
                            width: IsmLiveDimens.hundred,
                            child: IsmLiveButton(
                              onTap: () async {
                                var rtcTocken = await controller.joinMeeting(
                                    token: '',
                                    licenseKey: '',
                                    appSecret: '',
                                    meetingId: controller
                                        .myMeetingList[index].meetingId);
                                if (rtcTocken != null) {
                                  await controller.connectMeeting(
                                      context, '', rtcTocken);
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
