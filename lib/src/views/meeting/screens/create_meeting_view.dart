import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateMeetingScreen extends StatelessWidget {
  const CreateMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GetBuilder<MeetingController>(
          builder: (controller) => Padding(
                padding: IsmLiveDimens.edgeInsets8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const IsmLiveAnimatedText('Meeting Title :'),
                    IsmLiveDimens.boxHeight8,
                    IsmLiveInputField(
                      controller: controller.meetingTitleController,
                      hintText: 'Enter meeting title',
                    ),
                    IsmLiveDimens.boxHeight16,
                    const IsmLiveAnimatedText('Select Member :'),
                    IsmLiveDimens.boxHeight8,
                    IsmLiveInputField(
                      controller: controller.selecteMemberController,
                      onTap: IsLiveRouteManagement.goToSearchUserScreen,
                      readOnly: true,
                      hintText: 'Add A Member',
                    ),
                    IsmLiveDimens.boxHeight32,
                    IsmLiveButton(
                      onTap: controller.createMeetingOnTap,
                      label: 'Create',
                    ),
                  ],
                ),
              )));
}
