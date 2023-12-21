import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveStreamView extends StatefulWidget {
  const IsmLiveStreamView({
    super.key,
  });

  @override
  State<IsmLiveStreamView> createState() => _IsmLiveStreamViewState();
}

class _IsmLiveStreamViewState extends State<IsmLiveStreamView> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }
    IsmLiveUtility.updateLater(() {
      Get.find<IsmLiveMqttController>().setup(context);
      Get.find<IsmLiveStreamController>().configuration = IsmLiveConfig.of(context);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        appBar: IsmLiveHeader(),
        body: Center(
          child: Text('IsmLive Home View'),
        ),
      );
}
