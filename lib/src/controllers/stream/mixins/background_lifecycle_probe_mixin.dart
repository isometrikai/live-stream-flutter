import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

enum _IsmStreamLiveGateResult { live, notLive, unknown }

mixin StreamBackgroundLifecycleMixin on GetxController {
  // Background state management
  final RxBool _isInBackground = false.obs;
  final RxBool _isStreamActive = false.obs;
  final RxBool _isHost = false.obs;

  // Connection details for reconnection
  String? _lastStreamId;
  String? _storedToken; // Store RTC token locally for both hosts and viewers
  bool _isReconnecting =
      false; // Prevent multiple simultaneous reconnection attempts

  // Configuration
  bool _enableBackgroundLifecycle = true;
  bool _enableBackgroundAudio = true;
  bool _enableBackgroundVideo = false;

  // Timers for background handling
  Timer? _reconnectTimer;
  bool _videoPausedByBackground = false;

  // Preserve user's last camera/audio state so foreground resume (especially
  // the rejoin path where enableMyVideo() unconditionally publishes both tracks)
  // can restore the state the user actually chose.
  bool _userVideoOnBeforeBackground = true;
  bool _userAudioOnBeforeBackground = true;
  bool _mediaStateSavedForBackground = false;

  // Camera error tracking
  int _cameraErrorCount = 0;
  static const int _maxCameraErrors = 3;
  int _streamViewSessionId = 0;
  bool _hasShownInfoDialogInSession = false;
  bool _blockAutoReconnectAfterLifecycleDialog = false;

  /// Target: probe + reconnect + checks complete within ~4s or we show the info dialog.
  static const Duration _foregroundProbeTimeout = Duration(milliseconds: 15000);
  static const Duration _preResumeConnectedVerifyDelay =
      Duration(milliseconds: 100);
  static const Duration _afterConnectStabilizeDelay =
      Duration(milliseconds: 180);
  static const Duration _postResumeRoomStabilityDelay =
      Duration(milliseconds: 320);
  static const Duration _roomConnectTimeout = Duration(milliseconds: 2500);

  // Getters
  bool get isInBackground => _isInBackground.value;
  bool get isStreamActive => _isStreamActive.value;
  bool get isHost => _isHost.value;
  String? get storedToken => _storedToken;

  // Get the controller instance
  IsmLiveStreamController get _controller => this as IsmLiveStreamController;

  // Configure background lifecycle settings
  void configureBackgroundLifecycle({
    bool enableBackgroundLifecycle = true,
    bool enableBackgroundAudio = true,
    bool enableBackgroundVideo = false,
    Duration? backgroundTimeout,
  }) {
    _enableBackgroundLifecycle = enableBackgroundLifecycle;
    _enableBackgroundAudio = enableBackgroundAudio;
    _enableBackgroundVideo = enableBackgroundVideo;
    // backgroundTimeout is intentionally ignored: backend enforces viewer timeout.
  }

  // Initialize background lifecycle management
  void initializeBackgroundLifecycle() {
    IsmLiveLog.info(
        'Initializing background lifecycle - enabled: $_enableBackgroundLifecycle');
    if (!_enableBackgroundLifecycle) {
      IsmLiveLog.info('Background lifecycle disabled, not initializing');
      return;
    }

    WidgetsBinding.instance.addObserver(_controller);
    IsmLiveLog.info(
        'Background lifecycle management initialized - observer added');
  }

  // Dispose background lifecycle management
  void disposeBackgroundLifecycle() {
    WidgetsBinding.instance.removeObserver(_controller);
    _reconnectTimer?.cancel();
    IsmLiveLog.info('Background lifecycle management disposed');
  }

  // Set stream active state
  void setStreamActive(bool active, bool isHost) {
    _isStreamActive.value = active;
    _isHost.value = isHost;
    IsmLiveLog.info('Stream active: $active, isHost: $isHost');

    // Initialize background lifecycle when stream becomes active
    if (active) {
      _streamViewSessionId++;
      _hasShownInfoDialogInSession = false;
      _blockAutoReconnectAfterLifecycleDialog = false;
      IsmLiveLog.info('Started stream view session: $_streamViewSessionId');
      IsmLiveLog.info('Stream is active, initializing background lifecycle');
      _storeConnectionDetails();
      initializeBackgroundLifecycle();
    } else {
      _streamViewSessionId++;
      _hasShownInfoDialogInSession = false;
      _blockAutoReconnectAfterLifecycleDialog = false;

      // Reset all reconnection-related state so nothing from this session
      // leaks into a future stream (e.g. stuck _isReconnecting flag, stale
      // token that could be used by _attemptSingleReconnection, or pending
      // camera-resume retries).
      _isReconnecting = false;
      _storedToken = null;
      _lastStreamId = null;
      _videoPausedByBackground = false;
      _userVideoOnBeforeBackground = true;
      _userAudioOnBeforeBackground = true;
      _mediaStateSavedForBackground = false;
      _cameraErrorCount = 0;
      _reconnectTimer?.cancel();

      IsmLiveLog.info('Invalidated stream view session: $_streamViewSessionId');
      IsmLiveLog.info('Stream is inactive, disposing background lifecycle');
      disposeBackgroundLifecycle();
    }
  }

  void _storeConnectionDetails() {
    try {
      // Store the current stream ID
      _lastStreamId = _controller.streamId;

      IsmLiveLog.info(
          'Stored connection details - streamId: $_lastStreamId, isHost: ${_isHost.value}');
    } catch (e) {
      IsmLiveLog.error('Error storing connection details: $e');
    }
  }

  /// Method to store the RTC token (called from join_mixin when connecting)
  void storeToken(String token) {
    try {
      _storedToken = token;
      IsmLiveLog.info('Stored token locally (length: ${token.length})');
    } catch (e) {
      IsmLiveLog.error('Error storing token: $e');
    }
  }

  /// After host `rejoinCurrentHostStreamAfterForeground`, `_connectRoomAndInitialize`
  /// already publishes camera via `enableMyVideo()`. Clear this flag so
  /// [_resumeStream] does not run host camera resume again
  /// (duplicate `setCameraEnabled` can error and make video look disabled).
  void acknowledgeForegroundHostRejoinRestoredCamera() {
    if (!_isStreamActive.value || !_isHost.value) return;
    _videoPausedByBackground = false;
  }

  void handleBackgroundLifecycleState(AppLifecycleState state) {
    IsmLiveLog.info('Background lifecycle state received: $state');

    // Chat fallback polling control should be lifecycle-driven even when
    // background lifecycle features are disabled, so API polling doesn't run
    // in background and also resumes correctly in foreground.
    switch (state) {
      case AppLifecycleState.resumed:
        if (_isStreamActive.value) {
          _controller.resumeMqttDisconnectedChatFallbackIfNeeded();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        _controller.pauseMqttDisconnectedChatFallback();
        break;
      case AppLifecycleState.detached:
        break;
    }

    // `inactive` can be emitted when the app is transitioning to background or
    // when system UI overlays appear. We avoid doing heavy background handling
    // here, but we still mark the controller as "not active" so background-only
    // guards (e.g., MQTT fallback polling) do not run.
    if (state == AppLifecycleState.inactive) {
      IsmLiveLog.info('Marking inactive as background-like (lightweight)');
      _isInBackground.value = true;
      return;
    }

    if (!_enableBackgroundLifecycle) {
      IsmLiveLog.info('Background lifecycle disabled, skipping state: $state');
      return;
    }

    if (!_isStreamActive.value) {
      IsmLiveLog.info('Stream not active, skipping state: $state');
      return;
    }

    IsmLiveLog.info('Processing lifecycle state: $state');

    try {
      switch (state) {
        case AppLifecycleState.resumed:
          _handleAppResumed();
          break;
        case AppLifecycleState.paused:
          _handleAppPaused();
          break;
        case AppLifecycleState.detached:
          _handleAppDetached();
          break;
        case AppLifecycleState.hidden:
          _handleAppHidden();
          break;
        default:
          // Handle any other states (including inactive which we ignore)
          break;
      }
    } catch (e) {
      IsmLiveLog.error('Error in background lifecycle state handling: $e');
    }
  }

  void _handleAppResumed() {
    IsmLiveLog.info('App resumed from background');
    _isInBackground.value = false;
    _mediaStateSavedForBackground = false;
    _reconnectTimer?.cancel();

    if (_blockAutoReconnectAfterLifecycleDialog) {
      IsmLiveLog.info(
          'Auto reconnect is blocked after lifecycle info dialog; skipping foreground resume flow');
      return;
    }

    if (_isStreamActive.value) {
      // Resume MQTT fallback polling if it was paused in background.
      _controller.resumeMqttDisconnectedChatFallbackIfNeeded();
      unawaited(_runForegroundResumeFlow());
    }
  }

  /// After background: verify stream live status via API first.
  /// If backend confirms `success=true` and `isLive=true`, proceed to room checks/reconnect.
  /// If backend confirms not live, do not attempt reconnect; show reconnect info dialog.
  Future<void> _runForegroundResumeFlow() async {
    final sessionId = _streamViewSessionId;
    final expectedStreamId = _controller.streamId;

    IsmLiveLog.info(
        'Foreground resume: checking stream live status via API...');

    if (!_isStreamActive.value) {
      IsmLiveLog.info('Stream not active, aborting foreground resume');
      return;
    }

    if (expectedStreamId == null || expectedStreamId.isEmpty) {
      IsmLiveLog.info('streamId missing, aborting foreground resume');
      return;
    }

    if (_isReconnecting) {
      IsmLiveLog.info(
          'Reconnection already in progress, skipping foreground resume');
      return;
    }

    if (_blockAutoReconnectAfterLifecycleDialog) {
      IsmLiveLog.info(
          'Auto reconnect is blocked after lifecycle info dialog; aborting live-status gate');
      return;
    }

    final liveGate = await _checkStreamLiveStatusGate(expectedStreamId).timeout(
      _foregroundProbeTimeout,
      onTimeout: () {
        IsmLiveLog.info(
            'Foreground live-status gate timed out ($_foregroundProbeTimeout)');
        return _IsmStreamLiveGateResult.unknown;
      },
    );

    if (!_isStreamActive.value ||
        !_isSessionValid(sessionId) ||
        !_isExpectedStream(expectedStreamId)) {
      IsmLiveLog.info(
          'Stream/session changed during live-status gate, aborting');
      return;
    }

    if (liveGate != _IsmStreamLiveGateResult.live) {
      IsmLiveLog.info(liveGate == _IsmStreamLiveGateResult.notLive
          ? 'Foreground live-status gate: stream is not live — skipping reconnect and showing info dialog'
          : 'Foreground live-status gate: unknown (API error) — skipping reconnect and showing info dialog');
      await _disconnectLiveKitRoomForLifecycleInfoDialog();
      _showConnectionFailedDialog(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      );
      return;
    }

    IsmLiveLog.info(
        'Foreground live-status gate: confirmed live — checking room and resuming');

    _checkRoomStateAndResumeAfterProbe(
      sessionId: sessionId,
      expectedStreamId: expectedStreamId,
    );
  }

  Future<_IsmStreamLiveGateResult> _checkStreamLiveStatusGate(
      String? streamId) async {
    if (streamId == null || streamId.isEmpty) {
      return _IsmStreamLiveGateResult.unknown;
    }

    const maxAttempts = 4;
    const retryDelay = Duration(seconds: 3);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final verified =
            await _controller.isStreamLiveVerified(streamId: streamId);

        if (verified != null) {
          return verified
              ? _IsmStreamLiveGateResult.live
              : _IsmStreamLiveGateResult.notLive;
        }

        // null means the request failed (e.g. no internet) — retry
        IsmLiveLog.info(
            'Foreground live-status gate: attempt $attempt/$maxAttempts returned null, '
            '${attempt < maxAttempts ? "retrying in ${retryDelay.inSeconds}s..." : "no more retries"}');
      } catch (e, st) {
        IsmLiveLog.error(
            'Foreground live-status gate error (attempt $attempt/$maxAttempts): $e',
            st);
      }

      if (attempt < maxAttempts) {
        await Future.delayed(retryDelay);
      }
    }

    return _IsmStreamLiveGateResult.unknown;
  }

  void _handleAppPaused() {
    IsmLiveLog.info('App paused - going to background');
    _isInBackground.value = true;
    // Stop chat polling immediately while backgrounded.
    _controller.pauseMqttDisconnectedChatFallback();

    if (_isStreamActive.value) {
      _handleStreamBackground();
    }
  }

  void _handleAppDetached() {
    IsmLiveLog.info('App detached - cleaning up');
    _cleanupStream();
  }

  void _handleAppHidden() {
    IsmLiveLog.info('App hidden');
    _isInBackground.value = true;
    // Stop chat polling immediately while backgrounded.
    _controller.pauseMqttDisconnectedChatFallback();
    _handleAppPaused();
  }

  void _handleStreamBackground() {
    if (!_isStreamActive.value) return;

    // Guard: _handleAppHidden calls _handleAppPaused, so this method can fire
    // twice (hidden → paused). Only capture on the first call — after
    // _pauseVideoForBackground sets videoOn = false, a second save would
    // record the wrong (already-paused) state.
    if (!_mediaStateSavedForBackground) {
      _userVideoOnBeforeBackground = _controller.videoOn;
      _userAudioOnBeforeBackground = _controller.audioOn;
      _mediaStateSavedForBackground = true;
      IsmLiveLog.info(
          'Saved user media state before background — video: $_userVideoOnBeforeBackground, audio: $_userAudioOnBeforeBackground');
    }

    if (_isHost.value) {
      _handleHostBackground();
    } else {
      _handleViewerBackground();
    }
  }

  void _handleHostBackground() {
    IsmLiveLog.info('Host going to background');

    // Pause video immediately if not enabled for background
    if (!_enableBackgroundVideo) {
      unawaited(_pauseVideoForBackground());
    }

    // Host audio continues indefinitely in background
    // Background notification removed as per requirement
  }

  void _handleViewerBackground() {
    IsmLiveLog.info('Viewer going to background');

    // Pause video immediately if not enabled for background
    if (!_enableBackgroundVideo) {
      unawaited(_pauseVideoForBackground());
    }

    // Enable background audio if configured
    if (_enableBackgroundAudio) {
      _enableBackgroundAudioPlayback();
    }
  }

  Future<void> _pauseVideoForBackground() async {
    if (_videoPausedByBackground) return;

    try {
      // Only pause video if user is a host (has local video track)
      if (_isHost.value) {
        // Check if video was already manually paused by user
        if (!_controller.videoOn) {
          IsmLiveLog.info(
              'Video was already manually paused before going to background, not setting background pause flag');
          return; // Don't set _videoPausedByBackground flag, so video won't auto-resume
        }

        // Video was enabled: unpublish camera so LiveKit full-reconnect won't
        // call rePublishAllTracks on a muted track whose native track is null.
        IsmLiveLog.info(
            'Pausing host video for background via camera unpublish (safe for long reconnects)');
        _videoPausedByBackground = true;
        _controller.videoOn = false;
        await _controller.unpublishLocalCameraTrackOnly();
        _controller.update();
      } else {
        IsmLiveLog.info('Viewer going to background - no local video to pause');
      }
    } catch (e) {
      IsmLiveLog.error('Error pausing video for background: $e');

      // Reset flag on error
      _videoPausedByBackground = false;

      // If it's a camera error, increment error count
      if (e.toString().contains('CAMERA_ERROR') ||
          e.toString().contains('camera')) {
        _cameraErrorCount++;
        IsmLiveLog.error(
            'Camera error detected during background pause (count: $_cameraErrorCount)');

        if (_cameraErrorCount >= _maxCameraErrors) {
          IsmLiveLog.error(
              'Too many camera errors, disabling background lifecycle');
          _enableBackgroundLifecycle = false;
          WidgetsBinding.instance.removeObserver(_controller);
          return;
        }
      }
    }
  }

  void _enableBackgroundAudioPlayback() {
    // Respect viewer mute: forcing speaker on would desync UI/audio from what
    // the user chose before background (same idea as video in _pauseVideoForBackground).
    if (!_controller.speakerOn) {
      IsmLiveLog.info(
          'Viewer has stream audio muted — skipping background speaker enable');
      return;
    }
    _controller.toggleSpeaker(value: true);
  }

  void _resumeStream() {
    IsmLiveLog.info('Resuming existing stream connection');

    // Reset reconnection flag and cancel any ongoing reconnection timer
    _isReconnecting = false;
    _reconnectTimer?.cancel();

    // Add small delay to prevent rapid UI state changes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isStreamActive.value) {
        IsmLiveLog.info('Stream became inactive during resume delay, aborting');
        return;
      }
      if (_isHost.value && _videoPausedByBackground) {
        IsmLiveLog.info('Host video was paused by background, resuming camera');
        _resumeCameraWithRetry();
        _restoreUserAudioStateAfterResume();
      } else if (_isHost.value) {
        IsmLiveLog.info(
            'Host resumed from background - restoring user media state');
        _restoreUserMediaStateAfterRejoin();
      } else {
        IsmLiveLog.info('Viewer resumed from background');
      }

      _notifyHostBack();
      // Background notification hiding removed as per requirement
    });
  }

  /// After a rejoin, [enableMyVideo] unconditionally publishes camera + mic and
  /// sets [videoOn]/[audioOn] to true. This method reverts those flags and the
  /// underlying tracks back to whatever the user chose before backgrounding.
  void _restoreUserMediaStateAfterRejoin() {
    if (!_isHost.value) return;

    if (!_userVideoOnBeforeBackground && _controller.videoOn) {
      IsmLiveLog.info(
          'Restoring user video state: was OFF before background, disabling camera');
      _controller.toggleVideo(value: false);
    }

    _restoreUserAudioStateAfterResume();
  }

  /// Shared audio-state restore used by both the rejoin and non-rejoin resume
  /// paths. After a rejoin [enableMyVideo] + [toggleAudio(value:true)] always
  /// turn the mic on; this reverts that if the user had it muted.
  void _restoreUserAudioStateAfterResume() {
    if (!_isHost.value) return;

    if (!_userAudioOnBeforeBackground && _controller.audioOn) {
      IsmLiveLog.info(
          'Restoring user audio state: was OFF before background, muting mic');
      _controller.toggleAudio(value: false);
    }
  }

  void _resumeCameraWithRetry() {
    const maxAttempts = 3;
    var attempts = 0;

    Future<void> attemptResume() async {
      if (!_isStreamActive.value) {
        IsmLiveLog.info(
            'Stream no longer active, aborting camera resume retry');
        return;
      }
      attempts++;
      IsmLiveLog.info(
          'Attempting to resume camera (attempt $attempts/$maxAttempts)');

      try {
        // Only resume camera if user is a host (has local video track)
        if (_isHost.value) {
          IsmLiveLog.info(
              'Resuming host camera via setCameraEnabled (fresh publish after unpublish)');
          await _controller.resumeHostCameraAfterBackground();
          _videoPausedByBackground = false;
          _cameraErrorCount = 0; // Reset error count on success
          IsmLiveLog.info('Host camera resumed successfully');
        } else {
          IsmLiveLog.info(
              'Viewer resumed from background - no camera to resume');
          _videoPausedByBackground = false;
        }
      } catch (e) {
        IsmLiveLog.error('Error resuming camera (attempt $attempts): $e');

        // Handle camera errors
        if (e.toString().contains('CAMERA_ERROR') ||
            e.toString().contains('camera')) {
          _cameraErrorCount++;
          IsmLiveLog.error(
              'Camera error during resume (count: $_cameraErrorCount)');

          if (_cameraErrorCount >= _maxCameraErrors) {
            IsmLiveLog.error(
                'Too many camera errors, disabling background lifecycle');
            _enableBackgroundLifecycle = false;
            WidgetsBinding.instance.removeObserver(_controller);
            return;
          }
        }

        // Retry with exponential backoff
        if (attempts < maxAttempts) {
          final delay = Duration(milliseconds: 500 * attempts);
          IsmLiveLog.info(
              'Retrying camera resume in ${delay.inMilliseconds}ms');
          Future.delayed(delay, attemptResume);
        } else {
          IsmLiveLog.error(
              'Failed to resume camera after $maxAttempts attempts');
          _videoPausedByBackground =
              false; // Reset flag to allow future attempts
        }
      }
    }

    attemptResume();
  }

  void _notifyHostBack() {
    // Notify that host is back
    IsmLiveLog.info('Host is back from background');
  }

  void _cleanupStream() {
    IsmLiveLog.info('Cleaning up stream resources');
    _reconnectTimer?.cancel();
    _videoPausedByBackground = false;
    _cameraErrorCount = 0;
  }

  // Public methods for external control
  void reEnableBackgroundLifecycle() {
    _enableBackgroundLifecycle = true;
    _cameraErrorCount = 0;
    WidgetsBinding.instance.addObserver(_controller);
    IsmLiveLog.info('Background lifecycle re-enabled');
  }

  void disableBackgroundLifecycle() {
    _enableBackgroundLifecycle = false;
    WidgetsBinding.instance.removeObserver(_controller);
    _reconnectTimer?.cancel();
    IsmLiveLog.info('Background lifecycle disabled');
  }

  /// After a successful live-status gate (or unknown fallback), align LiveKit and resume local media.
  void _checkRoomStateAndResumeAfterProbe({
    required int sessionId,
    required String? expectedStreamId,
  }) {
    IsmLiveLog.info('Checking room state after probe...');

    if (!_isStreamActive.value) {
      IsmLiveLog.info('Stream is not active, skipping room state check');
      return;
    }

    if (_isReconnecting) {
      IsmLiveLog.info('Reconnection already in progress, skipping');
      return;
    }

    if (_blockAutoReconnectAfterLifecycleDialog) {
      IsmLiveLog.info(
          'Auto reconnect is blocked after lifecycle info dialog; skipping room state check');
      return;
    }

    final room = _controller.room;
    final connectionState = room?.connectionState;
    IsmLiveLog.info('Room connection state: $connectionState');

    if (room != null && connectionState == lk.ConnectionState.connected) {
      IsmLiveLog.info(
          'Room reports connected — verifying then resuming (or reconnecting)');
      unawaited(_verifyConnectedRoomThenResumeOrReconnect(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      ));
      return;
    } else if (room != null &&
        connectionState == lk.ConnectionState.disconnected) {
      // Live was confirmed by API; prefer a full room rebuild rejoin which is
      // the most reliable way to recover.
      IsmLiveLog.info(
          'Room is disconnected after live confirmation — forcing room rebuild rejoin');
      unawaited(_forceRejoinAfterLiveConfirmed(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      ));
      return;
    } else {
      IsmLiveLog.info(
          'Room connection state unclear/null after live confirmation — forcing room rebuild rejoin');
      unawaited(_forceRejoinAfterLiveConfirmed(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      ));
      return;
    }
  }

  /// When backend confirms the stream is live, we must reconnect reliably.
  /// Prefer the in-place rejoin flows that rebuild the room (viewer: fresh token;
  /// host: stored token). Only show the dialog if those fail.
  Future<void> _forceRejoinAfterLiveConfirmed({
    required int sessionId,
    required String? expectedStreamId,
  }) async {
    if (!_isStreamActive.value ||
        !_isSessionValid(sessionId) ||
        !_isExpectedStream(expectedStreamId)) {
      return;
    }
    if (_isReconnecting) return;
    if (_blockAutoReconnectAfterLifecycleDialog) return;

    _isReconnecting = true;
    try {
      final ok = !_isHost.value
          ? await _controller.rejoinCurrentViewerStreamAfterForeground(
              showProgress: true,
            )
          : await _controller.rejoinCurrentHostStreamAfterForeground();

      if (!_isStreamActive.value ||
          !_isSessionValid(sessionId) ||
          !_isExpectedStream(expectedStreamId)) {
        return;
      }

      if (ok) {
        IsmLiveLog.info(
            'Live-confirmed rejoin succeeded — resuming stream (post-verify)');
        _resumeStreamWithPostConnectVerify(
          sessionId: sessionId,
          expectedStreamId: expectedStreamId,
        );
        return;
      }

      IsmLiveLog.info(
          'Live-confirmed rejoin failed — attempting single reconnection fallback');
      // Hand over to the single reconnect flow which manages `_isReconnecting`.
      _isReconnecting = false;
      _attemptSingleReconnection(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      );
      return;
    } catch (e, st) {
      IsmLiveLog.error('Live-confirmed rejoin error: $e', st);
      if (_isStreamActive.value &&
          _isSessionValid(sessionId) &&
          _isExpectedStream(expectedStreamId)) {
        _showConnectionFailedDialog(
          sessionId: sessionId,
          expectedStreamId: expectedStreamId,
        );
      }
    } finally {
      _isReconnecting = false;
    }
  }

  /// LiveKit can briefly report `ConnectionState.connected` while the session is bad.
  /// After a short delay, reconnect if needed; otherwise resume and verify stability.
  Future<void> _verifyConnectedRoomThenResumeOrReconnect({
    required int sessionId,
    required String? expectedStreamId,
  }) async {
    await Future.delayed(_preResumeConnectedVerifyDelay);
    if (!_isStreamActive.value ||
        !_isSessionValid(sessionId) ||
        !_isExpectedStream(expectedStreamId)) {
      return;
    }
    if (_blockAutoReconnectAfterLifecycleDialog) return;
    final room = _controller.room;
    final state = room?.connectionState;
    if (room == null || state != lk.ConnectionState.connected) {
      IsmLiveLog.info(
          'Room not connected after verification delay — attempting reconnect');
      _attemptSingleReconnection(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      );
      return;
    }
    _resumeStreamWithPostConnectVerify(
      sessionId: sessionId,
      expectedStreamId: expectedStreamId,
    );
  }

  void _resumeStreamWithPostConnectVerify({
    required int sessionId,
    required String? expectedStreamId,
  }) {
    _resumeStream();
    unawaited(_ensureRoomStableOrShowDialog(
      sessionId: sessionId,
      expectedStreamId: expectedStreamId,
    ));
  }

  /// If the room drops shortly after resume/reconnect, show the same host/viewer dialogs.
  Future<void> _ensureRoomStableOrShowDialog({
    required int sessionId,
    required String? expectedStreamId,
  }) async {
    await Future.delayed(_postResumeRoomStabilityDelay);
    if (!_isStreamActive.value ||
        !_isSessionValid(sessionId) ||
        !_isExpectedStream(expectedStreamId)) {
      return;
    }
    if (_blockAutoReconnectAfterLifecycleDialog) return;
    final room = _controller.room;
    if (room == null || room.connectionState != lk.ConnectionState.connected) {
      IsmLiveLog.info(
          'Post-resume room check: not connected — showing status dialog');
      _showConnectionFailedDialog(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      );
    }
  }

  /// Attempt single reconnection with stored token
  void _attemptSingleReconnection({
    required int sessionId,
    required String? expectedStreamId,
  }) async {
    try {
      if (_blockAutoReconnectAfterLifecycleDialog) {
        IsmLiveLog.info(
            'Auto reconnect is blocked after lifecycle info dialog; skipping single reconnection attempt');
        return;
      }
      IsmLiveLog.info('Attempting single reconnection with stored token...');
      _isReconnecting = true;

      final room = _controller.room;
      if (room == null) {
        IsmLiveLog.error('Room is null, cannot reconnect');
        _isReconnecting = false;
        _showConnectionFailedDialog(
          sessionId: sessionId,
          expectedStreamId: expectedStreamId,
        );
        return;
      }

      // Try reconnection only once with stored token
      if (_storedToken != null) {
        IsmLiveLog.info(
            'Using stored token for single reconnection attempt...');

        try {
          // Try to reconnect (bounded wait so we always surface failure via dialog)
          await room
              .connect(IsmLiveApis.wsUrl, _storedToken!)
              .timeout(_roomConnectTimeout);

          // Check if stream is still active after connect
          if (!_isStreamActive.value ||
              !_isSessionValid(sessionId) ||
              !_isExpectedStream(expectedStreamId)) {
            IsmLiveLog.info(
                'Stream/session became invalid during reconnection, aborting');
            _isReconnecting = false;
            return;
          }

          // Brief settle before reading connection state (kept short for ~4s budget)
          await Future.delayed(_afterConnectStabilizeDelay);

          // Check again after delay
          if (!_isStreamActive.value ||
              !_isSessionValid(sessionId) ||
              !_isExpectedStream(expectedStreamId)) {
            IsmLiveLog.info(
                'Stream/session became invalid during stabilization delay, aborting');
            _isReconnecting = false;
            return;
          }

          // Check if reconnection was successful
          if (room.connectionState == lk.ConnectionState.connected) {
            IsmLiveLog.info('Single reconnection successful');
            _isReconnecting = false;
            _resumeStreamWithPostConnectVerify(
              sessionId: sessionId,
              expectedStreamId: expectedStreamId,
            );
          } else {
            IsmLiveLog.info(
                'Single reconnection failed, connection state: ${room.connectionState}');
            _isReconnecting = false;
            _showConnectionFailedDialog(
              sessionId: sessionId,
              expectedStreamId: expectedStreamId,
            );
          }
        } catch (e) {
          IsmLiveLog.error('Single reconnection attempt failed with error: $e');
          _isReconnecting = false;
          // Check if stream is still active before calling API
          if (_isStreamActive.value &&
              _isSessionValid(sessionId) &&
              _isExpectedStream(expectedStreamId)) {
            _showConnectionFailedDialog(
              sessionId: sessionId,
              expectedStreamId: expectedStreamId,
            );
          }
        }
      } else {
        IsmLiveLog.info('No stored token available, calling API immediately');
        _isReconnecting = false;
        _showConnectionFailedDialog(
          sessionId: sessionId,
          expectedStreamId: expectedStreamId,
        );
      }
    } catch (e) {
      IsmLiveLog.error('Error in single reconnection: $e');
      _isReconnecting = false;
      // Check if stream is still active before calling API
      if (_isStreamActive.value &&
          _isSessionValid(sessionId) &&
          _isExpectedStream(expectedStreamId)) {
        _showConnectionFailedDialog(
          sessionId: sessionId,
          expectedStreamId: expectedStreamId,
        );
      }
    }
  }

  void _stopStreamTimerForInfoDialog() {
    _controller.streamTimer?.cancel();
    _controller.streamTimer = null;
  }

  bool _isSessionValid(int sessionId) => sessionId == _streamViewSessionId;

  bool _isExpectedStream(String? expectedStreamId) {
    if (expectedStreamId == null || expectedStreamId.isEmpty) return false;
    return _controller.streamId == expectedStreamId;
  }

  bool _canShowInfoDialogOnCurrentScreen({
    int? sessionId,
    String? expectedStreamId,
  }) {
    if (sessionId != null && !_isSessionValid(sessionId)) {
      IsmLiveLog.info(
          'Skipping info dialog because session is stale: $sessionId != $_streamViewSessionId');
      return false;
    }

    if (expectedStreamId != null && !_isExpectedStream(expectedStreamId)) {
      IsmLiveLog.info(
          'Skipping info dialog because streamId mismatch: expected $expectedStreamId, current ${_controller.streamId}');
      return false;
    }

    if (_hasShownInfoDialogInSession) {
      IsmLiveLog.info(
          'Skipping info dialog because one is already shown in current session');
      return false;
    }

    // final currentRoute = Get.currentRoute;
    // final isOnStreamView = currentRoute == IsmLiveRoutes.streamView;
    // if (!isOnStreamView) {
    //   IsmLiveLog.info(
    //       'Skipping info dialog because current route is not stream view: $currentRoute');
    // }
    return true;
  }

  void _onlyCloseStreamLifecycleInfoDialog() {
    _hasShownInfoDialogInSession = false;

    // The room was already torn down by _disconnectLiveKitRoomForLifecycleInfoDialog
    // before this dialog was shown. This guard is a safety net in case the
    // earlier disconnect was incomplete (e.g. exception during teardown).
    final room = _controller.room;
    if (room != null) {
      unawaited(_safeForceStopAndDisconnect(room));
    }

    IsmLiveUtility.closeDialog();
  }

  void _exitStreamFromLifecycleInfoDialog() {
    final wasHost = _isHost.value;

    // Mark stream inactive BEFORE popping so disposal flows don't race with
    // lifecycle observer callbacks (which check _isStreamActive).
    _controller.setStreamActive(false, wasHost);

    // Safety net: if the earlier `_disconnectLiveKitRoomForLifecycleInfoDialog`
    // call didn't complete (e.g. exception path), force-stop remaining tracks.
    final room = _controller.room;
    if (room != null) {
      unawaited(_safeForceStopAndDisconnect(room));
    }

    IsmLiveUtility.closeDialog();

    // Pop the stream view.  The route's PopScope.onPopInvoked handler
    // triggers `cleanupStreamData → streamDispose` which resets all UI state,
    // timers, and polling.  We do NOT call streamDispose here to avoid
    // double-dispose (FocusNode, animation controller, etc.).
    IsmLiveRoute.pop();
  }

  Widget _streamLifecycleInfoDialogLayout({
    required String message,
    required TextAlign textAlign,
    required Widget gapBeforeExitButton,
  }) =>
      Material(
        color: IsmLiveColors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: _onlyCloseStreamLifecycleInfoDialog,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  icon: const Icon(
                    Icons.close,
                    size: 22,
                    color: IsmLiveColors.black,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Text(
                  message,
                  style: IsmLiveStyles.black16,
                  textAlign: textAlign,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              gapBeforeExitButton,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: IsmLiveButton(
                  onTap: _exitStreamFromLifecycleInfoDialog,
                  label: 'Exit',
                ),
              ),
            ],
          ),
        ),
      );

  /// Show dialog when connection failed but stream is still active
  Future<void> _showConnectionFailedDialog(
      {int? sessionId, String? expectedStreamId}) async {
    try {
      // Final check before showing dialog
      if (!_isStreamActive.value) {
        IsmLiveLog.info(
            'Stream is not active, skipping connection failed dialog');
        return;
      }
      if (!_canShowInfoDialogOnCurrentScreen(
          sessionId: sessionId, expectedStreamId: expectedStreamId)) {
        return;
      }

      // Close any open dialog before showing the stream ended dialog
      IsmLiveUtility.popUntilStreamView();
      _stopStreamTimerForInfoDialog();
      _hasShownInfoDialogInSession = true;
      _blockAutoReconnectAfterLifecycleDialog = true;
      // Await the disconnect so camera/mic hardware is fully released before
      // presenting the dialog. Previously this was fire-and-forget which could
      // leave native tracks active on iOS if the disconnect was slow.
      await _disconnectLiveKitRoomForLifecycleInfoDialog();

      // Re-check after async gap: stream may have become inactive while
      // awaiting disconnect (e.g. user exited via another path).
      if (!_isStreamActive.value) {
        IsmLiveLog.info(
            'Stream became inactive during lifecycle disconnect, skipping dialog');
        return;
      }

      final message = _isHost.value
          ? 'Unable to reconnect to your stream. Please try again or start a new stream'
          : 'Unable to reconnect to the stream. Please try again or browse other streams';

      IsmLiveUtility.showCustomDialog(
        _streamLifecycleInfoDialogLayout(
          message: message,
          textAlign: TextAlign.left,
          gapBeforeExitButton: IsmLiveDimens.boxHeight50,
        ),
        isDismissible: false,
      );
    } catch (e) {
      IsmLiveLog.error('Error showing connection failed dialog: $e');
    }
  }

  Future<void> _disconnectLiveKitRoomForLifecycleInfoDialog() async {
    final room = _controller.room;
    if (room == null) {
      IsmLiveLog.info(
        'Lifecycle info dialog flow: room already null, no LiveKit disconnect needed',
      );
      return;
    }

    try {
      IsmLiveLog.info(
        'Lifecycle info dialog flow: room state before teardown = ${room.connectionState}',
      );

      // Explicitly stop local media tracks BEFORE disconnecting the room.
      // On iOS, room.disconnect() alone does not guarantee the native
      // camera/microphone hardware is released. WebRTC tracks can keep
      // the hardware occupied until explicitly stopped, causing a critical
      // privacy leak where the camera indicator stays on after leaving.
      await _forceStopLocalMediaTracks(room);

      IsmLiveLog.info(
        'Disconnecting LiveKit room because lifecycle info dialog is shown',
      );
      await room.disconnect();
      _controller.listener = null;
      _controller.room = null;
      _controller.pendingConnection = false;
      _controller.participantTracks.clear();
      _controller.participantList.clear();
      IsmLiveLog.info(
        'Lifecycle info dialog flow: LiveKit room teardown completed',
      );
    } catch (e) {
      // Best-effort: do not block the dialog, but ensure room teardown is attempted.
      IsmLiveLog.error('Failed to disconnect LiveKit room for info dialog: $e');
      // Even if disconnect throws, null out references to prevent reconnect
      // and try to release hardware.
      _controller.listener = null;
      _controller.room = null;
      _controller.pendingConnection = false;
      _controller.participantTracks.clear();
      _controller.participantList.clear();
    }
  }

  /// Fire-and-forget helper: stops tracks, disconnects room, nulls references.
  /// Used by dialog close/exit handlers where the caller is synchronous.
  Future<void> _safeForceStopAndDisconnect(lk.Room room) async {
    try {
      await _forceStopLocalMediaTracks(room);
    } catch (_) {}
    try {
      await room.disconnect();
    } catch (_) {}
    _controller.room = null;
    _controller.listener = null;
  }

  /// Forcefully unpublishes and stops all local media tracks (camera + mic).
  ///
  /// On iOS, calling only `room.disconnect()` does NOT reliably release the
  /// native camera/microphone hardware. The underlying WebRTC tracks can keep
  /// the hardware occupied, causing the iOS camera/mic indicator to stay active.
  /// This method explicitly unpublishes all tracks and stops each one to
  /// guarantee hardware release.
  Future<void> _forceStopLocalMediaTracks(lk.Room room) async {
    final localParticipant = room.localParticipant;
    if (localParticipant == null) {
      IsmLiveLog.info('No local participant — skipping track stop');
      return;
    }

    try {
      // Collect track references before unpublishing (unpublish may clear them).
      // .toList() creates a snapshot so concurrent modification is safe.
      final videoTracks = localParticipant.videoTrackPublications
          .map((pub) => pub.track)
          .whereType<lk.LocalVideoTrack>()
          .toList();
      final audioTracks = localParticipant.audioTrackPublications
          .map((pub) => pub.track)
          .whereType<lk.LocalAudioTrack>()
          .toList();

      // Unpublish all tracks first (removes from server-side)
      try {
        await localParticipant.unpublishAllTracks();
      } catch (e) {
        IsmLiveLog.error('Error unpublishing tracks: $e');
      }

      // Explicitly stop each video track to release camera hardware.
      // Each call is independent — one failure must not prevent others.
      for (final track in videoTracks) {
        try {
          await track.stop();
          IsmLiveLog.info('Stopped local video track: ${track.sid}');
        } catch (e) {
          IsmLiveLog.error('Error stopping video track: $e');
        }
      }

      // Explicitly stop each audio track to release microphone hardware.
      for (final track in audioTracks) {
        try {
          await track.stop();
          IsmLiveLog.info('Stopped local audio track: ${track.sid}');
        } catch (e) {
          IsmLiveLog.error('Error stopping audio track: $e');
        }
      }

      IsmLiveLog.info(
        'Force-stopped ${videoTracks.length} video and ${audioTracks.length} audio local tracks',
      );
    } catch (e) {
      IsmLiveLog.error('Error in _forceStopLocalMediaTracks: $e');
    } finally {
      // Always mark media as off, even on partial failure, so UI does not
      // show stale "camera on" / "mic on" state.
      _controller.videoOn = false;
      _controller.audioOn = false;
    }
  }

  // Debug method to manually trigger background lifecycle for testing
  void debugTriggerBackgroundLifecycle(AppLifecycleState state) {
    IsmLiveLog.info(
        'DEBUG: Manually triggering background lifecycle state: $state');
    handleBackgroundLifecycleState(state);
  }
}
