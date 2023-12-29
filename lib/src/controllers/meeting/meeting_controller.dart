import 'dart:async';

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
  IsmLiveConfigData? configuration;
  final String wsUrl = IsmLiveApis.wsUrl;
  ScrollController userListController = ScrollController();
  RefreshController refreshController = RefreshController();
  RefreshController userRefreshController = RefreshController(initialRefresh: false);
  TextEditingController meetingTitleController = TextEditingController();
  TextEditingController selecteMemberController = TextEditingController();
  final IsmLiveDebouncer debouncer = IsmLiveDebouncer();
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
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      IsmLiveLog('event===================   $event');

      switch (event?.event ?? '') {
        case Event.actionCallIncoming:
          break;
        case Event.actionCallStart:
          break;
        case Event.actionCallAccept:
          var data = event?.body['extra'];

          var meetingId = data['meetingId'];
          var isAudioCall = data['isAudioCall'];

          var tocken = await joinMeeting(meetingId: meetingId);
          if (tocken != null) {
            await connectMeeting(tocken, meetingId, isAudioCall);
          }
          break;
        case Event.actionCallDecline:
          break;
        case Event.actionCallEnded:
          break;
        case Event.actionCallTimeout:
          break;
        case Event.actionCallCallback:
          var data = event?.body['extra'];
          var meetingDescription = data['meetingDescription'];
          var createdBy = data['createdBy'];
          var isAudioCall = data['isAudioCall'];
          await createMeeting(meetingDescription: meetingDescription, members: ['$createdBy'], audioOnly: isAudioCall);

          break;
        case Event.actionCallToggleHold:
          break;
        case Event.actionCallToggleMute:
          break;
        case Event.actionCallToggleDmtf:
          break;
        case Event.actionCallToggleGroup:
          break;
        case Event.actionCallToggleAudioSession:
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          break;
        case Event.actionCallCustom:
          IsmLiveLog('lastttttt');
          break;
      }
    });
  }

  void incomingCall({
    required String id,
    required String name,
    required String imageUrl,
    required String number,
    required String userId,
    required String meetingId,
    required bool isAudioCall,
    required String createdBy,
    required String meetingDescription,
  }) async {
    try {
      var callKitParams = CallKitParams(
        id: id,
        nameCaller: name,
        appName: 'LiveKit call',
        avatar: imageUrl,
        handle: number,
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
        extra: <String, dynamic>{
          'userId': userId,
          'meetingId': meetingId,
          'isAudioCall': isAudioCall,
          'createdBy': createdBy,
          'meetingDescription': meetingDescription,
        },
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl: 'https://i.pravatar.cc/500',
          actionColor: '#4CAF50',
          incomingCallNotificationChannelName: 'Incoming Call',
          missedCallNotificationChannelName: 'Missed Call',
        ),
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
          id: id, nameCaller: name, handle: number, type: 2, extra: <String, dynamic>{'userId': userId}, ios: const IOSParams(handleType: 'generic'));

      await FlutterCallkitIncoming.showMissCallNotification(params);
    } catch (e) {
      IsmLiveLog('error missCall  ====  $e');
    }
  }

  void createMeetingOnTap() async {
    if (membersSelectedList.isNotEmpty && meetingTitleController.text.isNotEmpty) {
      await createMeeting(meetingDescription: meetingTitleController.text, members: membersSelectedList, audioOnly: selectedCallType.last);
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
  Future<void> connectMeeting(String token, String meetingId, bool audioCallOnly) async {
    if (isMeetingOn) {
      return;
    }
    isMeetingOn = true;
    try {
      IsmLiveLog('error  ====  $audioCallOnly');
      var room = Room(
        roomOptions: RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(
              deviceId: configuration?.projectConfig.deviceId,
              cameraPosition: CameraPosition.front,
              params: VideoParametersPresets.h720_169,
            ),
            defaultAudioCaptureOptions: AudioCaptureOptions(
              deviceId: configuration?.projectConfig.deviceId,
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
        trackPermissions: [const ParticipantTrackPermission('allowed-identity', true, null)],
      );

      var localVideo = await LocalVideoTrack.createCameraTrack(const CameraCaptureOptions(
        cameraPosition: CameraPosition.front,
        params: VideoParametersPresets.h720_169,
      ));
      await room.localParticipant?.publishVideoTrack(localVideo);

      await IsmLiveRouteManagement.goToRoomPage(room, listener, meetingId, audioCallOnly);
      isMeetingOn = false;
    } catch (e, st) {
      isMeetingOn = false;
      IsmLiveLog.error(e, st);
    }
  }

  Future<void> getMeetingList([bool isLoading = true]) async {
    if (configuration != null) {
      var res = await viewModel.getMeetingsList(
        isLoading: isLoading,
      );
      myMeetingList = res ?? [];
    }
    update();
  }

  Future<String?> joinMeeting({required String meetingId}) async {
    if (configuration != null) {
      var res = await viewModel.joinMeeting(
        deviceId: configuration!.projectConfig.deviceId,
        meetingId: meetingId,
      );
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
      deviceId: configuration!.projectConfig.deviceId,
      meetingDescription: meetingDescription,
      members: members,
    );
    if (res != null) {
      await connectMeeting(res.rtcToken, res.meetingId, selectedCallType.last);
    }
  }

  bool isApicalling = false;
  Future<void> getMembersList({required int skip, required int limit, required String searchTag}) async {
    if (isApicalling) {
      return;
    }
    isApicalling = true;
    var res = await viewModel.getMembersList(
      skip: skip,
      limit: limit,
      searchTag: searchTag,
    );

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
      meetingId: meetingId,
      isLoading: isLoading,
    );
    return res;
  }
}
