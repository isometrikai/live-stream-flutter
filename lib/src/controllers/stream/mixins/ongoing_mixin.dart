part of '../stream_controller.dart';

mixin StreamOngoingMixin {
  IsmLiveStreamController get _controller => Get.find();

  final _participantDebouncer = IsmLiveDebouncer();

  void initializeStream({
    required String streamId,
    required bool isHost,
  }) async {
    _controller.pagination(streamId);
    unawaited(setUpListeners(
      isHost: isHost,
    ));
    if (!isHost) {
      await _controller.fetchMessagesCount(
        showLoading: false,
        getMessageModel: IsmLiveGetMessageModel(streamId: streamId),
      );

      if (_controller.messagesCount != 0) {
        await _controller.fetchMessages(
          showLoading: false,
          getMessageModel: IsmLiveGetMessageModel(
              streamId: streamId,
              sort: 1,
              skip: _controller.messagesCount < 10 ? 0 : (_controller.messagesCount - 10),
              limit: 10,
              senderIdsExclusive: false),
        );
      }
    }
    await sortParticipants(isHost);
    if (lkPlatformIsMobile()) {
      unawaited(_controller.toggleSpeaker(value: true));
    }
    _controller.update([IsmLiveStreamView.updateId]);
  }

  Future<void> setUpListeners({
    required bool isHost,
  }) async =>
      _controller.listener
        ?..on<RoomDisconnectedEvent>((event) async {
          IsmLiveLog.info('RoomDisconnectedEvent: $event');
        })
        ..on<ParticipantEvent>((event) {
          IsmLiveLog.info('ParticipantEvent: $event');
          sortParticipants(isHost);
        })
        ..on<ParticipantConnectedEvent>((event) async {
          IsmLiveLog.info('ParticipantConnectedEvent: $event');
        })
        ..on<ParticipantDisconnectedEvent>((event) async {
          IsmLiveLog.info('ParticipantDisconnectedEvent: $event');
        })
        ..on<RoomRecordingStatusChanged>((event) {})
        ..on<LocalTrackPublishedEvent>((_) => sortParticipants(isHost))
        ..on<LocalTrackUnpublishedEvent>((_) => sortParticipants(isHost))
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
          if (_controller.room == null) {
            return;
          }
          if (!_controller.room!.canPlaybackAudio) {
            IsmLiveLog.error('Audio playback failed for iOS Safari ..........');
          }
        });

  Future<void> sortParticipants(
    bool isHost,
  ) async {
    _participantDebouncer.run(() => _sortParticipants(isHost));
  }

  Future<void> _sortParticipants(bool isHost) async {
    final room = _controller.room;
    if (room == null) {
      return;
    }
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

  Future<void> addViewers(List<IsmLiveViewerModel> viewers) async {
    _controller.streamViewersList.addAll(viewers);
    _controller.streamViewersList = _controller.streamViewersList.toSet().toList();
  }

  Future<void> addMessages(
    List<IsmLiveMessageModel> messages, [
    bool isMqtt = true,
  ]) async {
    if (isMqtt) {
      _controller.streamMessagesList.addAll(messages);
    } else {
      _controller.streamMessagesList.insertAll(0, messages);
    }
    _controller.streamMessagesList = _controller.streamMessagesList.toSet().toList();
  }

  void addHeart(IsmLiveMessageModel message) {
    final key = ValueKey(message.messageId);
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.heartList.insert(
        0,
        IsmLiveAnimationView(
          key: key,
          child: Transform.scale(
            scale: 0.6,
            child: IsmLiveHeartButton(size: IsmLiveDimens.fifty),
          ),
          onComplete: () {
            _controller.heartList.removeWhere((e) => e.key == key);
          },
        ),
      );
    });
  }

  Future<void> toggleSpeaker({
    bool? value,
  }) async {
    final room = _controller.room;
    if (room == null) {
      return;
    }
    if (room.participants.values.isEmpty) {
      return;
    }
    if (room.participants.values.first.audioTracks.isEmpty) {
      return;
    }
    _controller.speakerOn = value ?? !_controller.speakerOn;

    _controller.speakerOn
        ? await room.participants.values.first.audioTracks.first.enable()
        : await room.participants.values.first.audioTracks.first.disable();

    //if above code is not working in iOS use this
    // await Hardware.instance.setPreferSpeakerOutput(_controller.speakerOn);
    // await Hardware.instance.setSpeakerphoneOn(_controller.speakerOn);
  }

  Future onOptionTap(IsmLiveStreamOption option) async {
    switch (option) {
      case IsmLiveStreamOption.gift:
        _controller.giftsSheet();
        break;
      case IsmLiveStreamOption.multiLive:
      case IsmLiveStreamOption.share:
      case IsmLiveStreamOption.members:
      case IsmLiveStreamOption.favourite:
      case IsmLiveStreamOption.settings:
      case IsmLiveStreamOption.vs:
        break;
      case IsmLiveStreamOption.rotateCamera:
        _controller.toggleCamera();
        break;
      case IsmLiveStreamOption.speaker:
        await toggleSpeaker();
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
      IsmLiveUtility.closeLoader();
      IsmLiveLog.error('Cannot leave stream');
      await _controller.animateToPage(_controller.previousStreamIndex);
      return;
    }
    _controller.isMeetingOn = false;
    unawaited(room.disconnect());
    await _controller.joinStream(
      _controller.streams[index],
      false,
      joinByScrolling: true,
    );
    _controller.previousStreamIndex = index;
    IsmLiveUtility.closeLoader();
  }

  void onExit({
    required bool isHost,
    required String streamId,
  }) {
    IsmLiveUtility.openBottomSheet(
      IsmLiveCustomButtomSheet(
        title: isHost ? IsmLiveStrings.areYouSureEndStream : IsmLiveStrings.areYouSureLeaveStream,
        leftLabel: 'Cancel',
        rightLabel: isHost ? 'End Stream' : 'Leave Stram',
        onLeft: Get.back,
        onRight: () async {
          Get.back();
          await disconnectStream(
            isHost: isHost,
            streamId: streamId,
          );
        },
      ),
      isDismissible: false,
    );
  }

  Future<void> disconnectStream({
    required bool isHost,
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
      if (isHost) {
        unawaited(_controller._dbWrapper.deleteSecuredValue(streamId));
      }
      _controller.isHost = null;
      _controller.isMeetingOn = false;
      _controller.streamId = null;
      await _controller.room?.disconnect();
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
