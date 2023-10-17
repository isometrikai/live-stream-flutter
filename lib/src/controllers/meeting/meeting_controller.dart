import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/my_meeting_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class MeetingController extends GetxController {
  MeetingController(this.viewModel);
  List<MyMeetingModel> myMeetingList = [];
  final MeetingViewModel viewModel;

  Future<void> connectMeeting(
    BuildContext context,
    String url,
    String token,
  ) async {
    try {
      var room = Room(
        roomOptions: RoomOptions(
            defaultCameraCaptureOptions: const CameraCaptureOptions(
              deviceId: '',
              cameraPosition: CameraPosition.front,
              params: VideoParametersPresets.h720_169,
            ),
            defaultAudioCaptureOptions: const AudioCaptureOptions(
              deviceId: '',
              noiseSuppression: true,
              echoCancellation: true,
              autoGainControl: true,
              highPassFilter: true,
              typingNoiseDetection: true,
            ),
            defaultVideoPublishOptions: VideoPublishOptions(
              videoEncoding: VideoParametersPresets.h720_169.encoding,
              videoSimulcastLayers: [
                VideoParametersPresets.h180_169,
                VideoParametersPresets.h360_169,
              ],
            ),
            defaultAudioPublishOptions: const AudioPublishOptions(
              dtx: true,
            )),
      );

      // Create a Listener before connecting
      final listener = room.createListener();

      // Try to connect to the room
      await room.connect(
        url,
        token,
      );
      room.localParticipant!.setTrackSubscriptionPermissions(
        allParticipantsAllowed: false,
        trackPermissions: [
          const ParticipantTrackPermission('allowed-identity', true, null)
        ],
      );

      var localVideo =
          await LocalVideoTrack.createCameraTrack(const CameraCaptureOptions(
        cameraPosition: CameraPosition.front,
        params: VideoParametersPresets.h720_169,
      ));
      await room.localParticipant!.publishVideoTrack(localVideo);
      var localAudio = await LocalAudioTrack.create();
      await room.localParticipant!.publishAudioTrack(localAudio);
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => RoomPage(room, listener),
        ),
      );
    } catch (e, st) {
      print('*************** $e');
      print('#####     $st');
    }
  }

  Future<void> getMeetingList(
      {required String token,
      required String licenseKey,
      required String appSecret}) async {
    var res = await viewModel.getMeetingsList(
        token: token, licenseKey: licenseKey, appSecret: appSecret);
    myMeetingList = res ?? [];
  }

  Future<String?> joinMeeting(
      {required String token,
      required String licenseKey,
      required String appSecret,
      required String meetingId}) async {
    var res = await viewModel.joinMeeting(
        token: token,
        licenseKey: licenseKey,
        appSecret: appSecret,
        meetingId: meetingId);
    if (res != null) {
      return res;
    }
    return null;
  }
}
