import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCreateStreamFAB extends StatelessWidget {
  const IsmLiveCreateStreamFAB({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        onPressed: () {
          Get.find<IsmLiveStreamController>().startStream();
        },
        child: const Icon(Icons.videocam_rounded),
      );
}
