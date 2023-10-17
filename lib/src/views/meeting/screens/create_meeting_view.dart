import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class CreateMeetingScreen extends StatelessWidget {
  const CreateMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Padding(
        padding: IsmLiveDimens.edgeInsets8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IsmLiveAnimatedText('Meeting Title :'),
            IsmLiveDimens.boxHeight8,
            IsmLiveInputField(
              controller: TextEditingController(),
              hintText: 'Enter meeting title',
            ),
            IsmLiveDimens.boxHeight16,
            const IsmLiveAnimatedText('Select Member :'),
            IsmLiveDimens.boxHeight8,
            IsmLiveInputField(
              controller: TextEditingController(),
              onTap: IsLiveRouteManagement.goToSearchUserScreen,
              readOnly: true,
              hintText: 'Add A Member',
            ),
            IsmLiveDimens.boxHeight32,
            IsmLiveButton(
              onTap: () {},
              label: 'Create',
            ),
          ],
        ),
      ));
}
