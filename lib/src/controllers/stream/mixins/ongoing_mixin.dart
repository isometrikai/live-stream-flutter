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
    _controller.moderatorsList.clear();

    _manageModerator(streamId);

    if (!isHost) {
      await _controller.fetchMessagesCount(
        showLoading: false,
        getMessageModel: IsmLiveGetMessageModel(streamId: streamId),
      );

      if (_controller.messagesCount != 0) {
        unawaited(
          _controller.fetchMessages(
            showLoading: false,
            getMessageModel: IsmLiveGetMessageModel(
              streamId: streamId,
              messageType: [IsmLiveMessageType.normal.value],
              sort: 1,
              skip: _controller.messagesCount < 10 ? 0 : (_controller.messagesCount - 10),
              limit: 10,
              senderIdsExclusive: false,
            ),
          ),
        );
      }
    }
    await sortParticipants();
    if (lkPlatformIsMobile()) {
      unawaited(_controller.toggleSpeaker(value: true));
    }
    IsmLiveUtility.updateLater(() {
      _controller.update([IsmLiveStreamView.updateId]);
    });
  }

  void _manageModerator(String streamId) async {
    /// this is to check user is a moderator or not via API call
    /// By passing User name in search tag  it will give us the filtered list
    await _controller._fetchModerators(
      streamId: streamId,
      searchTag: _controller.user?.userName,
    );

    _controller.isModerator = _controller.moderatorsList.any(
      (e) => e.userId == _controller.user?.userId,
    );

    ///This is to update the List of moderators without search
    await _controller.fetchModerators(
      forceFetch: true,
      streamId: streamId,
    );
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
          sortParticipants();
        })
        ..on<ParticipantConnectedEvent>((event) {
          IsmLiveLog.info('ParticipantConnectedEvent: $event');
          sortParticipants();
        })
        ..on<ParticipantDisconnectedEvent>((event) async {
          IsmLiveLog.info('ParticipantDisconnectedEvent: $event');
        })
        ..on<RoomRecordingStatusChanged>((event) {})
        ..on<LocalTrackPublishedEvent>((_) => sortParticipants())
        ..on<LocalTrackUnpublishedEvent>((_) => sortParticipants())
        ..on<TrackE2EEStateEvent>((event) {
          IsmLiveLog.info('TrackE2EEStateEvent: $event');
        })
        ..on<ParticipantNameUpdatedEvent>((event) {
          IsmLiveLog.info('ParticipantNameUpdatedEvent: $event');
          sortParticipants();
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

  Future<void> sortParticipants() async {
    _participantDebouncer.run(_sortParticipants);
  }

  Future<void> _sortParticipants() async {
    final room = _controller.room;
    if (room == null) {
      return;
    }
    var userMediaTracks = <IsmLiveParticipantTrack>[];

    // if (isHost || _controller.isMember) {
    final localParticipantTracks = room.localParticipant?.videoTracks;
    if (localParticipantTracks != null) {
      for (var t in localParticipantTracks) {
        userMediaTracks.add(
          IsmLiveParticipantTrack(
            participant: room.localParticipant!,
            videoTrack: t.track,
            isScreenShare: false,
          ),
        );
      }
    }

    // } else {
    for (var participant in room.participants.values) {
      for (var t in participant.videoTracks) {
        userMediaTracks.add(
          IsmLiveParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: false,
          ),
        );
      }
    }
    // }

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

  String controlSetting(IsmLiveHostSettings option) {
    switch (option) {
      case IsmLiveHostSettings.muteMyVideo:
        return _controller.videoOn ? option.muteValues : option.unmuteValues;
      case IsmLiveHostSettings.muteMyAudio:
        return _controller.audioOn ? option.muteValues : option.unmuteValues;
      case IsmLiveHostSettings.muteRemoteVideo:
        return option.muteValues;
      case IsmLiveHostSettings.muteRemoteAudio:
        return option.muteValues;
      case IsmLiveHostSettings.showNetWorkStats:
        return option.muteValues;
      case IsmLiveHostSettings.hideChatMessages:
        return option.muteValues;
      case IsmLiveHostSettings.hideControlButtons:
        return option.muteValues;
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
    final chats = messages.map((e) => _controller.convertMessageToChat(e)).toList();
    if (isMqtt) {
      _controller.streamMessagesList.addAll(chats);
    } else {
      _controller.streamMessagesList.insertAll(0, chats);
    }
    _controller.streamMessagesList = _controller.streamMessagesList.toSet().toList();
    await _controller.messagesListController.animateTo(
      _controller.messagesListController.position.maxScrollExtent + IsmLiveDimens.hundred,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
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

  void addGift(IsmLiveMessageModel message) {
    _controller.giftMessages.add(message);
    if (_controller.giftMessages.length == 1) {
      _handleGift(message);
    }
  }

  void _handleGift(IsmLiveMessageModel message) {
    if (message.customType == null) {
      return;
    }
    final key = ValueKey(message.messageId);
    final gift = message.customType!.path;
    final child = gift.endsWith('gif') ? IsmLiveGif(path: gift) : IsmLiveImage.asset(gift);
    _controller.giftList.insert(
      0,
      IsmLiveGiftView(
        key: key,
        child: child,
        onComplete: () {
          _controller.giftList.removeWhere((e) => e.key == key);
          _controller.giftMessages.removeAt(0);
          if (_controller.giftMessages.isNotEmpty) {
            _handleGift(_controller.giftMessages.first);
          }
          _controller.update([IsmLiveStreamView.updateId]);
        },
      ),
    );
  }

  Future<void> toggleSpeaker({
    bool? value,
  }) async {
    final room = _controller.room;
    if (room == null) {
      return;
    }
    if (room.participants.values.isEmpty || room.participants.values.first.audioTracks.isEmpty) {
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
        if (!_controller.isModerator && (_controller.isCopublisher != true)) {
          if (_controller.memberStatus.canEnableVideo) {
            _controller.copublishingStartVideoSheet();
          } else {
            _controller.copublishingViewerSheet();
          }
        } else {
          _controller.copublishingHostSheet();
        }

        break;
      case IsmLiveStreamOption.share:
        break;
      case IsmLiveStreamOption.members:
        break;
      case IsmLiveStreamOption.favourite:
        break;
      case IsmLiveStreamOption.settings:
        _controller.settingSheet();
        break;
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

  void onSettingTap(
    IsmLiveHostSettings option,
  ) async {
    switch (option) {
      case IsmLiveHostSettings.muteRemoteVideo:
        break;
      case IsmLiveHostSettings.muteRemoteAudio:
        break;
      case IsmLiveHostSettings.showNetWorkStats:
        break;
      case IsmLiveHostSettings.hideChatMessages:
        break;
      case IsmLiveHostSettings.hideControlButtons:
        break;
      case IsmLiveHostSettings.muteMyAudio:
        await _controller.toggleAudio();
        break;
      case IsmLiveHostSettings.muteMyVideo:
        _controller.toggleVideo();
        break;
    }
  }

  Future<bool> requestBackgroundPermission([bool isRetry = false]) async {
    // Required for android screenshare.
    try {
      var hasPermissions = await FlutterBackground.hasPermissions;
      if (!isRetry) {
        const androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: 'Screen Sharing',
          notificationText: '${IsmLiveConstants.name} is sharing the screen.',
          notificationImportance: AndroidNotificationImportance.Default,
          notificationIcon: AndroidResource(
            name: 'ic_launcher',
            defType: 'mipmap',
          ),
        );
        hasPermissions = await FlutterBackground.initialize(
          androidConfig: androidConfig,
        );
      }
      if (hasPermissions && !FlutterBackground.isBackgroundExecutionEnabled) {
        return await FlutterBackground.enableBackgroundExecution();
      }
      return false;
    } catch (e, st) {
      if (!isRetry) {
        return await Future<bool>.delayed(
          const Duration(seconds: 1),
          () => requestBackgroundPermission(true),
        );
      }
      IsmLiveLog.error('Could not publish video: $e', st);
      return false;
    }
  }

  void enableScreenShare() async {
    try {
      IsmLiveUtility.showLoader();
      if (_controller.room == null || _controller.room!.localParticipant == null) {
        return;
      }

      var isExecuting = await requestBackgroundPermission();
      IsmLiveLog.error(isExecuting);
      if (!isExecuting) {
        isExecuting = await requestBackgroundPermission();
      }
      if (isExecuting) {
        await _controller.room!.localParticipant!.setScreenShareEnabled(
          true,
          captureScreenAudio: true,
        );
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    } finally {
      IsmLiveUtility.closeLoader();
    }
  }

  void disableScreenShare() async {
    try {
      IsmLiveUtility.showLoader();
      await _controller.room!.localParticipant!.setScreenShareEnabled(
        false,
      );
      await FlutterBackground.disableBackgroundExecution();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    } finally {
      IsmLiveUtility.closeLoader();
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
    // _controller.isMeetingOn = false;
    unawaited(room.disconnect());
    await _controller.joinStream(
      _controller.streams[index],
      false,
      joinByScrolling: true,
    );
    _controller.previousStreamIndex = index;
    IsmLiveUtility.closeLoader();
  }

  Future<void> disconnectStream({
    required bool isHost,
    required String streamId,
    bool goBack = true,
  }) async {
    var isEnded = false;
    if (isHost) {
      isEnded = await _controller.stopStream(streamId);
    } else if (_controller.isCopublisher == true) {
      isEnded = await _controller.leaveMember(streamId: streamId);
    } else {
      isEnded = await _controller.leaveStream(streamId);
    }
    if (isEnded) {
      unawaited(_controller._mqttController?.unsubscribeStream(streamId));
      if (isHost) {
        unawaited(_controller._dbWrapper.deleteSecuredValue(streamId));
      }
      _controller.isHost = null;
      // _controller.isMeetingOn = false;
      _controller.streamId = null;
      await _controller.room?.disconnect();
      if (goBack) {
        closeStreamView(isHost);
      }
    }
  }

  void closeStreamView(bool isHost, [bool fromMqtt = false]) {
    _controller._streamTimer?.cancel();
    if (isHost) {
      IsmLiveRouteManagement.goToEndStreamView();
    } else {
      Get.back();
      if (fromMqtt) {
        IsmLiveUtility.showDialog(const IsmLiveStreamEndDialog());
      }
    }
  }
}
