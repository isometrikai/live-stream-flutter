import 'dart:async';
import 'dart:developer';

import 'package:appscrip_live_stream_component/src/res/res.dart';
import 'package:appscrip_live_stream_component/src/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class ControlsWidget extends StatefulWidget {
  const ControlsWidget(
    this.room,
    this.participant, {
    Key? key,
  }) : super(key: key);
  //
  final Room room;
  final LocalParticipant participant;

  @override
  State<StatefulWidget> createState() => _ControlsWidgetState();
}

class _ControlsWidgetState extends State<ControlsWidget> {
  //
  CameraPosition position = CameraPosition.front;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    participant.addListener(_onChange);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    participant.removeListener(_onChange);
    super.dispose();
  }

  LocalParticipant get participant => widget.participant;

  void _onChange() {
    // trigger refresh
    setState(() {});
  }

  bool get isMuted => participant.isMuted;

  void _disableAudio() async {
    await participant.setMicrophoneEnabled(false);
  }

  Future<void> _enableAudio() async {
    await participant.setMicrophoneEnabled(true);
  }

  void _disableVideo() async {
    await participant.setCameraEnabled(false);
  }

  void _enableVideo() async {
    await participant.setCameraEnabled(true);
  }

  void _toggleCamera() async {
    //
    final track = participant.videoTracks.firstOrNull?.track;
    if (track == null) return;

    try {
      final newPosition = position.switched();
      await track.setCameraPosition(newPosition);
      setState(() {
        position = newPosition;
      });
    } catch (error) {
      log('could not restart track: $error');
      return;
    }
  }

  void _onTapDisconnect() async {
    await widget.room.disconnect();
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: IsmLiveDimens.edgeInsetsB20,
        width: Get.width,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: IsmLiveDimens.thirty,
          children: [
            CustomIconButton(
              icon: Icon(
                Icons.phone,
                color: Colors.white,
                size: IsmLiveDimens.twentyFive,
              ),
              onTap: _onTapDisconnect,
              color: Colors.red,
              radius: IsmLiveDimens.fifty,
            ),
            participant.isMicrophoneEnabled()
                ? CustomIconButton(
                    icon: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: IsmLiveDimens.twentyFive,
                    ),
                    onTap: _disableAudio,
                  )
                : CustomIconButton(
                    icon: Icon(
                      Icons.mic_off,
                      color: Colors.white,
                      size: IsmLiveDimens.twentyFive,
                    ),
                    onTap: _enableAudio,
                  ),
            participant.isCameraEnabled()
                ? CustomIconButton(
                    icon: Icon(
                      Icons.videocam_sharp,
                      color: Colors.white,
                      size: IsmLiveDimens.twentyFive,
                    ),
                    onTap: _disableVideo,
                  )
                : CustomIconButton(
                    icon: Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: IsmLiveDimens.twentyFive,
                    ),
                    onTap: _enableVideo,
                  ),
            CustomIconButton(
              icon: Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
                size: IsmLiveDimens.twentyFive,
              ),
              onTap: _toggleCamera,
            ),
          ],
        ),
      );
}
