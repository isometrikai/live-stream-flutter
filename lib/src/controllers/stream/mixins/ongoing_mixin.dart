part of '../stream_controller.dart';

/// Ensures audio routes to the loudspeaker when no external audio device
/// (Bluetooth, wired headset) is connected. Safe to call repeatedly.
///
/// On iOS [setSpeakerphoneOn] already respects connected accessories
/// (Bluetooth / wired headsets take priority by default).
/// On Android [setSpeakerphoneOn(true)] forces the built-in speaker and
/// overrides any connected device, so we guard the call behind a device check.
///
/// When [withRetry] is true (default for the initial connection), a delayed
/// second attempt is scheduled. This guards against the common race where
/// WebRTC's remote-track subscription reconfigures the audio session and
/// resets the output back to the earpiece (Android) or where the
/// AVAudioSession hasn't fully activated yet (iOS).
Future<void> _ensureLoudspeakerRouting({bool withRetry = false}) async {
  try {
    await _applySpeakerRoute();
  } catch (e) {
    IsmLiveLog('_ensureLoudspeakerRouting error: $e');
  }

  if (withRetry) {
    unawaited(Future<void>.delayed(
      const Duration(milliseconds: 800),
      () async {
        try {
          await _applySpeakerRoute();
        } catch (e) {
          IsmLiveLog('_ensureLoudspeakerRouting retry error: $e');
        }
      },
    ));
    // Some devices (notably certain Xiaomi/Redmi builds and some iOS versions)
    // can re-route audio *again* after the first remote track starts rendering.
    // A second delayed re-apply reduces intermittent "earpiece instead of speaker"
    // reports without changing steady-state behavior.
    unawaited(Future<void>.delayed(
      const Duration(milliseconds: 1600),
      () async {
        try {
          await _applySpeakerRoute();
        } catch (e) {
          IsmLiveLog('_ensureLoudspeakerRouting 2nd retry error: $e');
        }
      },
    ));
  }
}

Future<void> _applySpeakerRoute() async {
  if (Platform.isIOS) {
    await lk.Hardware.instance.setSpeakerphoneOn(true);
    return;
  }

  if (Platform.isAndroid) {
    final hasExternal = await _hasExternalAudioOutputOnAndroid();
    if (!hasExternal) {
      await lk.Hardware.instance.setSpeakerphoneOn(true);
    }
    return;
  }

  await lk.Hardware.instance.setSpeakerphoneOn(true);
}

/// Returns `true` when an external audio output (Bluetooth, wired headset,
/// USB audio) is currently connected on Android.
///
/// Built-in outputs are identified by substring matching against known
/// built-in keywords. This handles OEM-specific labels (e.g. Xiaomi/Redmi
/// reporting "Built-In Speaker", localized names like "手机听筒", etc.).
Future<bool> _hasExternalAudioOutputOnAndroid() async {
  try {
    final devices = await lk.Hardware.instance.enumerateDevices();
    final outputs = devices.where((d) => d.kind == 'audiooutput').toList();

    IsmLiveLog.info(
        '_hasExternalAudioOutputOnAndroid: ${outputs.length} outputs: '
        '${outputs.map((d) => '"${d.label}"').join(', ')}');

    // On Android, built-in outputs are typically "Earpiece" + "Speaker"
    // (at most 2 entries). Any additional entry indicates external hardware.
    if (outputs.length > 2) return true;

    // Substring-based matching so OEM-specific labels (e.g. "Built-In Speaker",
    // "phone speaker", localized names) are still recognized as built-in.
    const builtInKeywords = [
      'earpiece',
      'speaker',
      'speakerphone',
      'built-in',
      'builtin',
      'phone',
      'handset',
      'receiver',
    ];
    for (final device in outputs) {
      final label = device.label.toLowerCase().trim();
      if (label.isEmpty) continue;
      final isBuiltIn = builtInKeywords.any(label.contains);
      if (!isBuiltIn) {
        IsmLiveLog.info(
            '_hasExternalAudioOutputOnAndroid: detected external device: "$label"');
        return true;
      }
    }

    return false;
  } catch (e) {
    IsmLiveLog.info('_hasExternalAudioOutputOnAndroid error: $e');
    return false;
  }
}

mixin StreamOngoingMixin {
  IsmLiveStreamController get _controller => Get.find();
  IsmLivePkController get _pkController => Get.find();
// Debouncer to handle sorting of participants
  final _participantDebouncer = IsmLiveDebouncer();

  Timer? _heartDebounceTimer;
  int _pendingHeartCount = 0;
  int _heartIdCounter = 0;

  /// Stop MQTT-disconnected chat fallback polling (used on app background).
  void pauseMqttDisconnectedChatFallback() {
    _stopMqttDisconnectedChatFallback();
  }

  /// Resume MQTT-disconnected chat fallback polling if needed (used on resume).
  void resumeMqttDisconnectedChatFallbackIfNeeded() {
    final streamId = _controller.streamId;
    if (streamId == null || streamId.isEmpty) return;
    if (_controller.isInBackground) return;
    _controller.nudgeMqttReconnectAfterAppResume();
    if (IsmLiveApp.isMqttConnected) return;
    unawaited(_startMqttDisconnectedChatFallback(streamId));
  }

  // Function to initialize the stream
  void initializeStream({
    required String streamId,
    required bool isHost,
  }) async {
    if (_controller._messageFocusListener != null) {
      _controller.messageFocusNode
          .removeListener(_controller._messageFocusListener!);
    }
    _controller._messageFocusListener = () {
      if (_controller.messageFocusNode.hasFocus) {
        _controller.showEmojiBoard = false;
      }
    };
    _controller.messageFocusNode
        .addListener(_controller._messageFocusListener!);

    if (_controller.isPk) {
      _pkController.pkStatus(streamId);
    }
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
    final mqttConnectedAtJoin = IsmLiveApp.isMqttConnected;

    // Fetch message count and initial messages:
    // - Viewers: always (existing behavior)
    // - Host: only if MQTT is already disconnected, so the chat isn't blank
    if (!isHost || !mqttConnectedAtJoin) {
      await _controller.fetchMessagesCount(
        showLoading: false,
        getMessageModel: IsmLiveGetMessageModel(
            streamId: streamId, messageType: [IsmLiveMessageType.normal.value]),
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

    // Start/stop polling for chat updates when MQTT disconnects.
    _setupMqttDisconnectedChatFallback(streamId: streamId);

    // Sort participants and update UI
    unawaited(sortParticipants());
    // Toggle speaker if on mobile platform
    if (lk.lkPlatformIsMobile()) {
      unawaited(_controller.toggleSpeaker(value: true));
    }
    // Update stream view
    IsmLiveUtility.updateLater(() {
      _controller.update([IsmLiveStreamView.updateId]);
    });
  }

  void _setupMqttDisconnectedChatFallback({
    required String streamId,
  }) {
    _stopMqttDisconnectedChatFallback();
    _controller._mqttChatFallbackConnSubscription?.cancel();
    _controller._mqttChatFallbackConnSubscription =
        IsmLiveApp.isMqttConnectedRx.stream.listen((connected) {
      if (connected) {
        // MQTT is back: stop interval mechanism immediately.
        _stopMqttDisconnectedChatFallback();
        return;
      }

      // MQTT disconnected: start interval mechanism (if not already running).
      if (!_controller.isInBackground) {
        unawaited(_startMqttDisconnectedChatFallback(streamId));
      }
    });

    // Start immediately if MQTT is already disconnected at join time.
    if (!IsmLiveApp.isMqttConnected) {
      unawaited(_startMqttDisconnectedChatFallback(streamId));
    }
  }

  void _stopMqttDisconnectedChatFallback() {
    _controller._mqttChatFallbackTimer?.cancel();
    _controller._mqttChatFallbackTimer = null;
    _controller._mqttChatFallbackInFlight = false;
  }

  Future<void> _startMqttDisconnectedChatFallback(String streamId) async {
    if (_controller.isInBackground) return;
    if (IsmLiveApp.isMqttConnected) return;
    if (_controller._mqttChatFallbackTimer != null) return;

    // If we have no messages yet, do a one-time initial catch-up using the
    // existing pagination API.
    if (_controller.streamMessagesList.isEmpty) {
      await _controller.fetchMessagesCount(
        showLoading: false,
        getMessageModel: IsmLiveGetMessageModel(
          streamId: streamId,
          messageType: [IsmLiveMessageType.normal.value],
        ),
      );

      if (_controller.messagesCount != 0) {
        await _controller.fetchMessages(
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
        );
      }
    }

    // Interval mechanism: run only while MQTT is disconnected.
    final interval = IsmLiveDelegate.mqttChatFallbackInterval;
    final safeInterval =
        interval.inMilliseconds <= 0 ? const Duration(seconds: 6) : interval;
    _controller._mqttChatFallbackTimer = Timer.periodic(
      safeInterval,
      (timer) => unawaited(_pollNewMqttMessages(streamId)),
    );

    // Immediate run so we don't wait for the first tick.
    unawaited(_pollNewMqttMessages(streamId));
  }

  Future<void> _pollNewMqttMessages(String streamId) async {
    // Only fetch while MQTT is disconnected.
    if (IsmLiveApp.isMqttConnected) {
      _stopMqttDisconnectedChatFallback();
      return;
    }

    // Reduce background load; skip ticks while app isn't active.
    if (_controller.isInBackground) return;

    if (_controller._mqttChatFallbackInFlight) return;
    _controller._mqttChatFallbackInFlight = true;
    try {
      if (_controller.streamId == null || _controller.streamId!.isEmpty) {
        return;
      }

      // If there are no messages yet (e.g. host joined while MQTT was connected),
      // do a one-time initial catch-up using the existing pagination API.
      if (_controller.streamMessagesList.isEmpty) {
        await _controller.fetchMessagesCount(
          showLoading: false,
          getMessageModel: IsmLiveGetMessageModel(
            streamId: streamId,
            messageType: [IsmLiveMessageType.normal.value],
          ),
        );

        if (_controller.messagesCount != 0) {
          await _controller.fetchMessages(
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
          );
        }
        return;
      }

      final lastTimestampMs = _controller.streamMessagesList
          .map((m) => m.timeStamp.millisecondsSinceEpoch)
          .fold<int>(0, (prev, ms) => ms > prev ? ms : prev);

      if (lastTimestampMs == 0) return;

      await _controller.fetchNewMessagesSinceTimestamp(
        streamId: streamId,
        // Some backends treat `lastMessageTimestamp` as inclusive (>=).
        // Bump by 1ms so we truly fetch "newer than" and avoid duplicating the
        // most recent message on foreground resume / reconnect polls.
        lastMessageTimestamp: lastTimestampMs + 1,
        limit: 10,
        showDialog: false,
      );
    } catch (e, st) {
      IsmLiveLog.error('MQTT chat fallback poll failed: $e', st);
    } finally {
      _controller._mqttChatFallbackInFlight = false;
    }
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
    unawaited(_controller.fetchModerators(
      forceFetch: true,
      streamId: streamId,
    ));
  }

// Function to set up event listeners
  Future<void> setUpListeners({
    required bool isHost,
  }) async =>
      _controller.listener
        ?..on<lk.RoomDisconnectedEvent>((event) async {
          IsmLiveLog.info('RoomDisconnectedEvent: $event');
          if (!Get.isRegistered<IsmLiveStreamController>()) return;

          // Check if this is a background disconnection
          if (_controller.isInBackground) {
            IsmLiveLog.info(
                'Room disconnected while in background - not ending stream');
            return;
          }

          // Check if this is a client-initiated disconnection (likely background)
          if (event.reason == lk.DisconnectReason.clientInitiated) {
            IsmLiveLog.info(
                'Client-initiated disconnection - checking if in background');
            // Give a small delay to check if we're actually in background
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!Get.isRegistered<IsmLiveStreamController>()) return;
              if (_controller.isInBackground) {
                IsmLiveLog.info(
                    'Confirmed background disconnection - not ending stream');
                return;
              }
            });
          }

          // Check if this is a join failure during reconnection
          if (event.reason == lk.DisconnectReason.joinFailure) {
            IsmLiveLog.info(
                'Join failure during reconnection - not ending stream, will retry');
            return;
          }

          // Check if this is a state mismatch (common during reconnection)
          if (event.reason == lk.DisconnectReason.stateMismatch) {
            IsmLiveLog.info(
                'State mismatch during reconnection - not ending stream');
            return;
          }

          IsmLiveLog.info(
              'Room disconnected - this appears to be a real disconnection');
        })
        ..on<lk.ParticipantEvent>((event) {
          IsmLiveLog.info('ParticipantEvent: $event');
          sortParticipants();
        })
        ..on<lk.ParticipantConnectedEvent>((event) {
          IsmLiveLog.info('ParticipantConnectedEvent: $event');
          sortParticipants();
        })
        ..on<lk.ParticipantDisconnectedEvent>((event) async {
          // if (_controller.participantTracks.length == 1 &&
          //     _controller.isCopublisher) {
          //   _controller.userRole?.leaveCopublishing();
          // }
          IsmLiveLog.info('ParticipantDisconnectedEvent: $event');
        })
        ..on<lk.RoomRecordingStatusChanged>((event) {})
        ..on<lk.LocalTrackPublishedEvent>((_) => sortParticipants())
        ..on<lk.LocalTrackUnpublishedEvent>((_) => sortParticipants())
        ..on<lk.TrackE2EEStateEvent>((event) {
          IsmLiveLog.info('TrackE2EEStateEvent: $event');
        })
        ..on<lk.ParticipantNameUpdatedEvent>((event) {
          IsmLiveLog.info('ParticipantNameUpdatedEvent: $event');
          sortParticipants();
        })
        ..on<lk.DataReceivedEvent>((event) {
          IsmLiveLog.info('DataReceivedEvent: ${event.topic} $event');
        })
        ..on<lk.AudioPlaybackStatusChanged>((event) async {
          IsmLiveLog.info('DataReceivedEvent: ${event.isPlaying} $event');
          if (!Get.isRegistered<IsmLiveStreamController>()) return;
          if (_controller.room == null) {
            return;
          }
          if (!_controller.room!.canPlaybackAudio) {
            IsmLiveLog.error('Audio playback failed for iOS Safari ..........');
          }
        })
        ..on<lk.TrackSubscribedEvent>((event) {
          if (event.track.kind != lk.TrackType.AUDIO) {
            return;
          }
          if (!Get.isRegistered<IsmLiveStreamController>()) return;
          final room = _controller.room;
          if (room == null) {
            return;
          }
          if (_controller.speakerOn) {
            // Remote audio track just arrived — WebRTC's track subscription
            // can reconfigure the audio session and reset routing back to the
            // earpiece on some devices (Redmi/Xiaomi, certain iOS versions).
            // Re-apply loudspeaker routing after the track is fully started.
            unawaited(Future<void>(() async {
              await Future<void>.delayed(const Duration(milliseconds: 150));
              if (!Get.isRegistered<IsmLiveStreamController>()) return;
              if (_controller.room != room || !_controller.speakerOn) return;
              await _ensureLoudspeakerRouting(withRetry: true);
            }));
          }
          // LiveKit starts the remote track after this event (which re-enables
          // the WebRTC audio track). Defer so our desired state (speakerOn/mute)
          // wins over that enable. This also fixes rare cases where a track
          // remains disabled after fast join/leave cycles.
          unawaited(Future<void>(() async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            if (!Get.isRegistered<IsmLiveStreamController>()) return;
            if (_controller.room != room) {
              return;
            }
            await _syncRemoteAudioPlaybackWithSpeakerFlag(room);
          }));
        })
        ..on<lk.TrackUnmutedEvent>((event) {
          if (event.publication.kind != lk.TrackType.AUDIO) {
            return;
          }
          if (!Get.isRegistered<IsmLiveStreamController>()) return;
          final room = _controller.room;
          if (room == null) {
            return;
          }
          if (_controller.speakerOn) {
            // Host unmuted their mic — the audio session may have been
            // reconfigured. Re-apply loudspeaker routing to prevent earpiece.
            unawaited(Future<void>(() async {
              await Future<void>.delayed(const Duration(milliseconds: 150));
              if (!Get.isRegistered<IsmLiveStreamController>()) return;
              if (_controller.room != room || !_controller.speakerOn) return;
              await _ensureLoudspeakerRouting(withRetry: true);
            }));
          }
          // A remote audio track was unmuted by the server/host. Re-apply local
          // mute so the viewer's mute choice is honoured.
          unawaited(Future<void>(() async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            if (!Get.isRegistered<IsmLiveStreamController>()) return;
            if (_controller.room != room) {
              return;
            }
            await _syncRemoteAudioPlaybackWithSpeakerFlag(room);
          }));
        });

  Future<void> sortParticipants() async {
    _participantDebouncer.run(_sortParticipants);

    // if (_controller.participantTracks.length != 2) {
    //   _controller.pkStages = null;
    // }
  }

  Future<void> _sortParticipants() async {
    if (!Get.isRegistered<IsmLiveStreamController>()) return;
    final room = _controller.room;
    if (room == null) {
      return;
    }
    var userMediaTracks = <IsmLiveParticipantTrack>[];

    final localParticipantTracks =
        room.localParticipant?.videoTrackPublications;
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

    for (var participant in room.remoteParticipants.values) {
      for (var t in participant.videoTrackPublications) {
        userMediaTracks.add(
          IsmLiveParticipantTrack(
            participant: participant,
            videoTrack: t.track,
            isScreenShare: t.isScreenShare,
          ),
        );
      }
    }

    // Ensure a stable ordering across clients.
    //
    // LiveKit's `remoteParticipants` is a Map; `.values` iteration order can vary
    // between clients causing a "random" grid ordering for viewers.
    //
    // Additionally, some UI (e.g. publisher grid) relies on `participantList`
    // as the display-order list (PK can reverse it when swapping host), while
    // this method previously only updated `participantTracks`, causing mismatch.
    final orderedTracks = _orderParticipantTracksForDisplay(
      tracks: userMediaTracks,
      previousDisplayOrder: _controller.participantList,
      hostUserId: _controller.hostDetails?.userId,
    );

    _controller.participantTracks = orderedTracks;
    _controller.participantList = orderedTracks;
    _controller.update([IsmLiveStreamView.updateId]);

    if (_controller.isPk &&
        _controller.participantTracks.length == 2 &&
        ((_controller.userRole?.isHost ?? false) ||
            (_controller.userRole?.isPkGuest ?? false))) {
      if (IsmLiveUtility.isAnyBottomSheetOpen) {
        IsmLiveRoute.pop();
      }
      IsmLiveDebouncer(durationtime: 3000).run(() async {
        try {
          await _controller.animationController.forward();
        } catch (e) {
          IsmLiveLog('animation error - $e');
        }
      });
    }
  }

  List<IsmLiveParticipantTrack> _orderParticipantTracksForDisplay({
    required List<IsmLiveParticipantTrack> tracks,
    required List<IsmLiveParticipantTrack> previousDisplayOrder,
    required String? hostUserId,
  }) {
    String keyOf(IsmLiveParticipantTrack t) =>
        '${t.participant.identity}|${t.isScreenShare ? 1 : 0}';

    int deterministicCompare(IsmLiveParticipantTrack a, IsmLiveParticipantTrack b) {
      final aIsHost = hostUserId != null && a.participant.identity == hostUserId;
      final bIsHost = hostUserId != null && b.participant.identity == hostUserId;
      if (aIsHost != bIsHost) return aIsHost ? -1 : 1;

      // Prefer camera feed before screen share for the same participant.
      if (a.isScreenShare != b.isScreenShare) {
        return a.isScreenShare ? 1 : -1;
      }

      // Stable tie-breaker by identity (string compare is consistent across clients).
      return a.participant.identity.compareTo(b.participant.identity);
    }

    // Build a lookup from (identity + screenshare flag) => latest track instance.
    // If duplicates exist, keep the last one (they are equivalent for ordering).
    final byKey = <String, IsmLiveParticipantTrack>{};
    for (final t in tracks) {
      byKey[keyOf(t)] = t;
    }

    // 1) Preserve prior display order when possible (important for PK host swap),
    // 2) Append any newly-seen tracks in deterministic order.
    final ordered = <IsmLiveParticipantTrack>[];
    if (previousDisplayOrder.isNotEmpty) {
      for (final prev in previousDisplayOrder) {
        final k = keyOf(prev);
        final current = byKey.remove(k);
        if (current != null) {
          ordered.add(current);
        }
      }
    }

    final remaining = byKey.values.toList()..sort(deterministicCompare);
    ordered.addAll(remaining);
    return ordered;
  }

  String controlIcon(IsmLiveStreamOption option) {
    switch (option) {
      case IsmLiveStreamOption.gift:
      case IsmLiveStreamOption.multiLive:
      case IsmLiveStreamOption.share:
      case IsmLiveStreamOption.members:
      case IsmLiveStreamOption.scheduleModify:
      case IsmLiveStreamOption.bars:
      case IsmLiveStreamOption.vs:
      case IsmLiveStreamOption.settings:
      case IsmLiveStreamOption.rotateCamera:
      case IsmLiveStreamOption.product:
      case IsmLiveStreamOption.pk:
      case IsmLiveStreamOption.heart:
        return option.icon;
      case IsmLiveStreamOption.speaker:
        if (_controller.speakerOn) {
          return IsmLiveAssetConstants.speakerOn;
        }
        return IsmLiveAssetConstants.speakerOff;
    }
  }

  /// Gets the actual video status from the room's local participant
  /// Checks if video track is published and enabled (not muted)
  bool _getActualVideoStatus() {
    try {
      final room = _controller.room;
      if (room == null || room.localParticipant == null) {
        return _controller.videoOn; // Fallback to boolean if room not available
      }

      final localParticipant = room.localParticipant!;
      final videoTrackPublication = localParticipant.videoTrackPublications
          .where((pub) => !pub.isScreenShare)
          .firstOrNull;

      if (videoTrackPublication == null) {
        // No video track published, video is off
        return false;
      }

      // Check if track exists and is not muted
      final track = videoTrackPublication.track;
      if (track == null) {
        return false;
      }

      // Track is enabled if it exists and is not muted
      final isEnabled = !track.muted;

      // Sync the boolean with actual status to keep it accurate
      if (_controller.videoOn != isEnabled) {
        _controller.videoOn = isEnabled;
      }

      return isEnabled;
    } catch (e) {
      IsmLiveLog.error('Error getting actual video status: $e');
      // Fallback to boolean on error
      return _controller.videoOn;
    }
  }

  /// Gets the actual audio status from the room's local participant
  /// Checks if audio track is published and enabled (not muted)
  bool _getActualAudioStatus() {
    try {
      final room = _controller.room;
      if (room == null || room.localParticipant == null) {
        return _controller.audioOn; // Fallback to boolean if room not available
      }

      final localParticipant = room.localParticipant!;
      final audioTrackPublication =
          localParticipant.audioTrackPublications.firstOrNull;

      if (audioTrackPublication == null) {
        // No audio track published, audio is off
        return false;
      }

      // Check if track exists and is not muted
      final track = audioTrackPublication.track;
      if (track == null) {
        return false;
      }

      // Track is enabled if it exists and is not muted
      final isEnabled = !track.muted;

      // Sync the boolean with actual status to keep it accurate
      if (_controller.audioOn != isEnabled) {
        _controller.audioOn = isEnabled;
      }

      return isEnabled;
    } catch (e) {
      IsmLiveLog.error('Error getting actual audio status: $e');
      // Fallback to boolean on error
      return _controller.audioOn;
    }
  }

  String controlSettingIcon(IsmLiveHostSettings option) {
    switch (option) {
      case IsmLiveHostSettings.muteMyVideo:
        return _getActualVideoStatus() ? option.icon : option.offIcon;
      case IsmLiveHostSettings.muteMyAudio:
        return _getActualAudioStatus() ? option.icon : option.offIcon;
    }
  }

  // Function to handle actions on stream controls
  String controlSetting(IsmLiveHostSettings option) {
    switch (option) {
      case IsmLiveHostSettings.muteMyVideo:
        return _getActualVideoStatus()
            ? option.muteValues
            : option.unmuteValues;
      case IsmLiveHostSettings.muteMyAudio:
        return _getActualAudioStatus()
            ? option.muteValues
            : option.unmuteValues;
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
    if (viewers.isEmpty) {
      return;
    }
    final list = List<IsmLiveViewerModel>.from(_controller.streamViewersList);
    for (final v in viewers) {
      if (v.userId.isEmpty) {
        continue;
      }
      final i = list.indexWhere((e) => e.userId == v.userId);
      if (i >= 0) {
        list[i] = v;
      } else {
        list.add(v);
      }
    }
    _controller.streamViewersList = list;
  }

// Function to add messages to the stream
  Future<void> addMessages(
    List<IsmLiveMessageModel> messages, [
    bool isMqtt = true,
  ]) async {
    // Keep internal lifecycle probe messages out of chat UI.
    const foregroundCapabilityProbeBody = '__ism_live_foreground_probe__';
    final visibleMessages = messages
        .where((message) => message.body != foregroundCapabilityProbeBody)
        .toList();
    if (visibleMessages.isEmpty) {
      return;
    }

    final chats = visibleMessages
        .map((e) => _controller.convertMessageToChat(e))
        .toList();

    if (isMqtt) {
      _controller.streamMessagesList.addAll(chats);
    } else {
      _controller.streamMessagesList.insertAll(0, chats);
    }

    _controller.streamMessagesList =
        _controller.streamMessagesList.toSet().toList();
  }

  static const int _heartFlushThreshold = 15;

  void addHeart(IsmLiveMessageModel message, {int count = 1}) {
    for (var i = 0; i < count; i++) {
      final id = '${message.messageId}_$i';
      if (i == 0) {
        _insertHeartAnimation(id);
      } else {
        Future.delayed(Duration(milliseconds: i * 120), () {
          _insertHeartAnimation(id);
        });
      }
    }
  }

  void _addLocalHeart() {
    final id = 'local_${_heartIdCounter++}';
    _insertHeartAnimation(id);
  }

  void _insertHeartAnimation(String id) {
    final key = ValueKey(id);
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
  }

  void _scheduleHeartFlush() {
    _pendingHeartCount++;
    if (_pendingHeartCount >= _heartFlushThreshold) {
      _heartDebounceTimer?.cancel();
      _heartDebounceTimer = null;
      _flushPendingHearts();
      return;
    }
    _heartDebounceTimer?.cancel();
    _heartDebounceTimer = Timer(
      const Duration(milliseconds: 500),
      _flushPendingHearts,
    );
  }

  void _flushPendingHearts() {
    final count = _pendingHeartCount;
    _pendingHeartCount = 0;
    _heartDebounceTimer?.cancel();
    _heartDebounceTimer = null;
    if (count <= 0) return;
    final streamId = _controller.streamId ?? '';
    if (streamId.isEmpty) return;
    unawaited(_flushHeartsWithDelegate(streamId, count));
  }

  Future<void> _flushHeartsWithDelegate(String streamId, int count) async {
    await _controller.sendHeartMessage(streamId, count: count);
    final delegate = IsmLiveDelegate.heartBatchFlushCallback;
    if (delegate != null) {
      unawaited(_invokeHeartBatchFlushDelegate(delegate, streamId, count));
    }
  }

  Future<void> _invokeHeartBatchFlushDelegate(
    HeartBatchFlushCallback delegate,
    String streamId,
    int count,
  ) async {
    try {
      await delegate(streamId, count);
    } catch (e, st) {
      IsmLiveLog.error('heartBatchFlushCallback error: $e', st);
    }
  }

  void cancelHeartDebounce() {
    _heartDebounceTimer?.cancel();
    _heartDebounceTimer = null;
    _pendingHeartCount = 0;
    _heartIdCounter = 0;
  }

  // Function to add gift message to the stream
  void addGift(IsmLiveMessageModel message, Map<String, dynamic> payload) {
    _controller.giftMessages.add(message);
    if (_controller.giftMessages.length == 1) {
      _handleGift(message, payload);
    }
  }

  void _handleGift(IsmLiveMessageModel message, Map<String, dynamic> payload) {
    if (message.customType == null) {
      return;
    }
    final key = ValueKey(message.messageId);

    final data = payload['metaData'];

    final child = IsmLiveGif(path: data['message']);
    _controller.giftList.insert(
      0,
      IsmLiveGiftView(
        key: key,
        child: child,
        onComplete: () {
          _controller.giftList.removeWhere((e) => e.key == key);
          _controller.giftMessages.removeAt(0);
          if (_controller.giftMessages.isNotEmpty) {
            _handleGift(_controller.giftMessages.first, payload);
          }
        },
      ),
    );
  }

  /// Remote publication enable/disable controls server/adaptive settings, not
  /// what you hear. Toggle each remote audio track's enable/disable so the
  /// underlying WebRTC track matches the speaker UI.
  Future<void> _syncRemoteAudioPlaybackWithSpeakerFlag(lk.Room room) async {
    final speakerOn = _controller.speakerOn;

    // Route audio to the loudspeaker when enabling. Mobile WebRTC defaults to
    // the earpiece/receiver; without this call viewers hear audio from the
    // wrong speaker (or faintly through the receiver when muted).
    // The helper respects external devices (Bluetooth/wired) on Android.
    if (speakerOn) {
      await _ensureLoudspeakerRouting();
    }

    final futures = <Future<void>>[];
    for (final participant in room.remoteParticipants.values) {
      for (final pub in participant.audioTrackPublications) {
        final track = pub.track;
        if (track == null) {
          continue;
        }
        futures.add(() async {
          try {
            if (speakerOn) {
              await track.enable();
            } else {
              await track.disable();
            }
            // Belt-and-suspenders: directly flip the underlying WebRTC
            // MediaStreamTrack. On some mobile platforms the higher-level
            // enable/disable alone does not silence the audio renderer.
            try {
              track.mediaStreamTrack.enabled = speakerOn;
            } catch (_) {}
          } catch (e) {
            IsmLiveLog('speaker remote audio track error $e');
          }
        }());
      }
    }
    await Future.wait(futures);
  }

  Future<void> toggleSpeaker({
    bool? value,
  }) async {
    // Update UI state immediately (even if there are no remote audio tracks yet).
    final nextValue = value ?? !_controller.speakerOn;
    _controller.speakerOn = nextValue;
    _controller.update([
      IsmLiveStreamView.updateId,
      IsmLiveControlsWidget.updateId,
    ]);

    final room = _controller.room;
    if (room == null) {
      return;
    }

    try {
      await _syncRemoteAudioPlaybackWithSpeakerFlag(room);
    } catch (e) {
      IsmLiveLog('speaker error $e');
    }
  }

  Future onOptionTap(IsmLiveStreamOption option, BuildContext context) async {
    switch (option) {
      case IsmLiveStreamOption.gift:
        _controller.giftsSheet();
        break;
      case IsmLiveStreamOption.multiLive:
        if (_controller.isHost || _controller.isPublishing) {
          _controller.copublishingHostSheet();
        } else {
          if (_controller.memberStatus.canEnableVideo) {
            _controller.copublishingStartVideoSheet(context);
          } else {
            _controller.copublishingViewerSheet(context);
          }
        }

        break;
      case IsmLiveStreamOption.share:
        _controller.shareStream();
        break;
      case IsmLiveStreamOption.members:
        break;
      case IsmLiveStreamOption.scheduleModify:
        _controller.schgeduleStreamSheet();
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
        final context = IsmLiveUtility.navigatorKey.currentContext!;
        await IsmLiveUtility.openBottomSheet(
          IsmliveAnalyticsSheet(
            streamId: (_controller.userRole?.isPkGuest ?? false)
                ? _pkController.pkguestStreamId ?? ''
                : _controller.streamId ?? '',
          ),
          backgroundColor: context.liveTheme?.backgroundColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF121212)
                  : Colors.white),
        );
        break;
      case IsmLiveStreamOption.vs:
        _controller.pkSheet();
        break;
      case IsmLiveStreamOption.heart:
        // Tap feedback runs from the stream controls widget via native Android/iOS.
        _addLocalHeart();
        _scheduleHeartFlush();
        break;
      case IsmLiveStreamOption.pk:
        _pkController.stopPkBattleSheet();
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

  void onScheduleSettingTap(
    IsmLiveScheduleSettings option,
  ) async {
    switch (option) {
      case IsmLiveScheduleSettings.edit:
        IsmLiveRoute.pop();
        IsmLiveRouteManagement.goToGoLiveView(
          popPrevious: true,
          editStreamData: _controller.streamDetails,
        );
        break;
      case IsmLiveScheduleSettings.delete:
        IsmLiveRoute.pop();
        await _controller
            .deleteScheduledStream(_controller.streamDetails?.eventId ?? '');
        IsmLiveRoute.pop();
        _controller.streamDispose();
        unawaited(_controller.getStreams());
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

  bool onChangeCall = false;

  int? _pendingScrollIndex;

  void onStreamScroll({
    required int index,
    required BuildContext context,
  }) async {
    if (onChangeCall) {
      _pendingScrollIndex = index;
      return;
    }

    // Guard: avoid RangeError when streams list is empty or index is invalid
    if (_controller.streams.isEmpty ||
        index < 0 ||
        index >= _controller.streams.length) {
      return;
    }

    // Notify host app about stream scroll (fire and forget)
    IsmLiveDelegate.onStreamScrollCallback?.call(
      context,
      _controller.streamId ?? '',
      index,
      _controller.streams[index],
      _controller.isHost,
    );

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.streamScroll,
      properties: [
        {
          'current_stream_id': _controller.streamId ?? '',
          'next_stream_index': index,
          'next_stream_id': _controller.streams[index].streamId ?? '',
          'is_host': _controller.isHost,
        }
      ],
    );

    IsmLiveUtility.showLoader();
    onChangeCall = true;
    _pendingScrollIndex = null;

    // Cancel any in-flight deferred connection from the initial stream load.
    // Without this, completeDeferredConnection can race with the scroll-based
    // disconnect+join, causing ICE timeout and a broken state.
    _controller.pendingConnection = false;

    if (_controller.streams.length - 1 == index + 1) {
      unawaited(_controller.getStreams(
        skip: _controller.streams.length,
        type: _controller.streamType,
      ));
    }

    try {
      final didLeft = await disconnectStream(
        isHost: false,
        streamId: _controller.streamId ?? '',
        goBack: false,
        isScrolling: true,
      );
      if (!didLeft) {
        IsmLiveLog.error('Cannot leave stream');
      }

      // If user scrolled further while we were disconnecting, skip joining
      // the intermediate stream and jump straight to the latest target.
      if (_pendingScrollIndex != null && _pendingScrollIndex != index) {
        return;
      }

      if ((_controller.streams[index].isPaid ?? false) &&
          !(_controller.streams[index].isBuy ?? false)) {
        IsmLiveUtility.closeLoader();
        _controller.paidStreamSheet(
            coins: _controller.streams[index].amount ?? 0,
            onTap: () async {
              IsmLiveRoute.pop();
              var res = await _controller
                  .buyStream(_controller.streams[index].streamId ?? '');
              if (res) {
                _controller.streams[index].copyWith(isBuy: true);
                await _controller.joinStream(
                  _controller.streams[index],
                  false,
                  joinByScrolling: true,
                  isScrolling: true,
                  context: context,
                );
              }
            });
      } else {
        await _controller.joinStream(
          _controller.streams[index],
          false,
          joinByScrolling: true,
          isScrolling: true,
          context: context,
        );
      }

      _controller.previousStreamIndex = index;
    } catch (e, st) {
      IsmLiveLog.error('onStreamScroll error: $e', st);
    } finally {
      onChangeCall = false;
      IsmLiveUtility.closeLoader();

      // Process the latest pending scroll after this operation completes.
      // This runs inside finally so onChangeCall is already false, and the
      // recursive call will set it back to true synchronously (before its
      // first await), preventing concurrent entry.
      final pending = _pendingScrollIndex;
      if (pending != null) {
        _pendingScrollIndex = null;
        onStreamScroll(index: pending, context: context);
      }
    }
  }

  bool isStopStreamCall = false;

  Future<bool> disconnectStream({
    required bool isHost,
    required String streamId,
    bool goBack = true,
    bool endStream = true,
    bool isScrolling = false,
  }) async {
    _controller.isViewerJoiningStream = false;
    if (_controller.streamId?.isEmpty ?? true) {
      if (!isScrolling) {
        // IsmLiveUtility.closeLoader();
        // await _controller.animateToPage(_controller.previousStreamIndex);
        _controller.streamDispose();
        unawaited(_controller.getStreams());
        closeStreamView(
          false,
        );
      }
      return false;
    }
    if (isStopStreamCall) {
      return false;
    }
    isStopStreamCall = true;
    var isEnded = false;

    // Determine the disconnect type based on user role
    IsmLiveStreamDisconnectType? disconnectType;
    if (isHost) {
      disconnectType = IsmLiveStreamDisconnectType.host;
    } else if (_controller.userRole?.isPkGuest ?? false) {
      disconnectType = IsmLiveStreamDisconnectType.pkGuest;
    } else if (_controller.isCopublisher) {
      disconnectType = IsmLiveStreamDisconnectType.copublisher;
    } else {
      disconnectType = IsmLiveStreamDisconnectType.viewer;
    }

    // Use the unified API handler if provided, otherwise use default SDK behavior
    if (IsmLiveDelegate.streamDisconnectApiHandler != null) {
      // Host app provides custom API implementation
      isEnded = await IsmLiveDelegate.streamDisconnectApiHandler!(
          streamId, disconnectType);
    } else {
      // Default SDK behavior
      switch (disconnectType) {
        case IsmLiveStreamDisconnectType.host:
          await _controller.stopStream(
              streamId, _controller.user?.userId ?? '');
          isEnded = true;
          break;
        case IsmLiveStreamDisconnectType.pkGuest:
          await _pkController.pkEnd(intentToStop: false);
          isEnded = true;
          break;
        case IsmLiveStreamDisconnectType.copublisher:
          await _controller.leaveMember(streamId: streamId);
          isEnded = true;
          break;
        case IsmLiveStreamDisconnectType.viewer:
          await _controller.leaveStream(streamId);
          isEnded = true;
          break;
      }
    }

    if (isEnded && endStream) {
      // unawaited(_controller._mqttController?.unsubscribeStream(streamId));
      if (isHost) {
        unawaited(_controller._dbWrapper.deleteSecuredValue(streamId));
      }

      // Set stream as inactive for background lifecycle
      _controller.setStreamActive(false, isHost);

      await disconnectRoom();

      if (goBack) {
        unawaited(_controller.getStreams());
        closeStreamView(isHost, streamId: streamId);
      }
    }

    _controller.triggerOnStreamEndOnce();
    isStopStreamCall = false;

    return isEnded;
  }

  Future<void> disconnectRoom([bool callDispose = true]) async {
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      return;
    }
    _controller.isViewerJoiningStream = false;

    // Capture room reference synchronously BEFORE any await. When this method
    // is called fire-and-forget (e.g. from MQTT viewerRemoved / streamStopped),
    // a concurrent streamDispose triggered by route-pop can null _controller.room
    // during the MQTT-unsubscribe await, causing room.disconnect() to be skipped
    // entirely and leaving remote audio playing.
    final room = _controller.room;

    final currentStreamId = _controller.streamId;
    if (currentStreamId != null && currentStreamId.isNotEmpty) {
      if (IsmLiveDelegate.unsubscribStreamById != null) {
        IsmLiveDelegate.unsubscribStreamById!(currentStreamId);
      } else {
        await _controller._mqttController?.unsubscribeStream(currentStreamId);
      }
    }

    try {
      if (room != null) {
        // Explicitly stop local media tracks to release camera/mic hardware on
        // iOS. room.disconnect() alone does not guarantee native hardware
        // release, especially when the room already reports disconnected
        // (e.g. after internet fluctuation).
        final lp = room.localParticipant;
        if (lp != null) {
          // Snapshot track references before unpublishing (avoids concurrent
          // modification and captures tracks that unpublish may clear).
          final videoTracks = lp.videoTrackPublications
              .map((pub) => pub.track)
              .whereType<lk.LocalVideoTrack>()
              .toList();
          final audioTracks = lp.audioTrackPublications
              .map((pub) => pub.track)
              .whereType<lk.LocalAudioTrack>()
              .toList();
          try {
            await lp.unpublishAllTracks();
          } catch (_) {}
          for (final t in videoTracks) {
            try {
              await t.stop();
            } catch (_) {}
          }
          for (final t in audioTracks) {
            try {
              await t.stop();
            } catch (_) {}
          }
        }

        if (room.connectionState != lk.ConnectionState.disconnected) {
          await room.disconnect();
        }
      }

      _controller.userRole = null;

      // Only clear streamId if not preventing disposal (e.g., during rejoin)
      if (!_controller.preventDispose) {
        _controller.streamId = null;
      }

      _pkController.pkTimer?.cancel();
      _pkController.pkTimer = null;
      _controller.streamTimer?.cancel();
      _controller.streamTimer = null;

      IsmLiveUtility.updateLater(() {
        if (Get.isRegistered<IsmLiveStreamController>()) {
          _controller.streamDispose(callDispose);
        }
      });
      // Let LiveKit/native teardown settle before the next navigation. A single
      // short deferral avoids the old 2s stacked delays (here + disconnectStream).
      // Skipped when callDispose is false (e.g. PK rejoin) so reconnect stays fast.
      if (!_controller.isHost && callDispose) {
        await Future.delayed(const Duration(milliseconds: 350));
      }
    } catch (e, st) {
      IsmLiveLog.error(' end stream  $e , $st');
    }
  }

  void closeStreamView(bool isHost, {String? streamId, bool fromMqtt = false}) {
    _controller.streamTimer?.cancel();
    _controller.streamTimer = null;
    _pkController.pkTimer?.cancel();
    _pkController.pkTimer = null;

    if (isHost) {
      IsmLiveRouteManagement.goToEndStreamView(streamId!);
    } else {
      IsmLiveUtility.popUntilStreamView();
      IsmLiveRoute.pop();
      if (fromMqtt) {
        IsmLiveUtility.showCustomDialog(const IsmLiveStreamEndDialog());
      }
    }
  }
}
