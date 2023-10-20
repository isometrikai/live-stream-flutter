import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/my_meeting_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

class MeetingController extends GetxController {
  MeetingController(this.viewModel);
  List<MyMeetingModel> myMeetingList = [];
  List<UserDetails> userDetailsList = [];
  List<String> membersSelectedList = [];
  final MeetingViewModel viewModel;
  IsmLiveStreamConfig? configuration;
  final String wsUrl = IsmLiveConstants.wsUrl;
  ScrollController userListController = ScrollController();

  @override
  void onInit() async {
    super.onInit();

    if (lkPlatformIs(PlatformType.android)) {
      await _checkPremissions();
    }

    await getMembersList(limit: 10, skip: 0, searchTag: '');
  }

  void onMemberSelected(bool value, String id) {
    if (value) {
      membersSelectedList.add(id);
    } else {
      membersSelectedList.remove(id);
    }

    IsmLiveLog.info('-------------> $membersSelectedList');
    update();
  }

  Future<void> _checkPremissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isPermanentlyDenied) {
      IsmLiveLog('Bluetooth Permission disabled');
    }

    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      IsmLiveLog('Bluetooth Connect Permission disabled');
    }

    status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      IsmLiveLog('Camera Permission disabled');
    }

    status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      IsmLiveLog('Microphone Permission disabled');
    }
  }

  Future<void> connectMeeting(
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
        wsUrl,
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

      await IsLiveRouteManagement.goToRoomPage(room, listener);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
  }

  Future<void> getMeetingList() async {
    if (configuration != null) {
      var res = await viewModel.getMeetingsList(
          token: configuration!.userConfig.userToken,
          licenseKey: configuration!.communicationConfig.licenseKey,
          appSecret: configuration!.communicationConfig.appSecret);
      myMeetingList = res ?? [];
    }
    update();
  }

  Future<String?> joinMeeting({required String meetingId}) async {
    if (configuration != null) {
      var res = await viewModel.joinMeeting(
          token: configuration!.userConfig.userToken,
          licenseKey: configuration!.communicationConfig.licenseKey,
          appSecret: configuration!.communicationConfig.appSecret,
          meetingId: meetingId);
      if (res != null) {
        return res;
      }
    }
    return null;
  }

  Future<void> getMembersList(
      {required int skip,
      required int limit,
      required String searchTag}) async {
    var res = await viewModel.getMembersList(
        userSecret: configuration!.communicationConfig.userSecret,
        licenseKey: configuration!.communicationConfig.licenseKey,
        appSecret: configuration!.communicationConfig.appSecret,
        skip: skip,
        limit: limit,
        searchTag: searchTag);

    if (res != null) {
      userDetailsList = res;
    }
    update();
  }
}
