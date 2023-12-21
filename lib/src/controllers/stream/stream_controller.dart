import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'mixins/api_mixin.dart';

class IsmLiveStreamController extends GetxController with GetSingleTickerProviderStateMixin, StreamAPIMixin {
  IsmLiveStreamController(this._viewModel);
  final IsmLiveStreamViewModel _viewModel;

  IsmLiveConfigData? configuration;

  UserDetails? user;

  List<ParticipantTrack> participantTracks = [];

  CameraPosition position = CameraPosition.front;

  late TabController tabController;

  final _streamRefreshControllers = <IsmLiveStreamType, RefreshController>{};
  final _streams = <IsmLiveStreamType, List<IsmLiveStreamModel>>{};

  RefreshController get streamRefreshController => _streamRefreshControllers[streamType]!;

  List<IsmLiveStreamModel> get streams => _streams[streamType]!;
  // set streams(List<IsmLiveStreamModel> data) => _streams[streamType] = data;

  double positionX = 20;
  double positionY = 20;

  final Rx<IsmLiveStreamType> _streamType = IsmLiveStreamType.all.obs;
  IsmLiveStreamType get streamType => _streamType.value;
  set streamType(IsmLiveStreamType value) => _streamType.value = value;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      vsync: this,
      length: IsmLiveStreamType.values.length,
    );
    generateVariables();
  }

  void generateVariables() {
    for (var type in IsmLiveStreamType.values) {
      _streamRefreshControllers[type] = RefreshController();
      _streams[type] = [];
    }
  }

  @override
  void onReady() {
    super.onReady();
    IsmLiveUtility.updateLater(startOnInit);
  }

  void startOnInit() async {
    unawaited(getUserDetails());
    unawaited(subscribeUser());
    unawaited(getStreams(streamType));
    tabController.addListener(() {
      streamType = IsmLiveStreamType.values[tabController.index];
    });
  }

  Future<bool> subscribeUser() => _subscribeUser(true);
  Future<bool> unsubscribeUser() => _subscribeUser(false);

  void onClick(int index) {
    var member2 = participantTracks.elementAt(index + 1);
    participantTracks[index + 1] = participantTracks.elementAt(0);
    participantTracks[0] = member2;
    update(['room']);
  }

  Future<void> setUpListeners(
    EventsListener<RoomEvent> listener,
    Room room,
  ) async =>
      listener
        ..on<RoomDisconnectedEvent>((event) async {
          if (event.reason != null) {
            IsmLiveLog('Room disconnected: reason => ${event.reason}');
          }
          Get.back();
        })
        ..on<ParticipantEvent>((event) {
          IsmLiveLog('Participant event');

          sortParticipants(room);
        })
        ..on<RoomRecordingStatusChanged>((event) {})
        ..on<LocalTrackPublishedEvent>((_) => sortParticipants(room))
        ..on<LocalTrackUnpublishedEvent>((_) => sortParticipants(room))
        ..on<TrackE2EEStateEvent>(onE2EEStateEvent)
        ..on<ParticipantNameUpdatedEvent>((event) {
          IsmLiveLog('Participant name updated: ${event.participant.identity}, name => ${event.name}');
        })
        ..on<DataReceivedEvent>((event) {
          var decoded = 'Failed to decode';
          try {
            decoded = utf8.decode(event.data);
          } catch (_) {
            IsmLiveLog('$decoded: $_');
          }
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

  void onE2EEStateEvent(TrackE2EEStateEvent e2eeState) {
    IsmLiveLog('e2ee state: $e2eeState');
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
    update(['room']);
  }

  Future<bool> stopMeeting({
    required bool isLoading,
    required String meetingId,
  }) =>
      _viewModel.stopMeeting(
        isLoading: isLoading,
        meetingId: meetingId,
      );

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

  Future<void> onTapDisconnect(room, meetingId) async {
    var res = await stopMeeting(
      isLoading: true,
      meetingId: meetingId,
    );

    if (res) {
      await room.disconnect();
    }
  }
}
