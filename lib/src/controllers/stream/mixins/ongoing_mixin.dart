part of '../stream_controller.dart';

mixin StreamOngoingMixin {
  IsmLiveStreamController get _controller => Get.find();

  final _participantDebouncer = IsmLiveDebouncer();

  void initializeStream({
    required String streamId,
    required Room room,
    required RoomListener listener,
    required bool isHost,
  }) async {
    _controller.pagination(streamId);
    unawaited(setUpListeners(
      listener: listener,
      room: room,
      isHost: isHost,
    ));
    await sortParticipants(room, isHost);
    if (lkPlatformIsMobile()) {
      unawaited(_controller.toggleSpeaker(room: room, value: true));
    }
    _controller.update([IsmLiveStreamView.updateId]);
  }

  Future<void> setUpListeners({
    required RoomListener listener,
    required Room room,
    required bool isHost,
  }) async =>
      listener
        ..on<RoomDisconnectedEvent>((event) async {
          IsmLiveLog.info('RoomDisconnectedEvent: $event');
        })
        ..on<ParticipantEvent>((event) {
          IsmLiveLog.info('ParticipantEvent: $event');
          sortParticipants(room, isHost);
        })
        ..on<ParticipantConnectedEvent>((event) async {
          IsmLiveLog.info('ParticipantConnectedEvent: $event');
        })
        ..on<ParticipantDisconnectedEvent>((event) async {
          IsmLiveLog.info('ParticipantDisconnectedEvent: $event');
        })
        ..on<RoomRecordingStatusChanged>((event) {})
        ..on<LocalTrackPublishedEvent>((_) => sortParticipants(room, isHost))
        ..on<LocalTrackUnpublishedEvent>((_) => sortParticipants(room, isHost))
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
          IsmLiveLog.info('DataReceivedEvent: ${event.isPlaying} $event');
          if (!room.canPlaybackAudio) {
            IsmLiveLog.error('Audio playback failed for iOS Safari ..........');
          }
        });

  Future<void> sortParticipants(
    Room room,
    bool isHost,
  ) async {
    _participantDebouncer.run(() => _sortParticipants(room, isHost));
  }

  Future<void> _sortParticipants(Room room, bool isHost) async {
    var userMediaTracks = <ParticipantTrack>[];

    if (isHost) {
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
    } else {
      for (var participant in room.participants.values) {
        for (var t in participant.videoTracks) {
          userMediaTracks.add(ParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: false,
          ));
        }
      }
    }

    _controller.participantTracks = [...userMediaTracks];
    _controller.update([IsmLiveStreamView.updateId]);
  }

  String controlIcon(IsmLiveStreamOption option) {
    switch (option) {
      case IsmLiveStreamOption.gift:
      case IsmLiveStreamOption.multiLive:
      case IsmLiveStreamOption.share:
      case IsmLiveStreamOption.members:
      case IsmLiveStreamOption.favourite:
      case IsmLiveStreamOption.settings:
      case IsmLiveStreamOption.rotateCamera:
      case IsmLiveStreamOption.vs:
        return option.icon;
      case IsmLiveStreamOption.speaker:
        if (_controller.speakerOn) {
          return IsmLiveAssetConstants.speakerOn;
        }
        return IsmLiveAssetConstants.speakerOff;
    }
  }

  Future<void> addViewers(List<IsmLiveViewerModel> viewers, [List<String>? updateIds]) async {
    _controller.streamViewersList.addAll(viewers);
    _controller.streamViewersList = _controller.streamViewersList.toSet().toList();
  }

  Future<void> toggleSpeaker({
    required Room room,
    bool? value,
  }) async {
    _controller.speakerOn = value ?? !_controller.speakerOn;

    _controller.speakerOn
        ? await room.participants.values.first.audioTracks.first.enable()
        : await room.participants.values.first.audioTracks.first.disable();

    //if above code is not working in iOS use this
    // await Hardware.instance.setPreferSpeakerOutput(_controller.speakerOn);
    // await Hardware.instance.setSpeakerphoneOn(_controller.speakerOn);
  }

  Future onOptionTap(
    IsmLiveStreamOption option, {
    required Room room,
    LocalParticipant? participant,
  }) async {
    switch (option) {
      case IsmLiveStreamOption.gift:
      case IsmLiveStreamOption.multiLive:
      case IsmLiveStreamOption.share:
      case IsmLiveStreamOption.members:
      case IsmLiveStreamOption.favourite:
      case IsmLiveStreamOption.settings:
      case IsmLiveStreamOption.vs:
        break;
      case IsmLiveStreamOption.rotateCamera:
        _controller.toggleCamera(participant);
        break;
      case IsmLiveStreamOption.speaker:
        await toggleSpeaker(room: room);
        break;
    }
  }

  void onStreamScroll({
    required int index,
    required Room room,
  }) async {
    IsmLiveUtility.showLoader();
    final didLeft = await _controller.leaveStream(_controller.streamId ?? '');
    if (!didLeft) {
      IsmLiveLog.error('Cannot leave stream');
      return;
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

  Future<void> disconnectStream({
    required bool isHost,
    required Room room,
    required String streamId,
    bool goBack = true,
  }) async {
    var isEnded = false;
    if (isHost) {
      isEnded = await _controller.stopStream(streamId);
    } else {
      isEnded = await _controller.leaveStream(streamId);
    }
    if (isEnded) {
      unawaited(_controller._mqttController?.unsubscribeStream(streamId));
      _controller.isHost = null;
      _controller.isMeetingOn = false;
      _controller.streamId = null;
      await room.disconnect();
      if (goBack) {
        closeStreamView(isHost);
      }
    }
  }

  void closeStreamView(bool isHost) {
    _controller._streamTimer?.cancel();
    if (isHost) {
      IsmLiveRouteManagement.goToEndStreamView();
    } else {
      Get.back();
    }
  }
}
