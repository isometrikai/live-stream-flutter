part of '../stream_controller.dart';

mixin StreamOngoingParticipantsMixin
    on StreamOngoingMixin, StreamOngoingChatMixin, StreamOngoingControlsMixin {
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
          streamId: streamId,
          messageType:
              IsmLiveDelegate.streamScreenConfigure.resolvedChatMessageTypes,
        ),
      );

      if (_controller.messagesCount != 0) {
        unawaited(
          _controller.fetchMessages(
            showLoading: false,
            getMessageModel: IsmLiveGetMessageModel(
              streamId: streamId,
              messageType: IsmLiveDelegate
                  .streamScreenConfigure.resolvedChatMessageTypes,
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
    // Apply the current speaker/mute preference on mobile.
    //
    // Previously this forced `speakerOn = true` unconditionally, which undid
    // a viewer's client-side host mute whenever `initializeStream` re-ran on
    // a rejoin (e.g. foreground resume after background rebuilt the LiveKit
    // room via `_connectRoomAndInitialize`). The fresh room's incoming
    // `TrackSubscribedEvent` would then sync against the now-true flag and
    // re-enable the host's audio track.
    //
    // On initial join `speakerOn` defaults to `true`, so first-join behaviour
    // is unchanged; on rejoin we honour whatever the viewer last chose.
    if (lk.lkPlatformIsMobile()) {
      unawaited(_controller.toggleSpeaker(value: _controller.speakerOn));
    }
    // Update stream view
    IsmLiveUtility.updateLater(() {
      _controller.update([IsmLiveStreamView.updateId]);
    });
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
        ..on<lk.TrackPublishedEvent>((event) {
          if (event.publication.kind != lk.TrackType.VIDEO) {
            return;
          }
          IsmLiveLog.info(
            'TrackPublishedEvent: identity=${event.participant.identity} '
            'sid=${event.publication.sid} subscribed=${event.publication.subscribed} '
            'subscriptionAllowed=${event.publication.subscriptionAllowed} '
            'isRtmp=${_controller.isRtmp}',
          );
          if (_controller.isRtmp &&
              !event.publication.subscribed &&
              event.publication.subscriptionAllowed) {
            unawaited(() async {
              try {
                await event.publication.subscribe();
                IsmLiveLog.info(
                  'TrackPublishedEvent: subscribe requested for '
                  '${event.participant.identity}',
                );
              } catch (e, st) {
                IsmLiveLog.error(
                  'TrackPublishedEvent: subscribe failed for '
                  '${event.participant.identity}: $e',
                  st,
                );
              }
              await sortParticipants();
            }());
            return;
          }
          sortParticipants();
        })
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
          if (event.track.kind == lk.TrackType.VIDEO) {
            // Remote co-publisher video arrives after publish; refresh track list
            // so publisher grid gets a non-null VideoTrack (was stale on publish-only sort).
            sortParticipants();
            return;
          }
          if (!Get.isRegistered<IsmLiveStreamController>()) return;
          final room = _controller.room;
          if (room == null) {
            return;
          }
          if (_controller.speakerOn) {
            // Remote audio track just arrived â€” WebRTC's track subscription
            // can reconfigure the audio session and reset routing back to the
            // earpiece on some devices (Redmi/Xiaomi, certain iOS versions).
            // Re-apply loudspeaker routing after the track is fully started.
            unawaited(Future<void>(() async {
              await Future<void>.delayed(const Duration(milliseconds: 150));
              if (!Get.isRegistered<IsmLiveStreamController>()) return;
              if (_controller.room != room || !_controller.speakerOn) return;
              await _ensureLoudspeakerRouting(withRetry: true, forRoom: room);
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
        ..on<lk.TrackUnsubscribedEvent>((event) {
          if (event.track.kind == lk.TrackType.VIDEO) {
            sortParticipants();
          }
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
            // Host unmuted their mic â€” the audio session may have been
            // reconfigured. Re-apply loudspeaker routing to prevent earpiece.
            unawaited(Future<void>(() async {
              await Future<void>.delayed(const Duration(milliseconds: 150));
              if (!Get.isRegistered<IsmLiveStreamController>()) return;
              if (_controller.room != room || !_controller.speakerOn) return;
              await _ensureLoudspeakerRouting(withRetry: true, forRoom: room);
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

    if (_controller.isRtmp) {
      await _ensureRtmpRemoteVideoSubscriptions(room);
    }

    _controller.participantTracks = orderedTracks;
    _controller.participantList = orderedTracks;
    _logParticipantTrackDiagnostics(room, userMediaTracks, orderedTracks);
    _controller.update([
      IsmLiveStreamView.updateId,
      IsmLivePublisherGrid.updateId,
    ]);

    if (_controller.isPk &&
        _controller.participantTracks.length == 2 &&
        ((_controller.userRole?.isHost ?? false) ||
            (_controller.userRole?.isPkGuest ?? false))) {
      if (IsmLiveUtility.isAnyBottomSheetOpen) {
        IsmLiveRoute.pop();
      }
      IsmLiveDebouncer(durationtime: 3000).run(() async {
        try {
          if (_controller.animationController.isCompleted ||
              _controller.animationController.isDismissed) {
            _controller.animationController.reset();
          }
          await _controller.animationController.forward();
        } catch (e) {
          IsmLiveLog('animation error - $e');
        }
      });
    }
  }

  /// RTMP co-publishers often join after the host ingest is already live.
  /// Request explicit video subscriptions so their tracks are not left
  /// published-but-unsubscribed on the viewer client.
  Future<void> _ensureRtmpRemoteVideoSubscriptions(lk.Room room) async {
    for (final participant in room.remoteParticipants.values) {
      for (final pub in participant.videoTrackPublications) {
        if (pub.subscribed || !pub.subscriptionAllowed) {
          continue;
        }
        try {
          await pub.subscribe();
          IsmLiveLog.info(
            'RTMP remote video subscribe: identity=${participant.identity} '
            'sid=${pub.sid}',
          );
        } catch (e, st) {
          IsmLiveLog.error(
            'RTMP remote video subscribe failed: '
            'identity=${participant.identity} sid=${pub.sid}: $e',
            st,
          );
        }
      }
    }
  }

  void _logParticipantTrackDiagnostics(
    lk.Room room,
    List<IsmLiveParticipantTrack> rawTracks,
    List<IsmLiveParticipantTrack> orderedTracks,
  ) {
    final remoteCount = room.remoteParticipants.length;
    var remoteVideoPubs = 0;
    var remoteVideoSubscribedFlag = 0;
    var remoteVideoWithTrack = 0;
    final remoteSummaries = <String>[];
    final hostUserId = _controller.hostDetails?.userId;

    for (final participant in room.remoteParticipants.values) {
      final pubs = participant.videoTrackPublications;
      remoteVideoPubs += pubs.length;
      for (final pub in pubs) {
        if (pub.subscribed) {
          remoteVideoSubscribedFlag++;
        }
        if (pub.track != null) {
          remoteVideoWithTrack++;
        }
      }
      final pubDetails = pubs
          .map(
            (pub) => 'sid=${pub.sid.substring(0, min(8, pub.sid.length))}..'
                'sub=${pub.subscribed}'
                'track=${pub.track != null}'
                'allowed=${pub.subscriptionAllowed}',
          )
          .join(';');
      remoteSummaries.add(
        '${participant.identity}${participant.identity == hostUserId ? '(host)' : ''}: '
        'pubs=${pubs.length} [$pubDetails]',
      );
    }

    final orderedSummary = orderedTracks
        .map(
          (t) =>
              '${t.participant.identity}${t.isScreenShare ? '(screen)' : ''}:'
              'track=${t.videoTrack != null}',
        )
        .join(', ');

    final coPublisherTrackCount = hostUserId == null
        ? orderedTracks.length
        : orderedTracks
            .where((t) => t.participant.identity != hostUserId)
            .length;

    IsmLiveLog.info(
      'sortParticipants: isRtmp=${_controller.isRtmp} '
      'hostUserId=$hostUserId '
      'remoteParticipants=$remoteCount '
      'remoteVideoPublications=$remoteVideoPubs '
      'remoteVideoSubscribedFlag=$remoteVideoSubscribedFlag '
      'remoteVideoWithTrack=$remoteVideoWithTrack '
      'coPublisherTracksInGrid=$coPublisherTrackCount '
      'rawTracks=${rawTracks.length} orderedTracks=${orderedTracks.length} '
      '[$orderedSummary]',
    );
    if (remoteSummaries.isNotEmpty) {
      IsmLiveLog.info(
          'sortParticipants remote: ${remoteSummaries.join(' | ')}');
    } else if (_controller.isRtmp) {
      IsmLiveLog.info(
        'sortParticipants remote: none (only local/ingest tracks in room)',
      );
    }
  }

  List<IsmLiveParticipantTrack> _orderParticipantTracksForDisplay({
    required List<IsmLiveParticipantTrack> tracks,
    required List<IsmLiveParticipantTrack> previousDisplayOrder,
    required String? hostUserId,
  }) {
    String keyOf(IsmLiveParticipantTrack t) =>
        '${t.participant.identity}|${t.isScreenShare ? 1 : 0}';

    int deterministicCompare(
        IsmLiveParticipantTrack a, IsmLiveParticipantTrack b) {
      final aIsHost =
          hostUserId != null && a.participant.identity == hostUserId;
      final bIsHost =
          hostUserId != null && b.participant.identity == hostUserId;
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
      case IsmLiveStreamOption.rtmpDetails:
      case IsmLiveStreamOption.videoEffects:
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
}
