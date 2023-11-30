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
                    IsmLiveDimens.boxHeight20,
                    ToggleButtons(
                      direction: Axis.horizontal,
                      onPressed: (int index) {
                        controller.toggleAction(index);
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.purple,
                      selectedColor: Colors.white,
                      fillColor: Colors.green[200],
                      color: Colors.green[400],
                      constraints: const BoxConstraints(
                        minHeight: 40.0,
                        minWidth: 80.0,
                      ),
                      isSelected: controller.selectedCallType,
                      children: controller.fruits,
                    ),
                    IsmLiveDimens.boxHeight32,
                    IsmLiveButton(
                      onTap: () {
                        controller.createMeetingOnTap();
                      },
                      label: 'Create',
                    ),
                  ],
                ),
              )));
}
