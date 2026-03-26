import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

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

  // Camera error tracking
  int _cameraErrorCount = 0;
  static const int _maxCameraErrors = 3;
  int _streamViewSessionId = 0;
  bool _hasShownInfoDialogInSession = false;

  /// Internal probe payload used for foreground capability checks.
  /// UI layer filters this body so it never appears in chat.
  static const String _foregroundCapabilityProbeBody =
      '__ism_live_foreground_probe__';

  /// Target: probe + reconnect + checks complete within ~4s or we show the info dialog.
  static const Duration _foregroundProbeTimeout = Duration(milliseconds: 6000);
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
      IsmLiveLog.info('Started stream view session: $_streamViewSessionId');
      IsmLiveLog.info('Stream is active, initializing background lifecycle');
      _storeConnectionDetails();
      initializeBackgroundLifecycle();
    } else {
      _streamViewSessionId++;
      _hasShownInfoDialogInSession = false;
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
      _controller._isInBackground.value = true; // Sync with controller
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
    _controller._isInBackground.value = false; // Sync with controller
    _reconnectTimer?.cancel();

    if (_isStreamActive.value) {
      // Resume MQTT fallback polling if it was paused in background.
      _controller.resumeMqttDisconnectedChatFallbackIfNeeded();
      unawaited(_runForegroundResumeFlow());
    }
  }

  /// After background: send a silent probe message first.
  /// If the server accepts it, the stream is still valid for this user — then reconnect
  /// LiveKit and resume UI. If the probe fails, fall back to API + dialogs (host/viewer).
  Future<void> _runForegroundResumeFlow() async {
    final sessionId = _streamViewSessionId;
    final expectedStreamId = _controller.streamId;

    IsmLiveLog.info(
        'Foreground resume: checking stream capability via silent presence message...');

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

    final probeOk = await _sendStreamCapabilityProbeMessage().timeout(
      _foregroundProbeTimeout,
      onTimeout: () {
        IsmLiveLog.info(
            'Foreground capability probe timed out ($_foregroundProbeTimeout)');
        return false;
      },
    );

    if (!_isStreamActive.value ||
        !_isSessionValid(sessionId) ||
        !_isExpectedStream(expectedStreamId)) {
      IsmLiveLog.info('Stream/session changed during probe, aborting');
      return;
    }

    if (!probeOk) {
      if (!_isHost.value) {
        IsmLiveLog.info(
            'Foreground capability probe failed — viewer will rejoin via API (fresh token)');
        final ok = await _controller.rejoinCurrentViewerStreamAfterForeground(
          showProgress: true,
        );
        if (!_isStreamActive.value ||
            !_isSessionValid(sessionId) ||
            !_isExpectedStream(expectedStreamId)) {
          IsmLiveLog.info('Stream/session changed during API rejoin, aborting');
          return;
        }
        if (ok) {
          IsmLiveLog.info('Viewer API rejoin succeeded — resuming stream');
          _resumeStreamWithPostConnectVerify(
            sessionId: sessionId,
            expectedStreamId: expectedStreamId,
          );
        } else {
          IsmLiveLog.info('Viewer API rejoin failed — showing info dialog');
          _showConnectionFailedDialog(
            sessionId: sessionId,
            expectedStreamId: expectedStreamId,
          );
        }
      } else {
        IsmLiveLog.info(
            'Foreground capability probe failed — host will attempt in-place room rebuild rejoin');
        final ok = await _controller.rejoinCurrentHostStreamAfterForeground();
        if (!_isStreamActive.value ||
            !_isSessionValid(sessionId) ||
            !_isExpectedStream(expectedStreamId)) {
          IsmLiveLog.info(
              'Stream/session changed during host rejoin, aborting');
          return;
        }
        if (ok) {
          IsmLiveLog.info('Host rejoin succeeded — resuming stream');
          _resumeStreamWithPostConnectVerify(
            sessionId: sessionId,
            expectedStreamId: expectedStreamId,
          );
        } else {
          IsmLiveLog.info('Host rejoin failed — showing info dialog');
          _showConnectionFailedDialog(
            sessionId: sessionId,
            expectedStreamId: expectedStreamId,
          );
        }
      }
      return;
    }

    IsmLiveLog.info('Foreground probe succeeded — checking room and resuming');
    _checkRoomStateAndResumeAfterProbe(
      sessionId: sessionId,
      expectedStreamId: expectedStreamId,
    );
  }

  Future<bool> _sendStreamCapabilityProbeMessage() async {
    final streamId = _controller.streamId;
    if (streamId == null || streamId.isEmpty) {
      return false;
    }
    try {
      final deviceId = _controller.configuration?.projectConfig.deviceId ?? '';
      final sent = await _controller.sendMessage(
        showLoading: false,
        showDialog: false,
        sendMessageModel: IsmLiveSendMessageModel(
          streamId: streamId,
          body: _foregroundCapabilityProbeBody,
          searchableTags: [_foregroundCapabilityProbeBody],
          metaData: const IsmLiveMetaData(),
          deviceId: deviceId,
          messageType: IsmLiveMessageType.probe,
        ),
      );
      IsmLiveLog.info('Foreground capability probe send result: $sent');
      return sent;
    } catch (e, st) {
      IsmLiveLog.error('Foreground capability probe error: $e', st);
      return false;
    }
  }

  void _handleAppPaused() {
    IsmLiveLog.info('App paused - going to background');
    _isInBackground.value = true;
    _controller._isInBackground.value = true; // Sync with controller
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
    _controller._isInBackground.value = true; // Sync with controller
    // Stop chat polling immediately while backgrounded.
    _controller.pauseMqttDisconnectedChatFallback();
    _handleAppPaused();
  }

  void _handleStreamBackground() {
    if (!_isStreamActive.value) return;

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
      if (_isHost.value && _videoPausedByBackground) {
        IsmLiveLog.info('Host video was paused by background, resuming camera');
        _resumeCameraWithRetry();
      } else if (_isHost.value) {
        IsmLiveLog.info('Host resumed from background - video was not paused');
      } else {
        IsmLiveLog.info('Viewer resumed from background');
      }

      _notifyHostBack();
      // Background notification hiding removed as per requirement
    });
  }

  void _resumeCameraWithRetry() {
    const maxAttempts = 3;
    var attempts = 0;

    Future<void> attemptResume() async {
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

  /// After a successful capability probe, align LiveKit and resume local media.
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
    } else if (room != null &&
        connectionState == lk.ConnectionState.disconnected) {
      // Viewer recovery: a disconnected room after a successful probe can still
      // fail reconnection due to `duplicateIdentity`. Prefer API rejoin which
      // rebuilds the Room cleanly with a fresh token.
      if (!_isHost.value) {
        IsmLiveLog.info(
            'Room is disconnected after probe — viewer will rejoin via API (fresh token)');
        unawaited(_viewerRejoinViaApiOrShowDialog(
          sessionId: sessionId,
          expectedStreamId: expectedStreamId,
        ));
      } else {
        IsmLiveLog.info(
            'Room is disconnected after probe — host will rejoin by rebuilding room');
        unawaited(_hostRejoinViaRoomRebuildOrShowDialog(
          sessionId: sessionId,
          expectedStreamId: expectedStreamId,
        ));
      }
    } else {
      IsmLiveLog.info(
          'Room connection state unclear, attempting single reconnection');
      _attemptSingleReconnection(
          sessionId: sessionId, expectedStreamId: expectedStreamId);
    }
  }

  Future<void> _hostRejoinViaRoomRebuildOrShowDialog({
    required int sessionId,
    required String? expectedStreamId,
  }) async {
    final ok = await _controller.rejoinCurrentHostStreamAfterForeground();
    if (!_isStreamActive.value ||
        !_isSessionValid(sessionId) ||
        !_isExpectedStream(expectedStreamId)) {
      IsmLiveLog.info('Stream/session changed during host rejoin, aborting');
      return;
    }
    if (ok) {
      _resumeStreamWithPostConnectVerify(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      );
    } else {
      _showConnectionFailedDialog(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      );
    }
  }

  Future<void> _viewerRejoinViaApiOrShowDialog({
    required int sessionId,
    required String? expectedStreamId,
  }) async {
    final ok = await _controller.rejoinCurrentViewerStreamAfterForeground(
      showProgress: true,
    );
    if (!_isStreamActive.value ||
        !_isSessionValid(sessionId) ||
        !_isExpectedStream(expectedStreamId)) {
      IsmLiveLog.info(
          'Stream/session changed during viewer API rejoin, aborting');
      return;
    }
    if (ok) {
      _resumeStreamWithPostConnectVerify(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      );
    } else {
      _showConnectionFailedDialog(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      );
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
    IsmLiveUtility.closeDialog();
  }

  void _exitStreamFromLifecycleInfoDialog() {
    IsmLiveUtility.closeDialog();
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
  void _showConnectionFailedDialog({int? sessionId, String? expectedStreamId}) {
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

  // Debug method to manually trigger background lifecycle for testing
  void debugTriggerBackgroundLifecycle(AppLifecycleState state) {
    IsmLiveLog.info(
        'DEBUG: Manually triggering background lifecycle state: $state');
    handleBackgroundLifecycleState(state);
  }
}
