import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/my_meeting_model.dart';
import 'package:appscrip_live_stream_component/src/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
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
  final List<Widget> fruits = <Widget>[
    const Text('VideoCall'),
    const Text('AudioCall'),
  ];
  final List<bool> selectedCallType = <bool>[true, false];
  @override
  void onInit() async {
    super.onInit();

    if (lkPlatformIs(PlatformType.android)) {
      await _checkPremissions();
    }
    callLisner();
  }

  void callLisner() async {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      switch (event!.event) {
        case Event.actionCallIncoming:
          IsmLiveLog('11111111111111111111111111');
          break;
        case Event.actionCallStart:
          IsmLiveLog('222222222222222222222222222');

          break;
        case Event.actionCallAccept:
          IsmLiveLog('333333333333');
          break;
        case Event.actionCallDecline:
          break;
        case Event.actionCallEnded:
          IsmLiveLog('44444444444444444444444');
          break;
        case Event.actionCallTimeout:
          IsmLiveLog('5555555555555');
          break;
        case Event.actionCallCallback:
          IsmLiveLog('6666666666666666666666');
          break;
        case Event.actionCallToggleHold:
          break;
        case Event.actionCallToggleMute:
          // TODO: only iOS
          break;
        case Event.actionCallToggleDmtf:
          // TODO: only iOS
          break;
        case Event.actionCallToggleGroup:
          // TODO: only iOS
          break;
        case Event.actionCallToggleAudioSession:
          // TODO: only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: only iOS
          break;
        case Event.actionCallCustom:
          IsmLiveLog('lastttttt');
          break;
      }
    });
  }

  void incomingCall(String id) async {
    try {
      var callKitParams = CallKitParams(
        id: id,
        nameCaller: 'Hien Nguyen',
        appName: 'Callkit',
        avatar: 'https://i.pravatar.cc/100',
        handle: '0123456789',
        type: 0,
        textAccept: 'Accept',
        textDecline: 'Decline',
        missedCallNotification: const NotificationParams(
          showNotification: true,
          isShowCallback: true,
          subtitle: 'Missed call',
          callbackText: 'Call back',
        ),
        duration: 30000,
        extra: <String, dynamic>{'userId': '1a2b3c4d'},
        headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
        android: const AndroidParams(
            isCustomNotification: true,
            isShowLogo: false,
            ringtonePath: 'system_ringtone_default',
            backgroundColor: '#0955fa',
            backgroundUrl: 'https://i.pravatar.cc/500',
            actionColor: '#4CAF50',
            incomingCallNotificationChannelName: 'Incoming Call',
            missedCallNotificationChannelName: 'Missed Call'),
        ios: const IOSParams(
          iconName: 'CallKitLogo',
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default',
        ),
      );
      await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
    } catch (e) {
      IsmLiveLog('error incomingcall  ====  $e');
    }
  }

  void missCall({
    required String id,
    required String name,
    required String number,
    required String userId,
  }) async {
    try {
      var params = CallKitParams(
          id: id,
          nameCaller: name,
          handle: number,
          type: 2,
          extra: <String, dynamic>{'userId': userId},
          ios: const IOSParams(handleType: 'generic'));

      await FlutterCallkitIncoming.showMissCallNotification(params);
    } catch (e) {
      IsmLiveLog('error missCall  ====  $e');
    }
  }

  void createMeetingOnTap() async {
    if (membersSelectedList.isNotEmpty &&
        meetingTitleController.text.isNotEmpty) {
      await createMeeting(
          meetingDescription: meetingTitleController.text,
          members: membersSelectedList,
          audioOnly: selectedCallType.last);
    }
  }

  void toggleAction(int index) {
    for (var i = 0; i < selectedCallType.length; i++) {
      selectedCallType[i] = i == index;
    }

    IsmLiveLog(selectedCallType);
    update();
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

  bool isMeetingOn = false;
  Future<void> connectMeeting(
      String token, String meetingId, bool audioCallOnly) async {
    if (isMeetingOn) {
      return;
    }
    isMeetingOn = true;
    try {
      IsmLiveLog('error  ====  $audioCallOnly');
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

      await IsLiveRouteManagement.goToRoomPage(
          room, listener, meetingId, audioCallOnly);
      isMeetingOn = false;
      await refreshController.requestRefresh();
    } catch (e, st) {
      isMeetingOn = false;
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

  Future<void> createMeeting({
    required String meetingDescription,
    required List<String> members,
    bool audioOnly = false,
  }) async {
    var res = await viewModel.createMeeting(
        audioOnly: audioOnly,
        deviceId: configuration!.communicationConfig.deviceId,
        token: configuration!.userConfig.userToken,
        licenseKey: configuration!.communicationConfig.licenseKey,
        appSecret: configuration!.communicationConfig.appSecret,
        meetingDescription: meetingDescription,
        members: members);
    if (res != null) {
      await connectMeeting(res.rtcToken, res.meetingId, selectedCallType.last);
    }
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
