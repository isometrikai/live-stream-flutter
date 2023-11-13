import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class IsmLiveStreamController extends GetxController {
  IsmLiveStreamController(this._viewModel);
  var meetingController = Get.find<MeetingController>();
  final IsmLiveStreamViewModel _viewModel;

  CameraPosition position = CameraPosition.front;
  double positionX = 20;
  double positionY = 20;
  Future<bool?> stopMeeting(
      {required bool isLoading, required String meetingId}) async {
    var res = await _viewModel.stopMeeting(
        token: meetingController.configuration?.userConfig.userToken ?? '',
        licenseKey:
            meetingController.configuration?.communicationConfig.licenseKey ??
                '',
        appSecret:
            meetingController.configuration?.communicationConfig.appSecret ??
                '',
        isLoading: isLoading,
        meetingId: meetingId);

    return res;
  }

  void onPan(details) {
    positionX += details.delta.dx;
    positionY += details.delta.dy;
    update();
  }

  void disableAudio(LocalParticipant participant) async {
    await participant.setMicrophoneEnabled(false);
  }

  Future<void> enableAudio(LocalParticipant participant) async {
    await participant.setMicrophoneEnabled(true);
  }

  void disableVideo(LocalParticipant participant) async {
    await participant.setCameraEnabled(false);
  }

  void enableVideo(LocalParticipant participant) async {
    await participant.setCameraEnabled(true);
  }

  void toggleCamera(LocalParticipant participant) async {
    final track = participant.videoTracks.firstOrNull?.track;
    if (track == null) return;

    try {
      final newPosition = position.switched();
      await track.setCameraPosition(newPosition);
      position = newPosition;
      update();
    } catch (error) {
      IsmLiveLog('could not restart track: $error');
      return;
    }
  }

  void onTapDisconnect(room, meetingId) async {
    var res = await stopMeeting(isLoading: true, meetingId: meetingId);

    if (res ?? false) {
      await room.disconnect();
    }
  }
}
