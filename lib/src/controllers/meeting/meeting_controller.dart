import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/create_meeting_model.dart';
import 'package:appscrip_live_stream_component/src/models/my_meeting_model.dart';
import 'package:appscrip_live_stream_component/src/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MeetingController extends GetxController {
  MeetingController(this.viewModel);
  List<MyMeetingModel> myMeetingList = [];
  List<UserDetails> userDetailsList = [];
  List<String> membersSelectedList = [];
  List<String> membersNameSelectedList = [];
  final MeetingViewModel viewModel;
  IsmLiveStreamConfig? configuration;
  final String wsUrl = IsmLiveApis.wsUrl;
  ScrollController userListController = ScrollController();
  RefreshController refreshController = RefreshController();
  RefreshController userRefreshController =
      RefreshController(initialRefresh: false);
  TextEditingController meetingTitleController = TextEditingController();
  TextEditingController selecteMemberController = TextEditingController();
  final Debouncer debouncer = Debouncer();

  @override
  void onInit() async {
    super.onInit();

    if (lkPlatformIs(PlatformType.android)) {
      await _checkPremissions();
    }
  }

  void createMeetingOnTap() async {
    if (membersSelectedList.isNotEmpty &&
        meetingTitleController.text.isNotEmpty) {
      await createMeeting(
          meetingDescription: meetingTitleController.text,
          members: membersSelectedList);
    }
  }

  void onMemberSelected(bool value, String id, String name) {
    if (value) {
      membersSelectedList.add(id);
      membersNameSelectedList.add(name);
    } else {
      membersSelectedList.remove(id);
      membersNameSelectedList.remove(name);
    }

    var membersNames = '';
    for (var i in membersNameSelectedList) {
      membersNames = '$i, $membersNames';
    }
    selecteMemberController.text = membersNames;
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

  Future<void> connectMeeting(String token, String meetingId) async {
    try {
      var room = Room(
        roomOptions: RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(
              deviceId: configuration?.communicationConfig.deviceId,
              cameraPosition: CameraPosition.front,
              params: VideoParametersPresets.h720_169,
            ),
            defaultAudioCaptureOptions: AudioCaptureOptions(
              deviceId: configuration?.communicationConfig.deviceId,
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
      room.localParticipant?.setTrackSubscriptionPermissions(
        allParticipantsAllowed: true,
        trackPermissions: [
          const ParticipantTrackPermission('allowed-identity', true, null)
        ],
      );

      var localVideo =
          await LocalVideoTrack.createCameraTrack(const CameraCaptureOptions(
        cameraPosition: CameraPosition.front,
        params: VideoParametersPresets.h720_169,
      ));
      await room.localParticipant?.publishVideoTrack(localVideo);

      await IsLiveRouteManagement.goToRoomPage(room, listener, meetingId);
      // await refreshController.requestRefresh();
      await getMeetingList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
  }

  Future<void> getMeetingList([bool isLoading = true]) async {
    if (configuration != null) {
      var res = await viewModel.getMeetingsList(
          isLoading: isLoading,
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
          deviceId: configuration!.communicationConfig.deviceId,
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

  Future<CreateMeetingModel?> createMeeting({
    required String meetingDescription,
    required List<String> members,
  }) async {
    var res = await viewModel.createMeeting(
        deviceId: configuration!.communicationConfig.deviceId,
        token: configuration!.userConfig.userToken,
        licenseKey: configuration!.communicationConfig.licenseKey,
        appSecret: configuration!.communicationConfig.appSecret,
        meetingDescription: meetingDescription,
        members: members);
    if (res != null) {
      await connectMeeting(res.rtcToken, res.meetingId);
      return res;
    }
    return null;
  }

  bool isApicalling = false;
  Future<void> getMembersList(
      {required int skip,
      required int limit,
      required String searchTag}) async {
    if (isApicalling) {
      return;
    }
    isApicalling = true;
    var res = await viewModel.getMembersList(
        userSecret: configuration!.communicationConfig.userSecret,
        licenseKey: configuration!.communicationConfig.licenseKey,
        appSecret: configuration!.communicationConfig.appSecret,
        skip: skip,
        limit: limit,
        searchTag: searchTag);

    if (res != null) {
      userDetailsList.addAll(res);
    }
    isApicalling = false;
    update();
  }

  Future<bool> deleteMeeting({
    required String meetingId,
    required bool isLoading,
  }) async {
    var res = await viewModel.deleteMeeting(
        userToken: configuration!.userConfig.userToken,
        licenseKey: configuration!.communicationConfig.licenseKey,
        appSecret: configuration!.communicationConfig.appSecret,
        meetingId: meetingId,
        isLoading: isLoading);
    return res;
  }
}
