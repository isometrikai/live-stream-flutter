part of '../stream_controller.dart';

// Foreground / role-change rejoin flows.
mixin StreamJoinRejoinMixin on StreamJoinMixin, StreamJoinConnectionMixin {
  /// Viewer / PK-guest: rejoin the currently open stream after app resumes.
  ///
  /// Why this exists:
  /// - When coming back from background, message/probe APIs may fail with 400
  ///   (viewer not considered a member). Reconnecting LiveKit with an old token
  ///   can also produce SDP order errors.
  /// - Reuses the token saved on the original join (`publishPk` for PK guests,
  ///   `getRTCToken` for viewers) from [rtcToken], [storedToken], or secure storage
  ///   before requesting a new token.
  Future<bool> rejoinCurrentViewerStreamAfterForeground({
    bool showProgress = true,
  }) async {
    final context = IsmLiveUtility.navigatorKey.currentContext;
    if (context == null) {
      IsmLiveLog.error(
          'rejoinCurrentViewerStreamAfterForeground: navigator context is null');
      return false;
    }

    final streamId = _controller.streamId;
    if (streamId == null || streamId.isEmpty) {
      IsmLiveLog.error(
          'rejoinCurrentViewerStreamAfterForeground: streamId missing');
      return false;
    }

    final details = _controller.streamDetails;

    // Capture before `_connectRoomAndInitialize` resets role/PK flags.
    final wasPkGuest = _controller.userRole?.isPkGuest ?? false;
    final reconnectAsPkGuest = wasPkGuest;
    final reconnectAsPk = wasPkGuest ||
        _controller.isPk ||
        (details?.isPkChallenge ?? false);

    var loaderShown = false;
    try {
      _controller.isViewerJoiningStream = true;
      // Prevent cleanup while we attempt to rejoin in-place.
      _controller.preventDispose = true;

      if (showProgress && !(Get.isDialogOpen ?? false)) {
        // Use the existing blocking loader to keep UX consistent.
        // Only close it if we opened it, so we don't close other dialogs.
        IsmLiveUtility.showLoader();
        loaderShown = true;
      }

      Future<bool> _attemptRejoinWithToken({
        required String token,
        required DateTime? startTime,
        required String source,
      }) async {
        await _connectRoomAndInitialize(
          stream: details,
          token: token,
          streamId: streamId,
          streamImage: details?.streamImage,
          streamDiscription: details?.streamDescription ??
              _controller.descriptionController.text,
          hdBroadcast: details?.hdBroadcast ?? _controller.isHdBroadcast,
          restream: details?.restream ?? _controller.isRestreamBroadcast,
          isHost: false,
          isCopublisher: false,
          isPk: reconnectAsPk,
          isPkGust: reconnectAsPkGuest,
          isNewStream: false,
          joinByScrolling: false,
          isScrolling: false,
          isInteractive: false,
          startTime: startTime,
          context: context,
          eventId: details?.eventId,
          reJoin: true,
          isScheduledStream: details?.isScheduledStream,
          products: details?.products,
          performNavigation: false,
          showLoader: false,
        );

        // Give LiveKit a brief moment to update connection state.
        await Future.delayed(const Duration(milliseconds: 150));
        final connected =
            _controller.room?.connectionState == lk.ConnectionState.connected;
        IsmLiveLog.info(
            'rejoinCurrentViewerStreamAfterForeground: source=$source connected=$connected state=${_controller.room?.connectionState} is_pk_guest=$reconnectAsPkGuest');
        if (connected && reconnectAsPkGuest) {
          _controller.acknowledgeForegroundPublisherRejoinRestoredCamera();
        }
        return connected;
      }

      // Prefer the token from the original join (PK accept uses publishPk â†’
      // connectStream, which persists via rtcToken, storeToken, and secure storage).
      var storedToken = (_controller.rtcToken ?? '').trim();
      if (storedToken.isEmpty) {
        storedToken = (_controller.storedToken ?? '').trim();
      }
      if (storedToken.isEmpty) {
        storedToken = (await _dbWrapper.getSecuredValue(streamId)).trim();
      }
      if (storedToken.isNotEmpty) {
        final tokenKind =
            reconnectAsPkGuest ? 'stored PK publish' : 'stored RTC';
        IsmLiveLog.info(
            'rejoinCurrentViewerStreamAfterForeground: attempting with $tokenKind token for $streamId');
        try {
          final connected = await _attemptRejoinWithToken(
            token: storedToken,
            startTime: details?.startDateTime,
            source: reconnectAsPkGuest
                ? 'stored_pk_publish_token'
                : 'stored_token',
          );
          if (connected) return true;
        } catch (e, st) {
          IsmLiveLog.error(
              'rejoinCurrentViewerStreamAfterForeground: stored token rejoin failed, falling back: $e',
              st);
        }
      } else {
        IsmLiveLog.info(
            'rejoinCurrentViewerStreamAfterForeground: no stored token for $streamId');
      }

      var startTime = details?.startDateTime;
      String? freshToken;

      if (reconnectAsPkGuest) {
        // PK guest must use a publish token â€” never downgrade to viewer getRTCToken.
        if (Get.isRegistered<IsmLivePkController>()) {
          IsmLiveLog.info(
              'rejoinCurrentViewerStreamAfterForeground: PK guest â€” stored token missing or failed, fetching new publish PK token for $streamId');
          freshToken = await Get.find<IsmLivePkController>()
              .fetchPublishPkRtcToken(streamId: streamId);
        }
        if (freshToken == null || freshToken.trim().isEmpty) {
          IsmLiveLog.error(
              'rejoinCurrentViewerStreamAfterForeground: PK guest publish token fetch failed');
          return false;
        }
      } else {
        final rtc = await _controller.getRTCToken(streamId);
        if (rtc == null || rtc.rtcToken.trim().isEmpty) {
          IsmLiveLog.error(
              'rejoinCurrentViewerStreamAfterForeground: RTC token fetch failed');
          return false;
        }
        freshToken = rtc.rtcToken;
        startTime = rtc.startTime ?? startTime;
      }

      // Keep token available for background lifecycle reconnection.
      _controller.rtcToken = freshToken;
      _controller.storeToken(freshToken);

      final connected = await _attemptRejoinWithToken(
        token: freshToken,
        startTime: startTime,
        source: reconnectAsPkGuest ? 'fresh_pk_publish_token' : 'fresh_token',
      );
      return connected;
    } catch (e, st) {
      IsmLiveLog.error(
          'rejoinCurrentViewerStreamAfterForeground: unexpected error: $e', st);
      return false;
    } finally {
      if (loaderShown) {
        IsmLiveUtility.closeLoader();
      }
      _controller.isViewerJoiningStream = false;
      _controller.preventDispose = false;
    }
  }

  /// Co-publisher "Stop stream" (stop publishing only): leave the member role on
  /// the backend, then reconnect to LiveKit as a viewer with a fresh RTC token.
  Future<void> leaveCopublisherAndRejoinAsViewer({
    required String streamId,
    required BuildContext context,
  }) async {
    if (!_controller.isCopublisher || _controller.isHost) {
      return;
    }

    final usedCustomDisconnect =
        IsmLiveDelegate.streamDisconnectApiHandler != null;
    var leftServerOk = false;

    if (usedCustomDisconnect) {
      leftServerOk = await IsmLiveDelegate.streamDisconnectApiHandler!(
        streamId,
        IsmLiveStreamDisconnectType.copublisher,
      );
    } else {
      leftServerOk = await _controller.leaveMember(streamId: streamId);
    }

    if (!leftServerOk) {
      return;
    }

    // Custom disconnect bypasses [leaveMember]; mirror its local role/UI updates.
    if (usedCustomDisconnect) {
      _controller.streamMembersList.removeWhere(
        (e) => e.userId == _controller.user?.userId,
      );
      try {
        await _controller.room?.localParticipant?.unpublishAllTracks();
      } catch (_) {}
      try {
        _controller.userRole?.leaveCopublishing();
        _controller.memberStatus = IsmLiveMemberStatus.notMember;
      } catch (_) {}
      try {
        await _controller.sortParticipants();
      } catch (_) {}
      _controller.update([IsmLiveMembersSheet.updateId]);
    }

    var loaderShown = false;
    try {
      _controller.isViewerJoiningStream = true;
      _controller.preventDispose = true;

      if (!(Get.isDialogOpen ?? false)) {
        IsmLiveUtility.showLoader();
        loaderShown = true;
      }

      final rtc = await _controller.getRTCToken(streamId);
      if (rtc == null || rtc.rtcToken.trim().isEmpty) {
        IsmLiveLog.error(
            'leaveCopublisherAndRejoinAsViewer: RTC token fetch failed');
        return;
      }

      final token = rtc.rtcToken;
      _controller.rtcToken = token;
      _controller.storeToken(token);

      final details = _controller.streamDetails;
      await _connectRoomAndInitialize(
        stream: details,
        token: token,
        streamId: streamId,
        streamImage: details?.streamImage,
        streamDiscription: details?.streamDescription ??
            _controller.descriptionController.text,
        hdBroadcast: details?.hdBroadcast ?? _controller.isHdBroadcast,
        restream: details?.restream ?? _controller.isRestreamBroadcast,
        isHost: false,
        isCopublisher: false,
        isPk: details?.isPkChallenge ?? false,
        isPkGust: false,
        isNewStream: false,
        joinByScrolling: false,
        isScrolling: false,
        isInteractive: false,
        startTime: rtc.startTime ?? details?.startDateTime,
        context: context,
        eventId: details?.eventId,
        reJoin: true,
        isScheduledStream: details?.isScheduledStream,
        products: details?.products,
        performNavigation: false,
        showLoader: false,
      );
    } catch (e, st) {
      IsmLiveLog.error(
          'leaveCopublisherAndRejoinAsViewer: unexpected error: $e', st);
    } finally {
      if (loaderShown) {
        IsmLiveUtility.closeLoader();
      }
      _controller.isViewerJoiningStream = false;
      _controller.preventDispose = false;
    }
  }

  /// Host removed this device user from co-publishers (MQTT `memberRemoved`).
  /// The backend already cleared the member role; mirror successful `leaveMember` local
  /// cleanup then reconnect as a viewer (same RTC path as `leaveCopublisherAndRejoinAsViewer`).
  ///
  /// Returns whether LiveKit reports connected after reconnect. On `false`, callers
  /// may fall back to leaving the stream UI (e.g. disconnect room + pop).
  Future<bool> rejoinAsViewerAfterHostRemovedCopublisher({
    required String streamId,
  }) async {
    if (_controller.isHost || !_controller.isCopublisher) {
      return false;
    }

    final context = IsmLiveUtility.navigatorKey.currentContext;
    if (context == null) {
      IsmLiveLog.error(
          'rejoinAsViewerAfterHostRemovedCopublisher: navigator context is null');
      return false;
    }

    try {
      await _controller.room?.localParticipant?.unpublishAllTracks();
    } catch (_) {}
    try {
      _controller.userRole?.leaveCopublishing();
      _controller.memberStatus = IsmLiveMemberStatus.notMember;
    } catch (_) {}
    try {
      await _controller.sortParticipants();
    } catch (_) {}
    _controller.update([IsmLiveMembersSheet.updateId]);

    var loaderShown = false;
    try {
      _controller.isViewerJoiningStream = true;
      _controller.preventDispose = true;

      if (!(Get.isDialogOpen ?? false)) {
        IsmLiveUtility.showLoader();
        loaderShown = true;
      }

      final rtc = await _controller.getRTCToken(streamId);
      if (rtc == null || rtc.rtcToken.trim().isEmpty) {
        IsmLiveLog.error(
            'rejoinAsViewerAfterHostRemovedCopublisher: RTC token fetch failed');
        return false;
      }

      final token = rtc.rtcToken;
      _controller.rtcToken = token;
      _controller.storeToken(token);

      final details = _controller.streamDetails;
      await _connectRoomAndInitialize(
        stream: details,
        token: token,
        streamId: streamId,
        streamImage: details?.streamImage,
        streamDiscription: details?.streamDescription ??
            _controller.descriptionController.text,
        hdBroadcast: details?.hdBroadcast ?? _controller.isHdBroadcast,
        restream: details?.restream ?? _controller.isRestreamBroadcast,
        isHost: false,
        isCopublisher: false,
        isPk: details?.isPkChallenge ?? false,
        isPkGust: false,
        isNewStream: false,
        joinByScrolling: false,
        isScrolling: false,
        isInteractive: false,
        startTime: rtc.startTime ?? details?.startDateTime,
        context: context,
        eventId: details?.eventId,
        reJoin: true,
        isScheduledStream: details?.isScheduledStream,
        products: details?.products,
        performNavigation: false,
        showLoader: false,
      );

      await Future.delayed(const Duration(milliseconds: 150));
      final connected =
          _controller.room?.connectionState == lk.ConnectionState.connected;
      IsmLiveLog.info(
          'rejoinAsViewerAfterHostRemovedCopublisher: connected=$connected state=${_controller.room?.connectionState}');
      return connected;
    } catch (e, st) {
      IsmLiveLog.error(
          'rejoinAsViewerAfterHostRemovedCopublisher: unexpected error: $e',
          st);
      return false;
    } finally {
      if (loaderShown) {
        IsmLiveUtility.closeLoader();
      }
      _controller.isViewerJoiningStream = false;
      _controller.preventDispose = false;
    }
  }

  /// Copublisher: rejoin the currently open stream after app resumes.
  ///
  /// Reuses the stored RTC token (saved via `storeToken` when the copublisher
  /// originally connected). The server still considers the member as publishing,
  /// so `/switchprofile` returns "member already publishing" and `/viewer`
  /// returns a viewer-level token without publish rights.
  Future<bool> rejoinCurrentCopublisherStreamAfterForeground() async {
    final context = IsmLiveUtility.navigatorKey.currentContext;
    if (context == null) {
      IsmLiveLog.error(
          'rejoinCurrentCopublisherStreamAfterForeground: navigator context is null');
      return false;
    }

    final streamId = _controller.streamId;
    if (streamId == null || streamId.isEmpty) {
      IsmLiveLog.error(
          'rejoinCurrentCopublisherStreamAfterForeground: streamId missing');
      return false;
    }

    final details = _controller.streamDetails;
    IsmLiveLog.info(
        'rejoinCurrentCopublisherStreamAfterForeground: using stored token for $streamId');

    try {
      _controller.preventDispose = true;

      final token = _controller.storedToken;
      if (token == null || token.trim().isEmpty) {
        IsmLiveLog.error(
            'rejoinCurrentCopublisherStreamAfterForeground: stored copublisher token missing');
        return false;
      }

      _controller.rtcToken = token;

      await _connectRoomAndInitialize(
        stream: details,
        token: token,
        streamId: streamId,
        streamImage: details?.streamImage,
        streamDiscription: details?.streamDescription ??
            _controller.descriptionController.text,
        hdBroadcast: details?.hdBroadcast ?? _controller.isHdBroadcast,
        restream: details?.restream ?? _controller.isRestreamBroadcast,
        isHost: false,
        isCopublisher: true,
        isPk: details?.isPkChallenge ?? false,
        isPkGust: false,
        isNewStream: false,
        joinByScrolling: false,
        isScrolling: false,
        isInteractive: false,
        startTime: details?.startDateTime,
        context: context,
        eventId: details?.eventId,
        reJoin: true,
        isScheduledStream: details?.isScheduledStream,
        products: details?.products,
        performNavigation: false,
        showLoader: false,
      );

      await Future.delayed(const Duration(milliseconds: 150));
      final connected =
          _controller.room?.connectionState == lk.ConnectionState.connected;
      IsmLiveLog.info(
          'rejoinCurrentCopublisherStreamAfterForeground: connected=$connected state=${_controller.room?.connectionState}');
      if (connected) {
        _controller.acknowledgeForegroundPublisherRejoinRestoredCamera();
      }
      return connected;
    } catch (e, st) {
      IsmLiveLog.error(
          'rejoinCurrentCopublisherStreamAfterForeground: unexpected error: $e',
          st);
      return false;
    } finally {
      _controller.preventDispose = false;
    }
  }

  /// Host-only: rejoin the currently open stream after app resumes.
  ///
  /// Implementation notes:
  /// - Hosts don't have an API "get fresh token" flow in this SDK, so we reuse
  ///   the host RTC token stored in secure storage (keyed by streamId).
  /// - We rebuild the LiveKit `Room` using `_connectRoomAndInitialize()` to avoid
  ///   reconnecting on a potentially stale/disposed Room instance.
  Future<bool> rejoinCurrentHostStreamAfterForeground() async {
    final context = IsmLiveUtility.navigatorKey.currentContext;
    if (context == null) {
      IsmLiveLog.error(
          'rejoinCurrentHostStreamAfterForeground: navigator context is null');
      return false;
    }

    final streamId = _controller.streamId;
    if (streamId == null || streamId.isEmpty) {
      IsmLiveLog.error(
          'rejoinCurrentHostStreamAfterForeground: streamId missing');
      return false;
    }

    final details = _controller.streamDetails;
    IsmLiveLog.info(
        'rejoinCurrentHostStreamAfterForeground: loading stored RTC token for $streamId');

    try {
      // Prevent cleanup while we attempt to rejoin in-place.
      _controller.preventDispose = true;

      final token = await _dbWrapper.getSecuredValue(streamId);
      if (token.trim().isEmpty) {
        IsmLiveLog.error(
            'rejoinCurrentHostStreamAfterForeground: stored host token missing');
        return false;
      }

      // Keep token available for background lifecycle reconnection.
      _controller.rtcToken = token;
      _controller.storeToken(token);

      await _connectRoomAndInitialize(
        stream: details,
        token: token,
        streamId: streamId,
        streamImage: details?.streamImage,
        streamDiscription: details?.streamDescription ??
            _controller.descriptionController.text,
        hdBroadcast: details?.hdBroadcast ?? _controller.isHdBroadcast,
        restream: details?.restream ?? _controller.isRestreamBroadcast,
        isHost: true,
        isCopublisher: false,
        isPk: details?.isPkChallenge ?? false,
        isPkGust: false,
        isNewStream: false,
        joinByScrolling: false,
        isScrolling: false,
        isInteractive: false,
        startTime: details?.startDateTime,
        context: context,
        eventId: details?.eventId,
        reJoin: true,
        isScheduledStream: details?.isScheduledStream,
        products: details?.products,
        performNavigation: false,
        showLoader: false,
      );

      // Give LiveKit a brief moment to update connection state.
      await Future.delayed(const Duration(milliseconds: 150));
      final connected =
          _controller.room?.connectionState == lk.ConnectionState.connected;
      IsmLiveLog.info(
          'rejoinCurrentHostStreamAfterForeground: connected=$connected state=${_controller.room?.connectionState}');
      if (connected) {
        // `_connectRoomAndInitialize` already ran `enableMyVideo()` â€” avoid a second
        // foreground resume pass that calls `setCameraEnabled` again (races/errors).
        _controller.acknowledgeForegroundPublisherRejoinRestoredCamera();
      }
      return connected;
    } catch (e, st) {
      IsmLiveLog.error(
          'rejoinCurrentHostStreamAfterForeground: unexpected error: $e', st);
      return false;
    } finally {
      _controller.preventDispose = false;
    }
  }
}