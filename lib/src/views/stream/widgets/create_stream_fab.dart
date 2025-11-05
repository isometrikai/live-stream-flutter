import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveCreateStream extends StatelessWidget {
  const IsmLiveCreateStream({super.key});

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
    onTap: IsmLiveRouteManagement.goToGoLiveView,
    child: Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        boxShadow: [
          const BoxShadow(
              color: Colors.black12,
              spreadRadius: 3,
              blurRadius: 3,
              offset: Offset(0, 1)),
        ],
        borderRadius: BorderRadius.circular(IsmLiveDimens.ten),
        color: Colors.black,
      ),
      child: const Icon(
        Icons.videocam_rounded,
        color: Colors.white,
      ),
    ),
  );
}
