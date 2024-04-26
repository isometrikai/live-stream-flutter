part of '../stream_controller.dart';

mixin StreamOngoingMixin {
  IsmLiveStreamController get _controller => Get.find();
// Debouncer to handle sorting of participants
  final _participantDebouncer = IsmLiveDebouncer();
  // Function to initialize the stream
  void initializeStream({
    required String streamId,
    required bool isHost,
  }) async {
    _controller.messageFocusNode.addListener(() {
      if (_controller.messageFocusNode.hasFocus) {
        _controller.showEmojiBoard = false;
      }
    });
    // Pagination setup for the stream
    _controller.pagination(streamId);
    // Set up event listeners
    unawaited(setUpListeners(
      isHost: isHost,
    ));
    // Clear moderators list and request status
    _controller.moderatorsList.clear();
    // unawaited(_controller.statusCopublisherRequest(streamId));
    // Manage moderator status
    _manageModerator(streamId);
    // Fetch message count and initial messages if not host
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
              skip: _controller.messagesCount < 10
                  ? 0
                  : (_controller.messagesCount - 10),
              limit: 10,
              senderIdsExclusive: false,
            ),
          ),
        );
      }
    }
    // Sort participants and update UI
    await sortParticipants();
    // Toggle speaker if on mobile platform
    if (lkPlatformIsMobile()) {
      unawaited(_controller.toggleSpeaker(value: true));
    }
    // Update stream view
    IsmLiveUtility.updateLater(() {
      _controller.update([IsmLiveStreamView.updateId]);
    });
  }

// Function to manage moderator status
  void _manageModerator(String streamId) async {
    /// this is to check user is a moderator or not via API call
    /// By passing User name in search tag  it will give us the filtered list
    await _controller._fetchModerators(
      streamId: streamId,
      searchTag: _controller.user?.userName,
    );

    var isModerator = _controller.moderatorsList.any(
      (e) => e.userId == _controller.user?.userId,
    );

    if (isModerator) {
      _controller.userRole?.makeModerator();
    } else {
      _controller.userRole?.leaveModeration();
    }

    ///This is to update the List of moderators without search
    await _controller.fetchModerators(
      forceFetch: true,
      streamId: streamId,
    );
  }

// Function to set up event listeners
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
          if (_controller.participantTracks.length == 1 &&
              _controller.isCopublisher) {
            _controller.userRole?.leaveCopublishing();
          }
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

    final localParticipantTracks = room.localParticipant?.videoTracks;
    if (localParticipantTracks != null) {
      for (var t in localParticipantTracks) {
        userMediaTracks.add(
          IsmLiveParticipantTrack(
            participant: room.localParticipant!,
            videoTrack: t.track,
            isScreenShare: t.isScreenShare,
          ),
        );
      }
    }

    for (var participant in room.participants.values) {
      for (var t in participant.videoTracks) {
        userMediaTracks.add(
          IsmLiveParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: t.isScreenShare,
          ),
        );
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
      case IsmLiveStreamOption.bars:
      case IsmLiveStreamOption.vs:
      case IsmLiveStreamOption.settings:
      case IsmLiveStreamOption.rotateCamera:
      case IsmLiveStreamOption.product:
      case IsmLiveStreamOption.heart:
        return option.icon;
      case IsmLiveStreamOption.speaker:
        if (_controller.speakerOn) {
          return IsmLiveAssetConstants.speakerOn;
        }
        return IsmLiveAssetConstants.speakerOff;
    }
  }

  String controlSettingIcon(IsmLiveHostSettings option) {
    switch (option) {
      case IsmLiveHostSettings.muteMyVideo:
        return _controller.videoOn ? option.icon : option.offIcon;
      case IsmLiveHostSettings.muteMyAudio:
        return _controller.audioOn ? option.icon : option.offIcon;
    }
  }

  // Function to handle actions on stream controls
  String controlSetting(IsmLiveHostSettings option) {
    switch (option) {
      case IsmLiveHostSettings.muteMyVideo:
        return _controller.videoOn ? option.muteValues : option.unmuteValues;
      case IsmLiveHostSettings.muteMyAudio:
        return _controller.audioOn ? option.muteValues : option.unmuteValues;
      // case IsmLiveHostSettings.muteRemoteVideo:
      //   return option.muteValues;
      // case IsmLiveHostSettings.muteRemoteAudio:
      //   return option.muteValues;
      // case IsmLiveHostSettings.showNetWorkStats:
      //   return option.muteValues;
      // case IsmLiveHostSettings.hideChatMessages:
      //   return option.muteValues;
      // case IsmLiveHostSettings.hideControlButtons:
      //   return option.muteValues;
      // case IsmLiveHostSettings.block:
      //   return option.muteValues;
      // case IsmLiveHostSettings.report:
      //   return option.muteValues;
    }
  }

  // Function to add viewers to the stream
  Future<void> addViewers(
      List<IsmLiveViewerModel> viewers, bool isFirstCall) async {
    if (isFirstCall) {
      _controller.streamViewersList.clear();
    }
    _controller.streamViewersList.addAll(viewers);
    _controller.streamViewersList =
        _controller.streamViewersList.toSet().toList();
  }

// Function to add messages to the stream
  Future<void> addMessages(
    List<IsmLiveMessageModel> messages, [
    bool isMqtt = true,
  ]) async {
    final chats =
        messages.map((e) => _controller.convertMessageToChat(e)).toList();

    if (isMqtt) {
      _controller.streamMessagesList.addAll(chats);
    } else {
      _controller.streamMessagesList.insertAll(0, chats);
    }
    _controller.streamMessagesList =
        _controller.streamMessagesList.toSet().toList();
    await _controller.messagesListController.animateTo(
      _controller.messagesListController.position.maxScrollExtent +
          IsmLiveDimens.hundred,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

// Function to add heart message to the stream
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

  // Function to add gift message to the stream
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
    final child = gift.endsWith('gif')
        ? IsmLiveGif(path: gift)
        : IsmLiveImage.asset(gift);
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
    if (room.participants.values.isEmpty ||
        room.participants.values.first.audioTracks.isEmpty) {
      return;
    }

    _controller.speakerOn = value ?? !_controller.speakerOn;
    try {
      if (_controller.speakerOn) {
        for (var i = 0; i < room.participants.values.length; i++) {
          unawaited(
              room.participants.values.elementAt(i).audioTracks.first.enable());
        }
      } else {
        for (var i = 0; i < room.participants.values.length; i++) {
          unawaited(room.participants.values
              .elementAt(i)
              .audioTracks
              .first
              .disable());
        }
      }
    } catch (e) {
      IsmLiveLog('speaker error $e');
    }
  }

  Future onOptionTap(IsmLiveStreamOption option) async {
    switch (option) {
      case IsmLiveStreamOption.gift:
        _controller.giftsSheet();
        break;
      case IsmLiveStreamOption.multiLive:
        if (_controller.isHost || _controller.isPublishing) {
          _controller.copublishingHostSheet();
        } else {
          if (_controller.memberStatus.canEnableVideo) {
            _controller.copublishingStartVideoSheet();
          } else {
            _controller.copublishingViewerSheet();
          }
        }

        break;
      case IsmLiveStreamOption.share:
        _controller.animationController.forward();

        break;
      case IsmLiveStreamOption.members:
        break;
      case IsmLiveStreamOption.favourite:
        break;
      case IsmLiveStreamOption.settings:
        _controller.settingSheet();
        break;
      case IsmLiveStreamOption.product:
        IsmLiveRouteManagement.goToTagProduct();
        break;
      case IsmLiveStreamOption.rotateCamera:
        _controller.toggleCamera();
        break;
      case IsmLiveStreamOption.speaker:
        await toggleSpeaker();
        break;
      case IsmLiveStreamOption.bars:
        break;
      case IsmLiveStreamOption.vs:
        _controller.pkSheet();
        break;
      case IsmLiveStreamOption.heart:
        unawaited(_controller.sendHeartMessage(_controller.streamId ?? ''));
        break;
    }
  }

  void onSettingTap(
    IsmLiveHostSettings option,
  ) async {
    switch (option) {
      // case IsmLiveHostSettings.muteRemoteVideo:
      //   break;
      // case IsmLiveHostSettings.muteRemoteAudio:
      //   break;
      // case IsmLiveHostSettings.showNetWorkStats:
      //   break;
      // case IsmLiveHostSettings.hideChatMessages:
      //   break;
      // case IsmLiveHostSettings.hideControlButtons:
      //   break;
      case IsmLiveHostSettings.muteMyAudio:
        await _controller.toggleAudio();
        break;
      case IsmLiveHostSettings.muteMyVideo:
        _controller.toggleVideo();
        break;
      // case IsmLiveHostSettings.block:
      //   break;
      // case IsmLiveHostSettings.report:
      //   break;
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
      if (_controller.room == null ||
          _controller.room!.localParticipant == null) {
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
    final didLeft = await disconnectStream(
      isHost: false,
      streamId: _controller.streamId ?? '',
      goBack: false,
    );
    if (!didLeft) {
      IsmLiveUtility.closeLoader();
      IsmLiveLog.error('Cannot leave stream');
      await _controller.animateToPage(_controller.previousStreamIndex);
      return;
    }
    await _controller.joinStream(
      _controller.streams[index],
      false,
      joinByScrolling: true,
    );
    _controller.previousStreamIndex = index;
    IsmLiveUtility.closeLoader();
  }

  Future<bool> disconnectStream({
    required bool isHost,
    required String streamId,
    bool goBack = true,
    bool endStream = true,
  }) async {
    var isEnded = false;
    if (isHost) {
      isEnded = await _controller.stopStream(streamId);
    } else if (_controller.isCopublisher) {
      isEnded = await _controller.leaveMember(streamId: streamId);
    } else {
      isEnded = await _controller.leaveStream(streamId);
    }
    if (isEnded && endStream) {
      unawaited(_controller._mqttController?.unsubscribeStream(streamId));
      if (isHost) {
        unawaited(_controller._dbWrapper.deleteSecuredValue(streamId));
      }
      await disconnectRoom();

      if (goBack) {
        unawaited(_controller.getStreams());
        closeStreamView(isHost, streamId: streamId);
      }
    } else if (_controller.isCopublisher) {
      await _controller.unpublishTracks();

      _controller.userRole?.leaveCopublishing();

      _controller.memberStatus = IsmLiveMemberStatus.notMember;

      await _controller.getRTCToken(_controller.streamId ?? '',
          showLoader: false);

      await _controller.sortParticipants();
    }
    IsmLiveApp.onStreamEnd?.call();
    return isEnded;
  }

  Future<void> disconnectRoom() async {
    unawaited(
        _controller._mqttController?.unsubscribeStream(_controller.streamId!));

    _controller.userRole = null;
    _controller.streamId = null;
    _controller._streamTimer?.cancel();
    _controller._streamTimer = null;

    try {
      await _controller.room!.disconnect();
    } catch (e) {
      IsmLiveLog('room not disconnected $e');
    }
  }

  void closeStreamView(bool isHost, {String? streamId, bool fromMqtt = false}) {
    _controller._streamTimer?.cancel();
    _controller._streamTimer = null;

    if (isHost) {
      IsmLiveRouteManagement.goToEndStreamView(streamId!);
    } else {
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
      Get.back();
      if (fromMqtt) {
        IsmLiveUtility.showDialog(const IsmLiveStreamEndDialog());
      }
    }
  }
}
