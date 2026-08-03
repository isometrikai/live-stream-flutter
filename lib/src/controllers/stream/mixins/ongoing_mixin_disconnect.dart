part of '../stream_controller.dart';

mixin StreamOngoingDisconnectMixin on StreamOngoingMixin {
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

    if (isEnded) {
      if (disconnectType == IsmLiveStreamDisconnectType.host) {
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.streamEnded,
          properties: [
            {
              'stream_id': streamId,
              'disconnect_type': disconnectType.name,
              'user_id': _controller.user?.userId ?? '',
              'user_name':
                  _controller.user?.userName ?? _controller.user?.name ?? '',
            }
          ],
        );
      } else if (disconnectType == IsmLiveStreamDisconnectType.viewer) {
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.streamLeave,
          properties: [
            {
              'stream_id': streamId,
              'disconnect_type': disconnectType.name,
              'initiator_user_id': _controller.user?.userId ?? '',
              'initiator_user_name':
                  _controller.user?.userName ?? _controller.user?.name ?? '',
              'user_id': _controller.streamDetails?.userId ??
                  _controller.streamDetails?.userDetails?.id ??
                  '',
              'user_name': _controller.streamDetails?.userDetails?.userName ??
                  _controller.streamDetails?.userDetails?.name ??
                  '',
            }
          ],
        );
      }
    }

    if (isEnded && endStream) {
      // unawaited(_controller._mqttController?.unsubscribeStream(streamId));
      unawaited(_controller._dbWrapper.deleteSecuredValue(streamId));

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

    // Idempotent for the current stream lifecycle. Once closeStreamView has
    // marked the lifecycle closed, a second disconnectRoom (e.g., the local
    // disconnectStream completing its API await AFTER MQTT-broadcast
    // streamStopped already drove the close path) would re-fire streamDispose
    // and wipe state on the next-mounted view (notably IsmLiveEndStream after
    // its analytics load). The guard is reset at the top of [connectStream]
    // via [resetOnStreamEndTrigger], so subsequent stream sessions are
    // unaffected. PK rejoin uses preventDispose=true and is unaffected.
    if (_controller._hasClosedStreamView && !_controller.preventDispose) {
      IsmLiveLog(
          'disconnectRoom skipped: stream lifecycle already closed (concurrent close path)');
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
          try {
            await _controller.deepArPublisher?.stop();
          } catch (_) {}
          _controller.deepArPublisher = null;
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
    if (!_controller.tryMarkStreamViewClosed()) {
      IsmLiveLog(
          'closeStreamView skipped: already handled for current stream lifecycle');
      return;
    }

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