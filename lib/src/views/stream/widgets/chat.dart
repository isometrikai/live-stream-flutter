import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveChat extends StatelessWidget {
  const IsmLiveChat({super.key, required this.messagesList});
  final List<IsmLiveMessageModel> messagesList;

  @override
  Widget build(BuildContext context) => Obx(
        () => SizedBox(
          height: Get.height * 0.2,
          width: Get.width * 0.75,
          child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (_, index) => Text(messagesList[index].body),
              itemCount: messagesList.length),
        ),
      );
}
