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
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateMeetingScreen(),
                    ));
              },
              icon: const Icon(
                Icons.add,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        body: GetBuilder<MeetingController>(
          builder: (controller) =>

              //  Padding(
              //       padding: IsmLiveDimens.edgeInsets8_4,
              //       child: controller.myMeetingList.isEmpty
              //           ? const Center(
              //               child: Text('No meetings found'),
              //             )
              //           :

              ListView.separated(
                  itemBuilder: (context, index) => Container(
                        padding: IsmLiveDimens.edgeInsets4,
                        color: IsmLiveColors.white,
                        height: IsmLiveDimens.fifty,
                        child: Row(
                          children: [
                            // Text(controller
                            //     .myMeetingList[index].meetingDescription),
                            const Text('scjhdscksdch'),
                            const Spacer(),
                            SizedBox(
                              width: IsmLiveDimens.hundred,
                              child: IsmLiveButton(
                                onTap: () {
                                  log('###################################');
                                  controller.connectMeeting(
                                      context,
                                      'wss://streaming.isometrik.io',
                                      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJBUElnOWhCU050S0NxOVgiLCJleHAiOjE2OTc0ODE5NzEsImlhdCI6MTY5NzQ2MDM3MSwiaXNzIjoiQVBJZzloQlNOdEtDcTlYIiwianRpIjoiOTg5Y2MxMjItYjA3Yi00MmJlLTk1N2YtYjcyYTQzY2M4NzdmIiwibmFtZSI6InJhbmRvbVVzZXIyIiwibmJmIjoxNjk3NDYwMzcwLCJzdWIiOiI2NGY4NzU4MTQyMjlkNDAwMDFjMWM2NGEiLCJ0eXAiOiJhY2Nlc3MiLCJ2aWRlbyI6eyJjYW5QdWJsaXNoIjp0cnVlLCJjYW5QdWJsaXNoRGF0YSI6ZmFsc2UsImNhblN1YnNjcmliZSI6dHJ1ZSwiaGlkZGVuIjpmYWxzZSwicmVjb3JkZXIiOmZhbHNlLCJyb29tIjoiNjUyZDMwOTNkOGRkZTkwMDAxYzFlNGFmIiwicm9vbUFkbWluIjpmYWxzZSwicm9vbUNyZWF0ZSI6ZmFsc2UsInJvb21Kb2luIjp0cnVlLCJyb29tTGlzdCI6ZmFsc2UsInJvb21SZWNvcmQiOmZhbHNlfX0.Q-YoSFWnyUU2aO_ZpuhwKzyp80ae6emFj7x4qeAruT4');
                                },
                                label: 'Join',
                              ),
                            ),
                          ],
                        ),
                      ),
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: 5 // controller.myMeetingList.length,
                  ),
        ),
      );
}
