import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveCreateStreamFAB extends StatelessWidget {
  const IsmLiveCreateStreamFAB({super.key});

  @override
  Widget build(BuildContext context) => const FloatingActionButton(
        onPressed: IsmLiveRouteManagement.goToGoLiveView,
        child: Icon(Icons.videocam_rounded),
      );
}
