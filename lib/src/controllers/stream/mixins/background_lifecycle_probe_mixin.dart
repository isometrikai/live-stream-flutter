import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
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
  Duration _backgroundTimeoutDuration = const Duration(minutes: 5);

  // Timers for background handling
  Timer? _backgroundTimer;
  Timer? _reconnectTimer;
  bool _videoPausedByBackground = false;

  // Camera error tracking
  int _cameraErrorCount = 0;
  static const int _maxCameraErrors = 3;
  int _streamViewSessionId = 0;
  bool _hasShownInfoDialogInSession = false;

  /// Server accepts this as a non-chat capability check. Presence messages are handled
  /// without adding them to the visible chat list.
  static const String _foregroundCapabilityProbeBody = '__ism_live_foreground_probe__';

  /// Target: probe + reconnect + checks complete within ~4s or we show the info dialog.
  static const Duration _foregroundProbeTimeout = Duration(milliseconds: 1200);
  static const Duration _preResumeConnectedVerifyDelay =
      Duration(milliseconds: 100);
  static const Duration _afterConnectStabilizeDelay =
      Duration(milliseconds: 180);
  static const Duration _postResumeRoomStabilityDelay =
      Duration(milliseconds: 320);
  static const Duration _roomConnectTimeout = Duration(milliseconds: 1900);

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
    if (backgroundTimeout != null) {
      _backgroundTimeoutDuration = backgroundTimeout;
    }
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
    _backgroundTimer?.cancel();
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

  void handleBackgroundLifecycleState(AppLifecycleState state) {
    IsmLiveLog.info('Background lifecycle state received: $state');

    // Ignore inactive events for background handling; they are transient (e.g., system overlays)
    if (state == AppLifecycleState.inactive) {
      IsmLiveLog.info('Ignoring inactive state');
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
    _backgroundTimer?.cancel();
    _reconnectTimer?.cancel();

    if (_isStreamActive.value) {
      unawaited(_runForegroundResumeFlow());
    }
  }

  /// After background: send a silent `IsmLiveMessageType.presence` message first.
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
      IsmLiveLog.info('Reconnection already in progress, skipping foreground resume');
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
      IsmLiveLog.info(
          'Foreground capability probe failed — resolving via API and dialogs');
      await _callApiAndShowDialog(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      );
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
        sendMessageModel: IsmLiveSendMessageModel(
          streamId: streamId,
          body: _foregroundCapabilityProbeBody,
          searchableTags: [_foregroundCapabilityProbeBody],
          metaData: const IsmLiveMetaData(),
          deviceId: deviceId,
          messageType: IsmLiveMessageType.presence,
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
      _pauseVideoForBackground();
    }

    // Host audio continues indefinitely in background
    // Background notification removed as per requirement
  }

  void _handleViewerBackground() {
    IsmLiveLog.info('Viewer going to background');

    // Pause video immediately if not enabled for background
    if (!_enableBackgroundVideo) {
      _pauseVideoForBackground();
    }

    // Set timer to disconnect viewer after timeout
    _backgroundTimer = Timer(_backgroundTimeoutDuration * 2, () {
      if (_isInBackground.value && _isStreamActive.value) {
        IsmLiveLog.info('Viewer background timeout - disconnecting');
        _controller.disconnectStream(
            isHost: _isHost.value, streamId: _controller.room?.name ?? '');
      }
    });

    // Enable background audio if configured
    if (_enableBackgroundAudio) {
      _enableBackgroundAudioPlayback();
    }
  }

  void _pauseVideoForBackground() {
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

        // Video was enabled, so pause it for background and set flag
        IsmLiveLog.info(
            'Pausing host video for background using existing toggleVideo method');
        _videoPausedByBackground = true;
        _controller.toggleVideo(value: false);
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
    // Ensure audio continues in background using existing toggleSpeaker method
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
              'Resuming host camera using existing toggleVideo method');
          _controller.toggleVideo(value: true);
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
    _backgroundTimer?.cancel();
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
    _backgroundTimer?.cancel();
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
      IsmLiveLog.info('Room is disconnected, attempting single reconnection');
      _attemptSingleReconnection(
          sessionId: sessionId, expectedStreamId: expectedStreamId);
    } else {
      IsmLiveLog.info(
          'Room connection state unclear, attempting single reconnection');
      _attemptSingleReconnection(
          sessionId: sessionId, expectedStreamId: expectedStreamId);
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
      unawaited(_callApiAndShowDialog(
        sessionId: sessionId,
        expectedStreamId: expectedStreamId,
      ));
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
        unawaited(_callApiAndShowDialog(
            sessionId: sessionId, expectedStreamId: expectedStreamId));
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
            unawaited(_callApiAndShowDialog(
                sessionId: sessionId, expectedStreamId: expectedStreamId));
          }
        } catch (e) {
          IsmLiveLog.error('Single reconnection attempt failed with error: $e');
          _isReconnecting = false;
          // Check if stream is still active before calling API
          if (_isStreamActive.value &&
              _isSessionValid(sessionId) &&
              _isExpectedStream(expectedStreamId)) {
            unawaited(_callApiAndShowDialog(
                sessionId: sessionId, expectedStreamId: expectedStreamId));
          }
        }
      } else {
        IsmLiveLog.info('No stored token available, calling API immediately');
        _isReconnecting = false;
        unawaited(_callApiAndShowDialog(
            sessionId: sessionId, expectedStreamId: expectedStreamId));
      }
    } catch (e) {
      IsmLiveLog.error('Error in single reconnection: $e');
      _isReconnecting = false;
      // Check if stream is still active before calling API
      if (_isStreamActive.value &&
          _isSessionValid(sessionId) &&
          _isExpectedStream(expectedStreamId)) {
        unawaited(_callApiAndShowDialog(
            sessionId: sessionId, expectedStreamId: expectedStreamId));
      }
    }
  }

  /// Call API immediately and show dialog based on result
  Future<void> _callApiAndShowDialog({
    int? sessionId,
    String? expectedStreamId,
  }) async {
    try {
      final effectiveSessionId = sessionId ?? _streamViewSessionId;
      IsmLiveLog.info('Calling API immediately without delay...');

      if (!_isStreamActive.value ||
          _controller.streamId == null ||
          !_isSessionValid(effectiveSessionId) ||
          !_isExpectedStream(expectedStreamId)) {
        IsmLiveLog.info(
            'Stream/session not valid, streamId mismatch, or streamId is null, skipping API check');
        return;
      }

      final isStreamActive =
          await _checkStreamActiveStatus(_controller.streamId!);

      // Check again after async operation - stream might have been closed
      if (!_isStreamActive.value ||
          !_isSessionValid(effectiveSessionId) ||
          !_isExpectedStream(expectedStreamId)) {
        IsmLiveLog.info(
            'Stream/session became invalid during API call, skipping dialog');
        return;
      }

      if (isStreamActive) {
        IsmLiveLog.info(
            'API check: Stream is still active but reconnection failed');
        // Stream is active but we couldn't reconnect, show connection issue dialog
        _showConnectionFailedDialog(
            sessionId: effectiveSessionId, expectedStreamId: expectedStreamId);
      } else {
        IsmLiveLog.info(
            'API check: Stream is no longer active, showing dialog');
        _showStreamEndedDialog(
            sessionId: effectiveSessionId, expectedStreamId: expectedStreamId);
      }
    } catch (e) {
      IsmLiveLog.error('Error in immediate API call: $e');
      // Check if stream is still active before showing error dialog
      if (_isStreamActive.value) {
        _showConnectionFailedDialog(
            sessionId: sessionId, expectedStreamId: expectedStreamId);
      }
    }
  }

  /// Check if stream is still active by calling fetchModerators API
  Future<bool> _checkStreamActiveStatus(String streamId) async {
    try {
      // Call the repository method directly to get HTTP status code
      final repository = _controller.viewModel.repository;
      final response = await repository.fetchModerators(
        isLoading: false,
        streamId: streamId,
        skip: 0,
        limit: 1,
      );

      // Check if response has successful HTTP status code (200-299)
      final statusCode = response.statusCode;
      final isSuccess =
          statusCode >= 200 && statusCode < 300 && !response.hasError;

      IsmLiveLog.info(
          'fetchModerators API status code: $statusCode, hasError: ${response.hasError}, success: $isSuccess');

      return isSuccess;
    } catch (e) {
      IsmLiveLog.error('Error calling fetchModerators API: $e');
      return false;
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

    final currentRoute = Get.currentRoute;
    final isOnStreamView = currentRoute == IsmLiveRoutes.streamView;
    if (!isOnStreamView) {
      IsmLiveLog.info(
          'Skipping info dialog because current route is not stream view: $currentRoute');
    }
    return isOnStreamView;
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

  /// Show dialog when stream has ended
  void _showStreamEndedDialog({int? sessionId, String? expectedStreamId}) {
    try {
      // Final check before showing dialog
      if (!_isStreamActive.value) {
        IsmLiveLog.info('Stream is not active, skipping stream ended dialog');
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
          ? 'Stream has been stopped. Please start a new stream'
          : 'The stream you were watching has ended. Please browse other streams';

      IsmLiveUtility.showCustomDialog(
        _streamLifecycleInfoDialogLayout(
          message: message,
          textAlign: TextAlign.center,
          gapBeforeExitButton: IsmLiveDimens.boxHeight16,
        ),
        isDismissible: false,
      );
    } catch (e) {
      IsmLiveLog.error('Error showing stream ended dialog: $e');
    }
  }

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
