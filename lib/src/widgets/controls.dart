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

  bool _speakerphoneOn = false;

  @override
  void initState() {
    super.initState();
    participant.addListener(_onChange);

    _speakerphoneOn = Hardware.instance.speakerOn ?? false;
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

  void _setSpeakerphoneOn() {
    _speakerphoneOn = !_speakerphoneOn;

    widget.room.setSpeakerOn(_speakerphoneOn);
    // Hardware.instance.setSpeakerphoneOn(_speakerphoneOn);
    setState(() {});
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomIconButton(
              icon: const Icon(
                Icons.phone,
                color: Colors.white,
                size: 25,
              ),
              onTap: _onTapDisconnect,
              color: Colors.red,
              radius: 50,
            ),
            participant.isMicrophoneEnabled()
                ? CustomIconButton(
                    icon: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 25,
                    ),
                    onTap: _disableAudio,
                  )
                : CustomIconButton(
                    icon: const Icon(
                      Icons.mic_off,
                      color: Colors.white,
                      size: 25,
                    ),
                    onTap: _enableAudio,
                  ),
            participant.isCameraEnabled()
                ? CustomIconButton(
                    icon: const Icon(
                      Icons.videocam_sharp,
                      color: Colors.white,
                      size: 25,
                    ),
                    onTap: _disableVideo,
                  )
                : CustomIconButton(
                    icon: const Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                      size: 25,
                    ),
                    onTap: _enableVideo,
                  ),
            !_speakerphoneOn
                ? CustomIconButton(
                    icon: const Icon(
                      Icons.volume_off,
                      color: Colors.white,
                      size: 25,
                    ),
                    onTap: _setSpeakerphoneOn,
                  )
                : CustomIconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 25,
                    ),
                    onTap: _setSpeakerphoneOn,
                  ),
            CustomIconButton(
              icon: const Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
                size: 25,
              ),
              onTap: _toggleCamera,
            ),
          ],
        ),
      );
}
