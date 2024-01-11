import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'mixins/api_mixin.dart';
part 'mixins/join_mixin.dart';
part 'mixins/message_mixin.dart';
part 'mixins/ongoing_mixin.dart';

class IsmLiveStreamController extends GetxController
    with GetSingleTickerProviderStateMixin, StreamAPIMixin, StreamJoinMixin, StreamOngoingMixin, StreamMessageMixin {
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

  // --------- Start Stream Variables ---------------

  final Rx<Room?> _room = Rx<Room?>(null);
  Room? get room => _room.value;
  set room(Room? value) => _room.value = value;

  final Rx<RoomListener?> _listener = Rx<RoomListener?>(null);
  RoomListener? get listener => _listener.value;
  set listener(RoomListener? value) => _listener.value = value;

  // --------- End Stream Variables ---------------

  PageController? pageController;

  var previousStreamIndex = 0;

  bool isHdBroadcast = false;

  bool isRecordingBroadcast = false;

  String? streamId;

  final RxBool _speakerOn = true.obs;
  bool get speakerOn => _speakerOn.value;
  set speakerOn(bool value) => _speakerOn.value = value;

  final RxList<IsmLiveMemberDetailsModel> _streamMembersList = <IsmLiveMemberDetailsModel>[].obs;
  List<IsmLiveMemberDetailsModel> get streamMembersList => _streamMembersList;
  set streamMembersList(List<IsmLiveMemberDetailsModel> value) => _streamMembersList.value = value;

  final RxList<IsmLiveViewerModel> _streamViewersList = <IsmLiveViewerModel>[].obs;
  List<IsmLiveViewerModel> get streamViewersList => _streamViewersList;
  set streamViewersList(List<IsmLiveViewerModel> value) => _streamViewersList.value = value;

  final RxList<IsmLiveMessageModel> _streamMessagesList = <IsmLiveMessageModel>[].obs;
  List<IsmLiveMessageModel> get streamMessagesList => _streamMessagesList;
  set streamMessagesList(List<IsmLiveMessageModel> value) => _streamMessagesList.value = value;

  int get streamIndex => streams.indexWhere((e) => e.streamId == streamId);

  IsmLiveMemberDetailsModel? hostDetails;

  Uint8List? bytes;

  int hearts = 0;

  int orders = 0;

  int followers = 0;

  int earnings = 0;

  int messagesCount = 0;

  Duration duration = Duration.zero;

  CameraController? cameraController;

  final getStreamDebouncer = IsmLiveDebouncer();

  Future? cameraFuture;

  XFile? pickedImage;

  final RxList<ParticipantTrack> _participantTracks = <ParticipantTrack>[].obs;
  List<ParticipantTrack> get participantTracks => _participantTracks;
  set participantTracks(List<ParticipantTrack> value) => _participantTracks.value = value;

  CameraPosition position = CameraPosition.front;

  late TabController tabController;

  var descriptionController = TextEditingController();

  var messageFieldController = TextEditingController();

  ScrollController viewerListController = ScrollController();

  ScrollController messagesListController = ScrollController();

  final _streamRefreshControllers = <IsmLiveStreamType, RefreshController>{};

  final _streams = <IsmLiveStreamType, List<IsmLiveStreamModel>>{};

  RefreshController get streamRefreshController => _streamRefreshControllers[streamType]!;

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
    viewerListController.addListener(() async {
      if (viewerListController.position.maxScrollExtent * 0.8 <= viewerListController.position.pixels) {
        if (isViewesApiCall) {
          return;
        }
        isViewesApiCall = true;

        await getStreamViewer(streamId: streamId, limit: 10, skip: streamViewersList.length);
        isViewesApiCall = false;
      }
    });
    messagesListController.addListener(() {
      if (messagesListController.position.minScrollExtent == messagesListController.position.pixels) {
        if (isViewesApiCall) {
          return;
        }

        isViewesApiCall = true;

        if (messagesCount != 0) {
          fetchMessages(
            showLoading: false,
            getMessageModel: IsmLiveGetMessageModel(
              streamId: streamId,
              skip: messagesCount < 10 ? 0 : (messagesCount - 10),
              limit: _controller.messagesCount < 10 ? _controller.messagesCount : 10,
              sort: 1,
            ),
          );
        }
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

  void onChangeHdBroadcast(bool value) {
    isHdBroadcast = value;
    update([IsmGoLiveView.updateId]);
  }

  void onChangeRecording(bool value) {
    isRecordingBroadcast = value;

    update([IsmGoLiveView.updateId]);
  }

  Future<void> askPublish(bool audioCall) async {
    try {
      if (room == null) {
        return;
      }
      if (!audioCall) {
        await room?.localParticipant?.setCameraEnabled(true);
      } else {
        await room?.localParticipant?.setCameraEnabled(false);
      }
    } catch (error) {
      IsmLiveLog('could not publish video: $error');
    }
    try {
      await room?.localParticipant?.setMicrophoneEnabled(true);
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

  void toggleCamera() async {
    final participant = room?.localParticipant;
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

  Future<void> animateToPage(int index) async => await pageController?.animateToPage(
        index,
        duration: IsmLiveConstants.animationDuration,
        curve: Curves.easeInOut,
      );
}
