import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveModeratorSheet extends StatelessWidget {
  const IsmLiveModeratorSheet({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) => IsmLiveScrollSheet(
          title: 'Moderators',
          itemCount: controller.usersList.length,
          itemBuilder: (context, index) => Container(
            padding: IsmLiveDimens.edgeInsets0_4,
            child: ListTile(
              title: Text(controller.usersList[index].userName),
            ),
          ),
          separatorBuilder: (context, index) => const Divider(
            thickness: 0.5,
          ),
        ),
      );
}
