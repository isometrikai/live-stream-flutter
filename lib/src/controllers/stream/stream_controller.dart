import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/stream/get_message_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'mixins/api_mixin.dart';
part 'mixins/join_mixin.dart';
part 'mixins/ongoing_mixin.dart';

class IsmLiveStreamController extends GetxController
    with
        GetSingleTickerProviderStateMixin,
        StreamAPIMixin,
        StreamJoinMixin,
        StreamOngoingMixin {
  IsmLiveStreamController(this._viewModel);

  final IsmLiveStreamViewModel _viewModel;

  IsmLiveMqttController? get _mqttController {
    if (Get.isRegistered<IsmLiveMqttController>()) {
      return Get.find<IsmLiveMqttController>();
    }
    return null;
  }

  IsmLiveConfigData? configuration;

  UserDetails? user;

  bool isHdBroadcast = false;

  bool isRecordingBroadcast = false;

  String? streamId;

  final RxBool _speakerOn = true.obs;
  bool get speakerOn => _speakerOn.value;
  set speakerOn(bool value) => _speakerOn.value = value;

  final RxList<IsmLiveMemberDetailsModel> _streamMembersList =
      <IsmLiveMemberDetailsModel>[].obs;
  List<IsmLiveMemberDetailsModel> get streamMembersList => _streamMembersList;
  set streamMembersList(List<IsmLiveMemberDetailsModel> value) =>
      _streamMembersList.value = value;

  final RxList<IsmLiveViewerModel> _streamViewersList =
      <IsmLiveViewerModel>[].obs;
  List<IsmLiveViewerModel> get streamViewersList => _streamViewersList;
  set streamViewersList(List<IsmLiveViewerModel> value) =>
      _streamViewersList.value = value;

  final RxList<IsmLiveMessageModel> _streamMessagesList =
      <IsmLiveMessageModel>[].obs;
  List<IsmLiveMessageModel> get streamMessagesList => _streamMessagesList;
  set streamMessagesList(List<IsmLiveMessageModel> value) =>
      _streamMessagesList.value = value;

  int get streamIndex => streams.indexWhere((e) => e.streamId == streamId);

  int get streamIndex => streams.indexWhere((e) => e.streamId == streamId);

  IsmLiveMemberDetailsModel? hostDetails;

  Uint8List? bytes;

  int hearts = 0;

  int orders = 0;

  int followers = 0;

  int earnings = 0;

  Duration duration = Duration.zero;

  CameraController? cameraController;

  final getStreamDebouncer = IsmLiveDebouncer();

  Future? cameraFuture;

  XFile? pickedImage;

  List<ParticipantTrack> participantTracks = [];

  CameraPosition position = CameraPosition.front;

  late TabController tabController;

  var descriptionController = TextEditingController();

  var messageFieldController = TextEditingController();

  ScrollController viewerListController = ScrollController();

  final _streamRefreshControllers = <IsmLiveStreamType, RefreshController>{};

  final _streams = <IsmLiveStreamType, List<IsmLiveStreamModel>>{};

  RefreshController get streamRefreshController =>
      _streamRefreshControllers[streamType]!;

  List<IsmLiveStreamModel> get streams => _streams[streamType]!;

  bool? isHost;

  double positionX = 20;
  double positionY = 20;

  final Rx<IsmLiveStreamType> _streamType = IsmLiveStreamType.all.obs;
  IsmLiveStreamType get streamType => _streamType.value;
  set streamType(IsmLiveStreamType value) => _streamType.value = value;

  bool isModerationWarningVisible = true;

  Timer? _streamTimer;

  final Rx<Duration> _streamDuration = Duration.zero.obs;
  Duration get streamDuration => _streamDuration.value;
  set streamDuration(Duration value) => _streamDuration.value = value;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      vsync: this,
      length: IsmLiveStreamType.values.length,
    );
    generateVariables();
  }

  @override
  void onReady() {
    super.onReady();
    IsmLiveUtility.updateLater(startOnInit);
  }

  bool isViewesApiCall = false;

  void pagination(String streamId) {
    viewerListController.addListener(() {
      if (viewerListController.position.maxScrollExtent * 0.8 <=
          viewerListController.position.pixels) {
        if (isViewesApiCall) {
          return;
        }
        isViewesApiCall = true;
        getStreamViewer(
            streamId: streamId, limit: 10, skip: streamViewersList.length);
        isViewesApiCall = false;
      }
    });
  }

  void startOnInit() async {
    unawaited(getUserDetails());
    unawaited(subscribeUser());
    unawaited(getStreams());
    tabController.addListener(() {
      streamType = IsmLiveStreamType.values[tabController.index];
    });
  }

  void generateVariables() {
    for (var type in IsmLiveStreamType.values) {
      _streamRefreshControllers[type] = RefreshController();
      _streams[type] = [];
    }
  }

  Future<bool> subscribeUser() => _subscribeUser(true);

  Future<bool> unsubscribeUser() => _subscribeUser(false);

  void onFieldSubmit({
    required String streamId,
    required String body,
    required int messageType,
  }) async {
    var res = await sendMessage(
      showLoading: false,
      sendMessageModel: IsmLiveSendMessageModel(
        streamId: streamId,
        body: body,
        searchableTags: [body],
        metaData: const IsmLiveMetaData(),
        customType: body,
        deviceId: configuration?.projectConfig.deviceId ?? '',
        messageType: messageType,
      ),
    );

    if (res) {
      await fetchMessages(
          showLoading: false,
          getMessageModel: IsmLiveGetMessageModel(
              streamId: streamId,
              sort: -1,
              skip: 0,
              limit: 10,
              senderIdsExclusive: false));
      messageFieldController.clear();
    }
  }

  void onChangeHdBroadcast(
    bool value,
  ) {
    isHdBroadcast = value;
    update([IsmGoLiveView.updateId]);
  }

  void onChangeRecording(
    bool value,
  ) {
    isRecordingBroadcast = value;

    update([IsmGoLiveView.updateId]);
  }

  Future<void> askPublish(Room room, bool audioCall) async {
    try {
      if (!audioCall) {
        await room.localParticipant?.setCameraEnabled(true);
      } else {
        await room.localParticipant?.setCameraEnabled(false);
      }
    } catch (error) {
      IsmLiveLog('could not publish video: $error');
    }
    try {
      await room.localParticipant?.setMicrophoneEnabled(true);
    } catch (error) {
      IsmLiveLog('could not publish audio: $error');
    }
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

  void toggleCamera(LocalParticipant? participant) async {
    if (participant == null) {
      return;
    }
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
}
