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
part 'mixins/ongoing_mixin.dart';

class IsmLiveStreamController extends GetxController with GetSingleTickerProviderStateMixin, StreamAPIMixin, StreamJoinMixin, StreamOngoingMixin {
  IsmLiveStreamController(this._viewModel);
  @override
  final IsmLiveStreamViewModel _viewModel;

  IsmLiveConfigData? configuration;

  UserDetails? user;

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
    viewerListController.addListener(() {
      if (viewerListController.position.maxScrollExtent * 0.8 <= viewerListController.position.pixels) {
        if (isViewesApiCall) {
          return;
        }
        isViewesApiCall = true;
        getStreamViewer(streamId: streamId, limit: 10, skip: streamViewersList.length);
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

  void onClick(int index) {
    var member2 = participantTracks.elementAt(index + 1);
    participantTracks[index + 1] = participantTracks.elementAt(0);
    participantTracks[0] = member2;
    update([IsmLiveStreamView.updateId]);
  }

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

  Future<void> setUpListeners({
    required bool isHost,
    required String streamId,
    required EventsListener<RoomEvent> listener,
    required Room room,
  }) async =>
      listener
        ..on<RoomDisconnectedEvent>((event) async {
          IsmLiveLog.info('RoomDisconnectedEvent: $event');
          unawaited(getStreams());
          _streamTimer?.cancel();

          if (isHost) {
            IsmLiveRouteManagement.goToEndStreamView();
          } else {
            Get.back();
          }
        })
        ..on<ParticipantEvent>((event) {
          IsmLiveLog.info('ParticipantEvent: $event');

          sortParticipants(room);
        })
        ..on<ParticipantConnectedEvent>((event) async {
          IsmLiveLog.info('ParticipantConnectedEvent: $event');
        })
        ..on<ParticipantDisconnectedEvent>((event) async {
          IsmLiveLog.info('ParticipantDisconnectedEvent: $event');
        })
        ..on<RoomRecordingStatusChanged>((event) {})
        ..on<LocalTrackPublishedEvent>((_) => sortParticipants(room))
        ..on<LocalTrackUnpublishedEvent>((_) => sortParticipants(room))
        ..on<TrackE2EEStateEvent>((event) {
          IsmLiveLog.info('TrackE2EEStateEvent: $event');
        })
        ..on<ParticipantNameUpdatedEvent>((event) {
          IsmLiveLog.info('ParticipantNameUpdatedEvent: $event');
        })
        ..on<DataReceivedEvent>((event) {
          IsmLiveLog.info('DataReceivedEvent: ${event.topic} $event');
        })
        ..on<AudioPlaybackStatusChanged>((event) async {
          if (!room.canPlaybackAudio) {
            IsmLiveLog('Audio playback failed for iOS Safari ..........');
          }
        });

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

  void onRoomDidUpdate(Room room) {
    sortParticipants(room);
  }

  Future<void> sortParticipants(
    Room room,
  ) async {
    var userMediaTracks = <ParticipantTrack>[];

    for (var participant in room.participants.values) {
      for (var t in participant.videoTracks) {
        userMediaTracks.add(ParticipantTrack(
          participant: participant,
          videoTrack: t.track,
          isScreenShare: false,
        ));
      }
    }
    userMediaTracks.sort((a, b) {
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }

      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      return a.participant.joinedAt.millisecondsSinceEpoch - b.participant.joinedAt.millisecondsSinceEpoch;
    });

    final localParticipantTracks = room.localParticipant?.videoTracks;
    if (localParticipantTracks != null) {
      for (var t in localParticipantTracks) {
        userMediaTracks.add(ParticipantTrack(
          participant: room.localParticipant!,
          videoTrack: t.track,
          isScreenShare: false,
        ));
      }
    }

    participantTracks = [...userMediaTracks];
    update([IsmLiveStreamView.updateId]);
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

  Future<void> disconnectStream({
    required bool isHost,
    required Room room,
    required String streamId,
  }) async {
    var isEnded = false;
    if (isHost) {
      isEnded = await stopStream(streamId);
    } else {
      isEnded = await leaveStream(streamId);
    }
    if (isEnded) {
      await room.disconnect();
    }
  }

  void onExit({
    required bool isHost,
    required Room room,
    required String streamId,
  }) {
    IsmLiveUtility.openBottomSheet(
      IsmLiveCustomButtomSheet(
        title: isHost ? IsmLiveStrings.areYouSureEndStream : IsmLiveStrings.areYouSureLeaveStream,
        leftLabel: 'Cancel',
        rightLabel: isHost ? 'End Stream' : 'Leave Stram',
        leftOnTab: Get.back,
        rightOnTab: () async {
          Get.back();
          await disconnectStream(
            isHost: isHost,
            room: room,
            streamId: streamId,
          );
        },
      ),
      isDismissible: false,
    );
  }
}
