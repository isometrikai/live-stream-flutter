part of '../stream_controller.dart';

// This mixin provides methods for joining and initializing streams
mixin StreamJoinMixin {
  // Get references to the necessary controllers and wrappers using Get.find()
  IsmLiveStreamController get _controller => Get.find();
  IsmLiveDBWrapper get _dbWrapper => Get.find();

  // Check if Go Live is enabled by checking if the description controller is not empty
  bool get isGoLiveEnabled => _controller.descriptionController.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Shared video quality presets
  //
  // NOTE:
  // - Use ONE source of truth for dimensions/bitrates across:
  //   - camera capture (manual track creation)
  //   - room default capture options
  //   - publish options / simulcast layers
  // ---------------------------------------------------------------------------

  // HD: 1080p portrait, 30fps ~6Mbps (industry-standard live baseline)
  static const lk.VideoParameters _lkHdVideoParams = lk.VideoParameters(
    dimensions: // lk.VideoDimensions(1080, 1920),
        lk.VideoDimensionsPresets.h1080_169,
    encoding: lk.VideoEncoding(
      maxFramerate: 30,
      maxBitrate: 6000 * 1000,
    ),
  );

  // SD: 30fps ~3Mbps
  static const lk.VideoParameters _lkSdVideoParams = lk.VideoParameters(
    dimensions: // lk.VideoDimensions(720, 1280),
        lk.VideoDimensionsPresets.h720_169,
    encoding: lk.VideoEncoding(
      maxFramerate: 25,
      maxBitrate: 2500 * 1000,
    ),
  );

  /// Restream: quality between SD and full HD, tuned for external platforms.
  static const lk.VideoParameters _lkRestreamVideoParams = lk.VideoParameters(
    dimensions: // lk.VideoDimensions(720, 1280),
        lk.VideoDimensionsPresets.h720_169,
    encoding: lk.VideoEncoding(
      maxFramerate: 30,
      maxBitrate: 4000 * 1000,
    ),
  );

  lk.VideoParameters _resolveLkVideoParams({
    required bool hdBroadcast,
    required bool restream,
  }) {
    if (hdBroadcast) return _lkHdVideoParams;
    if (restream) return _lkRestreamVideoParams;
    return _lkSdVideoParams;
  }

  // Note: Simulcast layers are currently not used; keep the resolver ready
  // for future multi-bitrate setups if needed.

// Initialize the Go Live process by requesting camera permission and initializing the camera controller
  Future<void> initializationOfGoLive() async {
    // Prevent multiple simultaneous initializations
    if (_controller.cameraFuture != null) {
      return;
    }

    // Set a placeholder future immediately to prevent multiple calls
    _controller.cameraFuture = _initializeCameraAsync();
    _controller.update([IsmGoLiveView.cameraUpdateId]);
  }

  Future<void> _initializeCameraAsync() async {
    try {
      // Request permission without blocking
      final permissionStatus = await Permission.camera.request();

      if (!permissionStatus.isGranted) {
        IsmLiveLog.error('Camera permission not granted');
        return;
      }

      // Wait for cameras to be available from IsmLiveHandler.initialize() if it's still initializing
      if (IsmLiveUtility.camerasInitializationFuture != null) {
        try {
          await IsmLiveUtility.camerasInitializationFuture;
        } catch (e) {
          IsmLiveLog.error('Error waiting for camera initialization: $e');
        }
      }

      // Retry logic: Sometimes camera needs a moment to be released
      var retryCount = 0;
      const maxRetries = 3;
      const retryDelay = Duration(milliseconds: 300);

      while (retryCount < maxRetries) {
        // If still empty after waiting, try to get cameras directly (but only if not already initializing)
        if (IsmLiveUtility.cameras.isEmpty &&
            IsmLiveUtility.camerasInitializationFuture == null) {
          try {
            IsmLiveUtility.camerasInitializationFuture = availableCameras();
            IsmLiveUtility.cameras =
                await IsmLiveUtility.camerasInitializationFuture!;
          } catch (e) {
            IsmLiveLog.error('Failed to get available cameras: $e');
            if (retryCount < maxRetries - 1) {
              await Future.delayed(retryDelay);
              retryCount++;
              continue;
            }
            return;
          }
        }

        // Check if we have at least one camera available
        if (IsmLiveUtility.cameras.isNotEmpty) {
          break;
        }

        if (retryCount < maxRetries - 1) {
          IsmLiveLog.info(
              'No cameras available, retrying... (${retryCount + 1}/$maxRetries)');
          await Future.delayed(retryDelay);
          retryCount++;
        } else {
          IsmLiveLog.error('No cameras available after $maxRetries retries');
          return;
        }
      }

      // Use front camera (index 1) if available, otherwise use back camera (index 0)
      final cameraIndex = IsmLiveUtility.cameras.length > 1 ? 1 : 0;

      _controller.cameraController = CameraController(
        IsmLiveUtility.cameras[cameraIndex],
        ResolutionPreset.medium,
      );
      await _controller.cameraController!.initialize();
      // Lock camera orientation to portrait to prevent rotation on iOS
      await _controller.cameraController!
          .lockCaptureOrientation(DeviceOrientation.portraitUp);
      _controller.update([IsmGoLiveView.cameraUpdateId]);
    } catch (e) {
      IsmLiveLog.error('Failed to initialize camera: $e');
      _controller.cameraController?.dispose();
      _controller.cameraController = null;
      _controller.cameraFuture = null;
    }
  }

// Initialize and join a stream
  Future<void> initializeAndJoinStream(
    IsmLiveStreamDataModel stream,
    bool isHost, {
    bool joinByScrolling = false,
    bool isScrolling = false,
    required BuildContext context,
    bool reJoin = false,
    VoidCallback? onStreamEnd,
  }) async {
    final startedAt = DateTime.now();
    _controller.resetOnStreamEndTrigger();

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.controllerInitializeAndJoinAttempt,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'is_host': isHost,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          're_join': reJoin,
          'has_existing_room': _controller.room != null,
          'existing_stream_id': _controller.streamId ?? '',
        }
      ],
    );

    // Auto-detect rejoin scenario: if controller already has data for this stream
    // and we're not explicitly setting reJoin to false, treat it as rejoin
    // Note: Don't check listener as it might be cleared during disposal
    var isRejoinScenario = reJoin ||
        (_controller.streamId == stream.streamId && _controller.room != null);

    if (isRejoinScenario && !reJoin) {
      reJoin = true;

      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.controllerRejoinAutoDetected,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'reason': 'same_stream_id_and_room_present',
          }
        ],
      );
    }

    // Set preventDispose flag immediately for rejoin scenarios to prevent data clearing
    if (reJoin) {
      _controller.preventDispose = true;

      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.controllerPreventDisposeEnabled,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
          }
        ],
      );
    }

    final streamIndex = _controller.streams.indexOf(stream);
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.controllerInitializeIndex,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'index': streamIndex,
        }
      ],
    );

    initialize(streamIndex);

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.controllerJoinStreamAttempt,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'is_host': isHost,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          're_join': reJoin,
        }
      ],
    );

    try {
      await joinStream(
        stream,
        isHost,
        joinByScrolling: joinByScrolling,
        isScrolling: isScrolling,
        context: context,
        reJoin: reJoin,
        onStreamEnd: onStreamEnd,
      );
    } catch (e) {
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.controllerJoinStreamFailure,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': e.toString(),
          }
        ],
      );
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.controllerInitializeAndJoinFailure,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': e.toString(),
          }
        ],
      );
      rethrow;
    }
  }

  bool isScheduleStreamNotStartedYet(IsmLiveStreamDataModel stream) {
    if (stream.isScheduledStream == true &&
        (stream.streamId == null ||
            stream.streamId?.isEmpty == true ||
            stream.streamId?.contains('0000') == true)) {
      return true;
    }
    return false;
  }

// Initialize the page controller
  void initialize(int index) {
    _controller.pageController = PageController(
      initialPage: index,
    );
  }

  // Enable the user's video
  Future<void> enableMyVideo() async {
    if (_controller.room == null) {
      return;
    }

    try {
      // Ensure the Camera plugin controller is released before WebRTC opens camera
      try {
        await _controller.cameraController?.dispose();
        _controller.cameraController = null;
        _controller.cameraFuture = null;
      } catch (e) {
        IsmLiveLog.error('cameraController dispose before WebRTC error: $e');
      }

      final captureParams = _resolveLkVideoParams(
        hdBroadcast: _controller.isHdBroadcast,
        restream: _controller.isRestreamBroadcast,
      );

      // Match room / UI: `_connectRoomAndInitialize` sets `_controller.position`
      // from the delegate on first join and preserves it on rejoin.
      final resolvedCameraPosition = _controller.position;

      final tracks = await Future.wait([
        lk.LocalVideoTrack.createCameraTrack(
          lk.CameraCaptureOptions(
            cameraPosition: resolvedCameraPosition,
            params: captureParams,
          ),
        ),
        lk.LocalAudioTrack.create(),
      ]);
      var localVideo = tracks[0] as lk.LocalVideoTrack;
      var localAudio = tracks[1] as lk.LocalAudioTrack;

      await Future.wait<dynamic>([
        _controller.room!.localParticipant!.publishVideoTrack(localVideo),
        _controller.room!.localParticipant!.publishAudioTrack(localAudio),
      ]);
      // Keep UI flag in sync so settings / sync helpers don’t think video is off
      // while tracks are live (e.g. after foreground room rebuild).
      _controller.videoOn = true;
      _controller.audioOn = true;
    } catch (e) {
      IsmLiveLog.error('enableMyVideo error: $e');
      // Don't rethrow - let the stream continue without video/audio if needed
    }
  }

// Toggle audio on/off
  Future<void> toggleAudio({
    bool? value,
  }) async {
    final participant = _controller.room?.localParticipant;

    _controller.audioOn = value ?? !_controller.audioOn;

    try {
      await participant?.setMicrophoneEnabled(_controller.audioOn);
    } catch (error) {
      _controller.audioOn = !_controller.audioOn;
      IsmLiveLog('toggleAudio function  error  $error');
    }
    _controller.update();
  }

  Future<void> unpublishTracks() async {
    try {
      await _controller.room!.localParticipant!.unpublishAllTracks();
    } catch (e) {
      IsmLiveLog.error('unpublishTracks error: $e');
    }
  }

  /// Removes only the camera publication (keeps microphone).
  ///
  /// Used when the host backgrounds with video “off”: `setCameraEnabled(false)`
  /// mutes with default `stopCameraCaptureOnMute`, which can leave a publication
  /// whose native track is gone. After a long sleep / full reconnect, LiveKit
  /// calls [LocalParticipant.rePublishAllTracks] and crashes with
  /// `addTransceiver(): track is null`. Unpublishing avoids that stale entry.
  Future<void> unpublishLocalCameraTrackOnly() async {
    if (_controller.isRtmp) return;
    final lp = _controller.room?.localParticipant;
    if (lp == null) return;
    try {
      final pub = lp.getTrackPublicationBySource(lk.TrackSource.camera);
      if (pub != null) {
        await lp.removePublishedTrack(pub.sid);
      }
    } catch (e) {
      IsmLiveLog.error('unpublishLocalCameraTrackOnly error: $e');
    }
  }

  /// Awaitable camera on for hosts resuming from background (after unpublish).
  Future<void> resumeHostCameraAfterBackground() async {
    if (_controller.isRtmp) return;
    final participant = _controller.room?.localParticipant;
    if (participant == null) return;
    _controller.videoOn = true;
    try {
      await participant.setCameraEnabled(true);
      await _syncPublishedCameraToControllerPosition(participant);
      _controller.update();
    } catch (error) {
      // After a full rejoin, `enableMyVideo()` may already publish camera; a second
      // `setCameraEnabled(true)` can throw. Don’t force UI/video off if track exists.
      final pub =
          participant.getTrackPublicationBySource(lk.TrackSource.camera);
      final trackAlive = pub?.track != null;
      if (trackAlive) {
        IsmLiveLog.info(
            'resumeHostCameraAfterBackground: setCameraEnabled failed but camera track still present: $error');
        _controller.videoOn = true;
        await _syncPublishedCameraToControllerPosition(participant);
        _controller.update();
        return;
      }
      _controller.videoOn = false;
      IsmLiveLog.error('resumeHostCameraAfterBackground error: $error');
      rethrow;
    }
  }

  /// After unpublish + republish or SDK default capture, align hardware with [IsmLiveStreamController.position].
  Future<void> _syncPublishedCameraToControllerPosition(
    lk.LocalParticipant participant,
  ) async {
    final pub = participant.getTrackPublicationBySource(lk.TrackSource.camera);
    final track = pub?.track;
    if (track is! lk.LocalVideoTrack) return;
    try {
      await track.setCameraPosition(_controller.position);
    } catch (e) {
      IsmLiveLog.error('_syncPublishedCameraToControllerPosition: $e');
    }
  }

// Join a stream
  Future<void> joinStream(
    IsmLiveStreamDataModel stream,
    bool isHost, {
    bool joinByScrolling = false,
    bool isScrolling = false,
    bool isInteractive = false,
    VoidCallback? onStreamEnd,
    required BuildContext context,
    bool reJoin = false,
  }) async {
    final startedAt = DateTime.now();
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.joinStreamAttempt,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'is_host': isHost,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          're_join': reJoin,
          'is_scheduled_stream': stream.isScheduledStream ?? false,
          'is_pk': stream.isPkChallenge ?? false,
          'hd_broadcast': stream.hdBroadcast ?? false,
          'restream': stream.restream ?? false,
          'audio_only': stream.audioOnly ?? false,
        }
      ],
    );

    // Handle scheduled stream not started yet here to avoid duplicate navigation during scrolling
    if (isScheduleStreamNotStartedYet(stream)) {
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.joinStreamEarlyReturnScheduledNotStarted,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'is_host': isHost,
            'join_by_scrolling': joinByScrolling,
            'is_scrolling': isScrolling,
            're_join': reJoin,
          }
        ],
      );
      startSeduleStream(
        stream,
        isHost: isHost,
        isScrolling: isScrolling,
        joinByScrolling: joinByScrolling,
      );
      return;
    }
    // Get the token for the stream based on whether the user is a host or not
    if (onStreamEnd != null) {
      IsmLiveApp.onStreamEnd = onStreamEnd;
    }

    var token = '';
    var viewerUsedCachedToken = false;
    if (isHost) {
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.joinStreamTokenFetchHost,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
          }
        ],
      );
      token = await _dbWrapper.getSecuredValue(stream.streamId ?? '');

      if (token.trim().isEmpty) {
        final streamId = stream.streamId ?? '';
        final userId = _controller.user?.userId ?? '';
        final stopCallback = IsmLiveDelegate.missingHostTokenStopStreamCallback;
        var shouldCallStopStreamApi = true;

        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.joinStreamMissingHostToken,
          properties: [
            {
              'stream_id': streamId,
              'event_id': stream.eventId ?? '',
              'user_id': userId,
              'has_stop_callback': stopCallback != null,
            }
          ],
        );

        if (stopCallback != null) {
          try {
            shouldCallStopStreamApi =
                await stopCallback(context, streamId, userId);
          } catch (error, stackTrace) {
            IsmLiveLog.error(
              'missingHostTokenStopStreamCallback failed: $error',
              stackTrace,
            );
            // Preserve legacy behavior if host callback fails unexpectedly.
            shouldCallStopStreamApi = true;
          }
        } else {
          final shouldStopFromSheet =
              await IsmLiveUtility.openCustomBottomSheet<bool>(
            title:
                "It looks like you're already live from another device. Do you want to stop that stream?",
            leftLabel: 'no'.tr,
            rightLabel: 'yes'.tr,
            onLeft: () => IsmLiveRoute.pop(false),
            onRight: () => IsmLiveRoute.pop(true),
          );
          shouldCallStopStreamApi = shouldStopFromSheet ?? false;
        }

        if (shouldCallStopStreamApi) {
          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.joinStreamStopStreamCalled,
            properties: [
              {
                'stream_id': streamId,
                'event_id': stream.eventId ?? '',
                'user_id': userId,
              }
            ],
          );
          await _controller.stopStream(streamId, userId);
        }
        return;
      }
    } else {
      final streamId = stream.streamId ?? '';
      var existingToken = (await _dbWrapper.getSecuredValue(streamId)).trim();

      if (existingToken.isNotEmpty) {
        token = existingToken;
        viewerUsedCachedToken = true;
      } else {
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.joinStreamTokenFetchViewer,
          properties: [
            {
              'stream_id': stream.streamId ?? '',
              'event_id': stream.eventId ?? '',
            }
          ],
        );
        var data = await _controller.getRTCToken(streamId);
        if (data == null) {
          return;
        }

        token = data.rtcToken;

        // Store the start time for later calculation instead of calculating duration immediately
        _controller._streamStartTime = data.startTime;
      }
    }

    _controller.isRtmp = stream.rtmpIngest ?? false;
    _controller.isPremium = stream.isPaid ?? false;

    if (_controller.isPremium) {
      _controller.premiumStreamCoinsController.text = stream.amount.toString();
    }

    // Store fallback start time for later calculation
    if (_controller._streamStartTime == null && stream.startDateTime != null) {
      _controller._streamStartTime = stream.startDateTime;
    }

    // Initialize stream duration to zero - will be calculated just before timer starts
    _controller.streamDuration = Duration.zero;

    // Connect to the stream
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.joinStreamConnectStreamAttempt,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'is_host': isHost,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          're_join': reJoin,
          'defer_connection': true,
        }
      ],
    );

    try {
      await connectStream(
          stream: stream,
          token: token,
          streamId: stream.streamId!,
          streamImage: stream.streamImage,
          streamDiscription: stream.streamDescription,
          isHost: isHost,
          isNewStream: false,
          isPk: stream.isPkChallenge ?? false,
          joinByScrolling: joinByScrolling,
          isScrolling: isScrolling,
          hdBroadcast: stream.hdBroadcast ?? false,
          isInteractive: isInteractive,
          context: context,
          reJoin: reJoin,
          deferConnection: true);
    } catch (e, st) {
      if (!isHost && viewerUsedCachedToken) {
        final streamId = stream.streamId ?? '';
        IsmLiveLog.error(
          'joinStream: cached viewer RTC token failed, retrying with fresh token: $e',
          st,
        );
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.joinStreamTokenFetchViewer,
          properties: [
            {
              'stream_id': stream.streamId ?? '',
              'event_id': stream.eventId ?? '',
            }
          ],
        );
        final freshData = await _controller.getRTCToken(streamId);
        if (freshData != null && freshData.rtcToken.trim().isNotEmpty) {
          token = freshData.rtcToken;
          _controller._streamStartTime = freshData.startTime;
          try {
            await connectStream(
                stream: stream,
                token: token,
                streamId: stream.streamId!,
                streamImage: stream.streamImage,
                streamDiscription: stream.streamDescription,
                isHost: isHost,
                isNewStream: false,
                isPk: stream.isPkChallenge ?? false,
                joinByScrolling: joinByScrolling,
                isScrolling: isScrolling,
                hdBroadcast: stream.hdBroadcast ?? false,
                isInteractive: isInteractive,
                context: context,
                reJoin: reJoin,
                deferConnection: true);
            return;
          } catch (_) {}
        }
      }
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.joinStreamConnectStreamFailure,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': e.toString(),
          }
        ],
      );
      rethrow;
    }
  }

// Start streaming
  Future<void> startStream(
      {bool isNewStream = true, required BuildContext context}) async {
    if (_controller.isPremium &&
        _controller.premiumStreamCoinsController.isEmpty) {
      _controller.premiumStreamSheet();
      return;
    }

    // Check if cover photo is selected - show toast immediately if not
    if (_controller.pickedImage == null &&
        (_controller.streamDetails?.streamImage?.isEmpty ?? true)) {
      final toastContext = IsmLiveUtility.navigatorKey.currentContext;

      Fluttertoast.showToast(
        msg: IsmLiveStrings.pleaseSelectCoverPhoto,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: toastContext != null
            ? toastContext.dynamicTextTheme.bodyMedium?.fontSize ?? 16.0
            : 16.0,
      );
      return;
    }

    // Create a stream
    dynamic stream;
    final String? image;
    if (_controller.streamDetails?.isScheduledStream ?? false) {
      var res = await goLiveSchedule();

      if (res == null) {
        return;
      }
      stream = res;
      image = _controller.streamDetails?.streamImage;
      _controller.streamDetails =_controller.streamDetails?.copyWith(startDateTime: res.startTime);
    } else {
      var data = await _controller.createStream(context: context);
      if (data == null) {
        return;
      }
      if (data.model == null) {
        return;
      }
      if (data.model?.rtcToken.isEmpty ?? true) {
        unawaited(_controller.fetchScheduledStream(
            type: IsmLiveStreamType.scheduledStreams));

        IsmLiveUtility.showCustomDialog(
          IsmLiveScheduleDialog(
            message: _controller.scheduleLiveDate,
          ),
        );
        _controller.isSchedulingBroadcast = false;
        _controller.update(['ismlive-go-live']);

        return;
      }

      stream = data.model!;
      image = data.image;
    }

    // Store the start time for later calculation instead of calculating duration immediately
    _controller._streamStartTime = stream.startTime;

    // Initialize stream duration to zero - will be calculated just before timer starts
    _controller.streamDuration = Duration.zero;

    _controller.rtmlUrlDevice.text = stream.ingestEndpoint ?? '';
    _controller.streamKeyDevice.text = stream.streamKey ?? '';

    // Connect to the created stream
    await connectStream(
      token: stream.rtcToken,
      streamId: stream.streamId!,
      streamImage: image,
      isHost: true,
      isNewStream: isNewStream,
      hdBroadcast: _controller.isHdBroadcast,
      restream: _controller.isRestreamBroadcast,
      context: context,
      deferConnection: true,
    );
  }

  // Connect to the stream
  Future<void> connectStream({
    IsmLiveStreamDataModel? stream,
    required String token,
    required String streamId,
    String? streamImage,
    String? streamDiscription,
    bool hdBroadcast = false,
    bool restream = false,
    required bool isHost,
    bool isCopublisher = false,
    bool isPk = false,
    bool isPkGust = false,
    required bool isNewStream,
    bool joinByScrolling = false,
    bool isScrolling = false,
    bool isInteractive = false,
    DateTime? startTime,
    required BuildContext context,
    String? eventId,
    bool reJoin = false,
    bool? isScheduledStream,
    List? products,
    // When true, heavy LiveKit connection work is deferred and completed
    // from `stream_view` after navigation for a smoother transition.
    bool deferConnection = false,
  }) async {
    final startedAt = DateTime.now();
    final trackedStartDateTime = (startTime ??
            stream?.startDateTime ??
            _controller.streamDetails?.startDateTime)
        ?.toIso8601String();

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.connectStreamAttemptDetailed,
      properties: [
        {
          'stream_id': streamId,
          'is_host': isHost,
          'is_new_stream': isNewStream,
          're_join': reJoin,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          'is_copublisher': isCopublisher,
          'is_pk': isPk,
          'is_pk_guest': isPkGust,
          'hd_broadcast': hdBroadcast,
          'restream': restream,
          'defer_connection': deferConnection,
          'event_id': eventId,
          'is_scheduled_stream': isScheduledStream,
          'start_date_time': trackedStartDateTime ?? '',
        }
      ],
    );

    // Reset single-fire guards for the new stream lifecycle. Done here
    // (centralized funnel for all connect paths: host startStream, viewer
    // initializeAndJoinStream, scroll join, PK rejoin, copublisher reconnect)
    // instead of streamDispose to avoid the host-end vs viewer-leave race
    // where streamDispose during route teardown would prematurely re-arm
    // closeStreamView and cause a double Navigator.pop on an empty stack.
    _controller.resetOnStreamEndTrigger();

    // Store token for background lifecycle / deferred connect flows.
    // Persist for both host and viewer to support foreground rejoin with cached token.
    _controller.rtcToken = token;
    unawaited(_dbWrapper.saveValueSecurely(streamId, token));

    // When connecting to a different stream than the one we currently
    // hold data for, proactively clear any stale chat messages.
    //
    // The previous stream's `streamDispose()` (which clears the chat list)
    // runs via `IsmLiveUtility.updateLater` (next frame + 10ms). If the user
    // joins a new stream within that window, the next view can briefly show
    // the previous stream's chat. Skipped when `reJoin` is true so that
    // intentional preserve-state flows (PK guest, foreground rejoin) keep
    // their existing messages.
    if (!reJoin &&
        _controller.streamId != null &&
        _controller.streamId!.isNotEmpty &&
        _controller.streamId != streamId &&
        _controller.streamMessagesList.isNotEmpty) {
      _controller.streamMessagesList.clear();
    }

    // Subscribe to the stream
    _controller.streamId = streamId;

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.streamConnectAttempt,
      properties: [
        {
          'stream_id': streamId,
          'is_host': isHost,
          'is_new_stream': isNewStream,
          're_join': reJoin,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          'is_copublisher': isCopublisher,
          'is_pk': isPk,
          'is_pk_guest': isPkGust,
          'hd_broadcast': hdBroadcast,
          'restream': restream,
          'defer_connection': deferConnection,
          'event_id': eventId,
          'is_scheduled_stream': isScheduledStream,
          'start_date_time': trackedStartDateTime ?? '',
        }
      ],
    );

    final hadExistingStreamDetails = _controller.streamDetails != null;
    _controller.streamDetails ??= stream ??
        IsmLiveStreamDataModel(
          streamDescription: streamDiscription,
          streamImage: streamImage,
          hdBroadcast: hdBroadcast,
          restream: restream,
          isScheduledStream: isScheduledStream,
          startDateTime: startTime,
          eventId: eventId,
          products: products ?? [],
        );
    if (hadExistingStreamDetails && startTime != null) {
      _controller.streamDetails =
          _controller.streamDetails?.copyWith(startDateTime: startTime);
    }

    // Reset callback trigger flag for new stream
    _controller._streamViewLoadedCallbackTriggered = false;

    // Set up background lifecycle management
    _controller.setStreamActive(true, isHost, isCopublisher: isCopublisher);

    // Show a loader while connecting
    _controller.isModerationWarningVisible = true;
    _controller.descriptionController.text =
        streamDiscription ?? _controller.descriptionController.text;

    _controller.pkStages = null;

    _controller.userRole =
        isHost ? IsmLiveUserRole.host() : IsmLiveUserRole.viewer();
    _controller.isViewerJoiningStream = !isHost;

    if (isCopublisher) {
      _controller.userRole?.makeCopublisher();
    } else {
      _controller.userRole?.leaveCopublishing();
    }
    if (isPk) {
      _controller.pkStages = IsmLivePkStages.isPk();
      if (isPkGust) {
        _controller.userRole?.makePkGuest();
      }
    }
    _controller.update([IsmGoLiveView.updateId]);

    // Add null safety check for MQTT controller
    try {
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.connectStreamMqttSubscribeAttempt,
        properties: [
          {
            'stream_id': streamId,
            'is_host': isHost,
            'uses_custom_subscribe_callback':
                IsmLiveDelegate.subscribStreamById != null,
            'is_copublisher': isCopublisher,
            'has_mqtt_controller': _controller._mqttController != null,
          }
        ],
      );
      if (IsmLiveDelegate.subscribStreamById != null) {
        IsmLiveDelegate.subscribStreamById!(streamId);
      } else {
        if (!isCopublisher && _controller._mqttController != null) {
          // Don't block join/start on MQTT topic subscription/reconnect.
          unawaited(_controller._mqttController?.subscribeStream(streamId));
        }
      }
    } catch (e) {
      IsmLiveLog.error('MQTT subscription error: $e');
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.connectStreamMqttSubscribeFailure,
        properties: [
          {
            'stream_id': streamId,
            'error': e.toString(),
          }
        ],
      );
    }

    // If we want a snappier transition for host-initiated streams,
    // defer the heavy LiveKit connection to `stream_view` and navigate now.
    if (deferConnection && !joinByScrolling) {
      _controller.pendingConnection = true;
      try {
        final dummyRoom = lk.Room();
        final dummyListener = dummyRoom.createListener();

        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.connectStreamDeferredNavigationAttempt,
          properties: [
            {
              'stream_id': streamId,
              'is_host': isHost,
              'is_new_stream': isNewStream,
              're_join': reJoin,
              'is_scrolling': isScrolling,
              'duration_ms':
                  DateTime.now().difference(startedAt).inMilliseconds,
            }
          ],
        );

        await IsmLiveRouteManagement.goToStreamView(
          isHost: isHost,
          isNewStream: isNewStream,
          room: dummyRoom,
          isScrolling: isScrolling,
          streamImage: streamImage,
          listener: dummyListener,
          streamId: streamId,
          isInteractive: isInteractive,
          reJoin: reJoin,
        );
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.connectStreamDeferredNavigationSuccess,
          properties: [
            {
              'stream_id': streamId,
              'duration_ms':
                  DateTime.now().difference(startedAt).inMilliseconds,
            }
          ],
        );
      } catch (e, st) {
        IsmLiveLog.error('Navigation error (deferred connect): $e', st);
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.connectStreamDeferredNavigationFailure,
          properties: [
            {
              'stream_id': streamId,
              'duration_ms':
                  DateTime.now().difference(startedAt).inMilliseconds,
              'error': e.toString(),
            }
          ],
        );
      }
      return;
    }

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.connectRoomAndInitializeAttempt,
      properties: [
        {
          'stream_id': streamId,
          'is_host': isHost,
          'is_new_stream': isNewStream,
          're_join': reJoin,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          'duration_ms': 0,
          'start_date_time': trackedStartDateTime ?? '',
        }
      ],
    );

    try {
      await _connectRoomAndInitialize(
        stream: stream,
        token: token,
        streamId: streamId,
        streamImage: streamImage,
        streamDiscription: streamDiscription,
        hdBroadcast: hdBroadcast,
        restream: restream,
        isHost: isHost,
        isCopublisher: isCopublisher,
        isPk: isPk,
        isPkGust: isPkGust,
        isNewStream: isNewStream,
        joinByScrolling: joinByScrolling,
        isScrolling: isScrolling,
        isInteractive: isInteractive,
        startTime: startTime,
        context: context,
        eventId: eventId,
        reJoin: reJoin,
        isScheduledStream: isScheduledStream,
        products: products,
        performNavigation: !joinByScrolling,
        showLoader: true,
      );
    } catch (e) {
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.connectRoomAndInitializeFailure,
        properties: [
          {
            'stream_id': streamId,
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': e.toString(),
          }
        ],
      );
      rethrow;
    }
  }

  /// Viewer-only: rejoin the currently open stream after app resumes.
  ///
  /// Why this exists:
  /// - When coming back from background, message/probe APIs may fail with 400
  ///   (viewer not considered a member). Reconnecting LiveKit with an old token
  ///   can also produce SDP order errors.
  /// - This method uses the existing `getRTCToken()` + `_connectRoomAndInitialize()`
  ///   flow to obtain a fresh token and rejoin without navigating.
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
          isPk: details?.isPkChallenge ?? false,
          isPkGust: false,
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
            'rejoinCurrentViewerStreamAfterForeground: source=$source connected=$connected state=${_controller.room?.connectionState}');
        return connected;
      }

      var existingToken = (_controller.rtcToken ?? '').trim();
      if (existingToken.isEmpty) {
        existingToken = (await _dbWrapper.getSecuredValue(streamId)).trim();
      }
      if (existingToken.isNotEmpty) {
        IsmLiveLog.info(
            'rejoinCurrentViewerStreamAfterForeground: attempting with existing RTC token for $streamId');
        try {
          final connected = await _attemptRejoinWithToken(
            token: existingToken,
            startTime: details?.startDateTime,
            source: 'existing_token',
          );
          if (connected) return true;
        } catch (e, st) {
          IsmLiveLog.error(
              'rejoinCurrentViewerStreamAfterForeground: existing RTC token rejoin failed, falling back to fresh token: $e',
              st);
        }
      } else {
        IsmLiveLog.info(
            'rejoinCurrentViewerStreamAfterForeground: existing RTC token unavailable, requesting fresh token for $streamId');
      }

      final rtc = await _controller.getRTCToken(streamId);
      if (rtc == null || rtc.rtcToken.trim().isEmpty) {
        IsmLiveLog.error(
            'rejoinCurrentViewerStreamAfterForeground: RTC token fetch failed');
        return false;
      }

      final token = rtc.rtcToken;

      // Keep token available for background lifecycle reconnection.
      _controller.rtcToken = token;
      _controller.storeToken(token);

      final connected = await _attemptRejoinWithToken(
        token: token,
        startTime: rtc.startTime ?? details?.startDateTime,
        source: 'fresh_token',
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
        // `_connectRoomAndInitialize` already ran `enableMyVideo()` — avoid a second
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

  Future<void> _connectRoomAndInitialize({
    IsmLiveStreamDataModel? stream,
    required String token,
    required String streamId,
    String? streamImage,
    String? streamDiscription,
    bool hdBroadcast = false,
    bool restream = false,
    required bool isHost,
    bool isCopublisher = false,
    bool isPk = false,
    bool isPkGust = false,
    required bool isNewStream,
    bool joinByScrolling = false,
    bool isScrolling = false,
    bool isInteractive = false,
    DateTime? startTime,
    required BuildContext context,
    String? eventId,
    bool reJoin = false,
    bool? isScheduledStream,
    List? products,
    required bool performNavigation,
    bool showLoader = true,
  }) async {
    final sw = Stopwatch()..start();
    var loaderShown = false;
    if (!joinByScrolling && showLoader) {
      // Show a generic loader; detailed user-facing message was already
      // computed in the calling method.
      IsmLiveUtility.showLoader();
      loaderShown = true;
    }

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.roomInitStart,
      properties: [
        {
          'stream_id': streamId,
          'event_id': eventId,
          'is_host': isHost,
          'is_new_stream': isNewStream,
          're_join': reJoin,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          'perform_navigation': performNavigation,
          'defer_loader': !showLoader,
        }
      ],
    );

    try {
      // Setting video presets based on the hdBroadcast param
      final resolvedVideoParams = _resolveLkVideoParams(
        hdBroadcast: hdBroadcast,
        restream: restream,
      );

      // First join: use app delegate default. Host/co-publisher rejoin (e.g. after
      // background): keep last camera facing so back camera isn’t reset to front.
      final lk.CameraPosition resolvedCameraPosition;
      final preserveCameraOnReconnect =
          reJoin && (isHost || isCopublisher || isPkGust);
      if (preserveCameraOnReconnect) {
        resolvedCameraPosition = _controller.position;
      } else {
        resolvedCameraPosition = (IsmLiveDelegate.initialCameraPositionStream ==
                IsmLiveCameraPosition.front)
            ? lk.CameraPosition.front
            : lk.CameraPosition.back;
        _controller.position = resolvedCameraPosition;
      }

      final previousRoom = _controller.room;
      // Listener is always bound to the previous room; drop it before disconnect.
      try {
        await _controller.listener?.dispose();
      } catch (e) {
        IsmLiveLog.error('Listener dispose error: $e');
      }
      _controller.listener = null;

      if (previousRoom != null) {
        try {
          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.previousRoomDisconnectAttempt,
            properties: [
              {
                'stream_id': streamId,
                're_join': reJoin,
              }
            ],
          );
          // Always await disconnect — not only when connectionState != disconnected.
          // If we skip this when the client already shows `disconnected`, the server
          // can still hold the participant and the next `connect` with the same
          // host token hits `DisconnectReason.duplicateIdentity` (camera drops
          // ~1s later when the server kicks the duplicate session).
          await previousRoom.disconnect();
        } catch (e) {
          IsmLiveLog.error('Previous room disconnect error: $e');
        }
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.previousRoomDisconnectDone,
          properties: [
            {
              'stream_id': streamId,
              'duration_ms': sw.elapsedMilliseconds,
            }
          ],
        );
        // Same-token rejoins (host) need a beat for the SFU to release identity.
        await Future.delayed(
          reJoin
              ? const Duration(milliseconds: 900)
              : const Duration(milliseconds: 400),
        );
      }

      lk.Room buildConfiguredRoom() => lk.Room(
            roomOptions: lk.RoomOptions(
              defaultCameraCaptureOptions: lk.CameraCaptureOptions(
                cameraPosition: resolvedCameraPosition,
                params: resolvedVideoParams,
              ),
              defaultAudioCaptureOptions: const lk.AudioCaptureOptions(
                noiseSuppression: true,
                echoCancellation: true,
                autoGainControl: true,
                highPassFilter: true,
                typingNoiseDetection: true,
              ),
              defaultVideoPublishOptions: lk.VideoPublishOptions(
                videoEncoding: resolvedVideoParams.encoding,
              ),
              defaultAudioPublishOptions: const lk.AudioPublishOptions(
                dtx: true,
              ),
              // SFU still fans out to many viewers; these client flags help per-device
              // CPU/bandwidth. Without adaptiveStream, remote video defaults to HIGH for
              // every subscriber (see livekit_client RemoteTrackPublication defaults).
              adaptiveStream: true,
              // Reduces publisher encode work for simulcast layers no subscriber needs.
              dynacast: true,
            ),
          );

      var room = buildConfiguredRoom();
      _controller.room = room;
      IsmLiveLog.info('Joining streamId(roomId): $streamId');

      // Create a listener before connecting.
      _controller.listener = room.createListener();

      // Pre-connect guard: if the stream was disposed while we were setting
      // up (e.g. viewer closed the view during the previous-room disconnect
      // delay), abort before the expensive room.connect() call. Without this,
      // the room would connect, start receiving remote audio, and the viewer
      // would hear the streamer even after leaving the view.
      if (_controller.streamId == null || _controller.streamId != streamId) {
        IsmLiveLog.info(
            'Stream disposed during room setup for $streamId, aborting connection');
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.preconnectAbortedStreamDisposed,
          properties: [
            {
              'stream_id': streamId,
              'current_stream_id': _controller.streamId ?? '',
              'duration_ms': sw.elapsedMilliseconds,
            }
          ],
        );
        try {
          _controller.listener?.dispose();
        } catch (_) {}
        _controller.listener = null;
        _controller.room = null;
        _controller.isViewerJoiningStream = false;
        if (loaderShown) {
          IsmLiveUtility.closeLoader();
        }
        return;
      }

      // Try to connect with one guarded retry for transport timeouts.
      // Rarely, socket/ICE setup can timeout in production and a fresh room
      // instance resolves it without requiring the user to manually re-enter.
      var connectAttempt = 1;
      while (true) {
        try {
          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.roomConnectAttempt,
            properties: [
              {
                'stream_id': streamId,
                'duration_ms': sw.elapsedMilliseconds,
                'attempt': connectAttempt,
              }
            ],
          );
          await room.connect(IsmLiveApis.wsUrl, token);
          break;
        } catch (e, st) {
          final isTimeoutError = e is TimeoutException ||
              e.toString().contains('TimeoutException');
          final canRetry = isTimeoutError &&
              connectAttempt == 1 &&
              _controller.streamId == streamId;

          IsmLiveLog.error(
              'Room connection error(attempt=$connectAttempt): $e', st);
          _controller.isViewerJoiningStream = false;

          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.roomConnectFailure,
            properties: [
              {
                'stream_id': streamId,
                'duration_ms': sw.elapsedMilliseconds,
                'error': e.toString(),
                'attempt': connectAttempt,
                'will_retry': canRetry,
              }
            ],
          );

          // Release failed room resources (WebSocket, ICE agents, etc.).
          try {
            await room.disconnect();
          } catch (_) {}

          if (!canRetry) {
            if (loaderShown) {
              IsmLiveUtility.closeLoader();
              loaderShown = false;
            }
            return;
          }

          try {
            await _controller.listener?.dispose();
          } catch (_) {}
          _controller.listener = null;

          // Brief cool-off gives backend/client transport state time to settle.
          await Future.delayed(const Duration(milliseconds: 1200));

          if (_controller.streamId != streamId) {
            if (loaderShown) {
              IsmLiveUtility.closeLoader();
              loaderShown = false;
            }
            return;
          }

          connectAttempt++;
          room = buildConfiguredRoom();
          _controller.room = room;
          _controller.listener = room.createListener();
        }
      }

      // Stale connection guard: if the user scrolled to a different stream
      // while ICE negotiation was in progress, discard this connection so
      // we don't overwrite state belonging to the newer stream.
      if (_controller.streamId != streamId) {
        IsmLiveLog.info(
            'Discarding stale connection for $streamId (current: ${_controller.streamId})');
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.roomConnectDiscardedStale,
          properties: [
            {
              'stream_id': streamId,
              'current_stream_id': _controller.streamId ?? '',
              'duration_ms': sw.elapsedMilliseconds,
            }
          ],
        );
        try {
          await room.disconnect();
        } catch (_) {}
        _controller.isViewerJoiningStream = false;
        if (loaderShown) {
          IsmLiveUtility.closeLoader();
        }
        return;
      }

      if (!isHost) {
        _controller.isViewerJoiningStream = false;
      }

      if (!isHost) {
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.streamJoin,
          properties: [
            {
              'stream_id': streamId,
              'event_id': eventId ?? stream?.eventId ?? '',
              'stream_description': stream?.streamDescription ??
                  _controller.streamDetails?.streamDescription ??
                  '',
              'start_date_time': (stream?.startDateTime ??
                          _controller.streamDetails?.startDateTime)
                      ?.toIso8601String() ??
                  '',
              'is_scheduled_stream': stream?.isScheduledStream ??
                  _controller.streamDetails?.isScheduledStream ??
                  false,
              'initiator_user_id': _controller.user?.userId ?? '',
              'initiator_user_name':
                  _controller.user?.userName ?? _controller.user?.name ?? '',
              'user_id': stream?.userId ??
                  stream?.userDetails?.id ??
                  _controller.streamDetails?.userId ??
                  _controller.streamDetails?.userDetails?.id ??
                  '',
              'user_name': stream?.userDetails?.userName ??
                  stream?.userDetails?.name ??
                  _controller.streamDetails?.userDetails?.userName ??
                  _controller.streamDetails?.userDetails?.name ??
                  '',
            }
          ],
        );
      }
      if (isHost && isNewStream) {
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.streamStarted,
          properties: [
            {
              'stream_id': streamId,
              'event_id': eventId ?? '',
              'is_scheduled_stream': isScheduledStream ?? false,
              'user_id': _controller.user?.userId ?? '',
              'user_name':
                  _controller.user?.userName ?? _controller.user?.name ?? '',
            }
          ],
        );
      }

      // Route audio to the loudspeaker. Mobile WebRTC defaults to the
      // earpiece; live-stream participants expect loudspeaker output.
      // The helper respects external devices (Bluetooth/wired) on Android.
      // withRetry: true schedules retries to guard against WebRTC resetting
      // the audio route when remote tracks arrive.
      await _ensureLoudspeakerRouting(withRetry: true, forRoom: room);

      // Store the token for background lifecycle reconnection
      _controller.storeToken(token);

      // Set track subscription permissions
      try {
        room.localParticipant?.setTrackSubscriptionPermissions(
          allParticipantsAllowed: true,
          trackPermissions: [
            const lk.ParticipantTrackPermission(
              'allowed-identity',
              true,
              null,
            ),
          ],
        );
      } catch (e) {
        IsmLiveLog.error('Track subscription permissions error: $e');
      }

      // Enable video if the user is a host or copublisher
      if (!_controller.isRtmp) {
        try {
          if (isHost || isCopublisher || isPkGust) {
            await enableMyVideo();
          }
          // Toggle audio if the user is a host or copublisher
          unawaited(
            _controller.toggleAudio(
              value: isHost || isCopublisher,
            ),
          );
        } catch (e) {
          IsmLiveLog.error('Video/Audio enable error: $e');
        }
      }

      // iOS audio-session fix for viewer → copublisher promotion:
      // After disconnect→reconnect the AVAudioSession can remain in
      // playback-only mode. We post synthetic AVAudioSession interruption
      // notifications (began → ended/shouldResume) which is exactly what
      // iOS does on background→foreground — forcing WebRTC's RTCAudioSession
      // to tear down and rebuild its audio unit with playAndRecord.
      if (Platform.isIOS && isCopublisher) {
        unawaited(Future.delayed(
          const Duration(milliseconds: 1200),
          () async {
            if (_controller.room?.connectionState !=
                lk.ConnectionState.connected) {
              return;
            }
            try {
              await _controller._liveStreamBridge.reactivateAudioSession();
              // Re-apply speaker routing after the interruption cycle
              // completes (~300ms internal delay in native side).
              await Future.delayed(const Duration(milliseconds: 500));
              if (_controller.room?.connectionState ==
                  lk.ConnectionState.connected) {
                lk.Hardware.instance.setSpeakerphoneOn(true);
              }
            } catch (e) {
              IsmLiveLog.error('iOS audio session reactivation error: $e');
            }
          },
        ));
      }

      if (loaderShown) {
        IsmLiveUtility.closeLoader();
        loaderShown = false;
      }

      // Wrap API calls in try-catch
      try {
        unawaited(Future.wait([
          _controller.getStreamMembers(
            streamId: streamId,
            limit: 10,
            skip: 0,
          ),
          _controller.getStreamViewer(
            streamId: streamId,
            limit: 10,
            skip: 0,
          ),
        ]));
      } catch (e) {
        IsmLiveLog.error('Stream members/viewer fetch error: $e');
      }

      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.postConnectApiKickoff,
        properties: [
          {
            'stream_id': streamId,
            'is_host': isHost,
            'duration_ms': sw.elapsedMilliseconds,
          }
        ],
      );

      try {
        _controller.initializeStream(
          streamId: streamId,
          isHost: isHost,
        );
      } catch (e) {
        IsmLiveLog.error('Stream initialization error: $e');
      }

      // Initialize timer if not already set (for direct connectStream calls)
      if (startTime != null) {
        _controller._streamStartTime = startTime;
      }

      startStreamTimer();

      if (performNavigation) {
        try {
          IsmLiveGifts.threeD.map((e) => IsmLiveGif.preCache(e.path, context));
          IsmLiveGifts.animated
              .map((e) => IsmLiveGif.preCache(e.path, context));
        } catch (e) {
          IsmLiveLog.error('Gift pre-cache error: $e');
        }
        try {
          // Check if listener is null before calling goToStreamView
          if (_controller.listener == null) {
            IsmLiveLog.error('Cannot join stream: listener is null');
            return;
          }

          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.goToStreamViewAttempt,
            properties: [
              {
                'stream_id': streamId,
                'is_host': isHost,
                're_join': reJoin,
                'duration_ms': sw.elapsedMilliseconds,
              }
            ],
          );

          await IsmLiveRouteManagement.goToStreamView(
              isHost: isHost,
              isNewStream: isNewStream,
              room: room,
              isScrolling: isScrolling,
              streamImage: streamImage,
              listener: _controller.listener!,
              streamId: streamId,
              isInteractive: isInteractive,
              reJoin: reJoin);

          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.goToStreamViewSuccess,
            properties: [
              {
                'stream_id': streamId,
                'duration_ms': sw.elapsedMilliseconds,
              }
            ],
          );
        } catch (e) {
          IsmLiveLog.error('Navigation error: $e');
          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.goToStreamViewFailure,
            properties: [
              {
                'stream_id': streamId,
                'duration_ms': sw.elapsedMilliseconds,
                'error': e.toString(),
              }
            ],
          );
        }
      }
    } catch (e, st) {
      _controller.isViewerJoiningStream = false;
      try {
        unawaited(
          _controller._mqttController?.unsubscribeStream(
            streamId,
          ),
        );
      } catch (unsubError) {
        IsmLiveLog.error('Unsubscribe error: $unsubError');
      }
      _controller.userRole = null;
      IsmLiveLog.error('ConnectStream error: $e', st);
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.connectFlowOuterFailure,
        properties: [
          {
            'stream_id': streamId,
            'duration_ms': sw.elapsedMilliseconds,
            'error': e.toString(),
          }
        ],
      );
    } finally {
      sw.stop();
      if (loaderShown) {
        IsmLiveUtility.closeLoader();
      }
    }
  }

  /// Completes a previously deferred LiveKit connection from `stream_view`.
  Future<void> completeDeferredConnection({
    required BuildContext context,
    required bool isHost,
    required bool isNewStream,
    required bool isInteractive,
    required bool isSchedule,
  }) async {
    if (!_controller.pendingConnection ||
        _controller.rtcToken == null ||
        _controller.streamId == null) {
      return;
    }

    final token = _controller.rtcToken!;
    final streamId = _controller.streamId!;
    final details = _controller.streamDetails;

    final streamImage = details?.streamImage;
    final streamDiscription =
        details?.streamDescription ?? _controller.descriptionController.text;
    final hdBroadcast = details?.hdBroadcast ?? _controller.isHdBroadcast;
    final restream = details?.restream ?? _controller.isRestreamBroadcast;

    // Capture the flag early. If onStreamScroll clears pendingConnection
    // while _connectRoomAndInitialize is awaiting room.connect(), the stale
    // connection guard inside _connectRoomAndInitialize will detect the
    // streamId mismatch and discard the connection automatically.
    _controller.pendingConnection = false;

    await _connectRoomAndInitialize(
      stream: details,
      token: token,
      streamId: streamId,
      streamImage: streamImage,
      streamDiscription: streamDiscription,
      hdBroadcast: hdBroadcast,
      restream: restream,
      isHost: isHost,
      isCopublisher: false,
      isPk: details?.isPkChallenge ?? false,
      isPkGust: false,
      isNewStream: isNewStream,
      joinByScrolling: false,
      isScrolling: false,
      isInteractive: isInteractive,
      startTime: details?.startDateTime,
      context: context,
      eventId: details?.eventId,
      reJoin: false,
      isScheduledStream: details?.isScheduledStream ?? isSchedule,
      products: details?.products,
      performNavigation: false,
      showLoader: false,
    );
  }

  Future<IsmLiveScheduleRTCModule?> goLiveSchedule() async {
    var payload = IsmLiveScheduleStreamParam(
      audioOnly: _controller.streamDetails?.audioOnly,
      enableRecording: _controller.streamDetails?.isRecorded,
      eventId: _controller.streamDetails?.eventId,
      hdBroadcast: _controller.streamDetails?.hdBroadcast,
      isPaid: _controller.streamDetails?.isPaid,
      isPublicStream: _controller.streamDetails?.isPublicStream,
      isSelfHosted: true,
      isometrikUserId: _controller.streamDetails?.userId,
      lowLatencyMode: true,
      members: _controller.streamDetails?.members,
      multiLive: true,
      paymentAmount: _controller.streamDetails?.paymentAmount,
      paymentCurrencyCode: _controller.streamDetails?.paymentCurrencyCode,
      persistRtmpIngestEndpoint:
          _controller.streamDetails?.persistRtmpIngestEndpoint,
      products: _controller.streamDetails?.products,
      productsLinked: _controller.streamDetails?.productsLinked,
      restream: _controller.streamDetails?.restream,
      rtmpIngest: _controller.streamDetails?.rtmpIngest,
      saleType: 1,
      streamDescription: _controller.streamDetails?.streamDescription,
      streamImage: _controller.streamDetails?.streamImage,
      streamTitle: (_controller.streamDetails?.streamTitle?.isEmpty ?? true)
          ? 'My stream'
          : _controller.streamDetails?.streamTitle,
      userName: _controller.streamDetails?.userDetails?.userName,
    );
    return await _controller.goliveScheduleStream(payload);
  }

  void startSeduleStream(
    IsmLiveStreamDataModel stream, {
    bool isHost = true,
    bool isScrolling = false,
    bool joinByScrolling = false,
  }) {
    _controller._streamViewLoadedCallbackTriggered = false;
    _controller.userRole =
        isHost ? IsmLiveUserRole.host() : IsmLiveUserRole.viewer();
    var details = stream.userDetails;

    _controller.streamDetails = stream;

    _controller.descriptionController.text =
        stream.streamDescription ?? _controller.descriptionController.text;

    _controller.hostDetails = IsmLiveMemberDetailsModel(
        isAdmin: false,
        isPublishing: false,
        joinTime: 0,
        metaData: details?.userMetaData ?? const IsmLiveMetaData(),
        userId: details?.id ?? '',
        userIdentifier: details?.appUserId ?? '',
        userName: details?.userName ?? '',
        userProfileImageUrl: details?.userProfile ?? '');

    // Scheduled "not started yet" preview does not join LiveKit. Do not stash a
    // placeholder Room on the controller: `completeDeferredConnection` awaits
    // `previousRoom.disconnect()`, and disconnect() on a never-connected Room can
    // block ~10s (SDK timeout)—the main slowdown when hosting a scheduled go-live.
    _controller.room = null;
    if (!joinByScrolling) {
      final previewRoom = lk.Room();
      IsmLiveRouteManagement.goToStreamView(
        isHost: isHost,
        isNewStream: false,
        room: previewRoom,
        isScrolling: isScrolling,
        streamImage: stream.streamImage,
        listener: previewRoom.createListener(),
        streamId: stream.streamId ?? '',
        isSchedule: true,
        reJoin: false, // This is for scheduled streams, not rejoin
      );
    }

    IsmLiveUtility.updateLater(() {
      // Trigger stream view loaded callback for scheduled streams (only once per stream)
      if (!_controller._streamViewLoadedCallbackTriggered) {
        _controller._streamViewLoadedCallbackTriggered = true;
        IsmLiveDelegate.streamViewLoadedCallback?.call(
          _controller.isHost,
          _controller.hostDetails,
          stream,
        );
      }
    }, true);
  }

  void editScheduleStream(BuildContext context) async {
    String? image;
    if (_controller.streamDetails?.streamImage?.isEmpty ?? true) {
      if (_controller.pickedImage == null) {
        final file = await _controller.cameraController?.takePicture();
        if (file != null) {
          _controller.pickedImage = file;
          _controller.update([IsmGoLiveView.updateId]);
        } else {
          var file = await FileManager.pickGalleryImage();
          if (file != null) {
            _controller.pickedImage = file;
            _controller.update([IsmGoLiveView.updateId]);
          }
        }
      }

      var bytes = File(_controller.pickedImage!.path).readAsBytesSync();
      var type = _controller.pickedImage!.name.split('.').last;
      image = await _controller.uploadImage(type, bytes, context);
    }

    var res = await _controller.editScheduledStream(
      eventId: _controller.streamDetails?.eventId ?? '',
      streamImage: image ?? _controller.streamDetails?.streamImage,
      streamDescription: _controller.descriptionController.text.trim(),
    );
    _controller.streamDetails = null;
    if (res) {
      IsmLiveUtility.showCustomDialog(
        IsmLiveEditScheduleDialog(
          message:
              _controller.streamDetails?.scheduleStartTime ?? DateTime.now(),
        ),
      );
    }
  }

  void startStreamTimer() {
    if (_controller.streamTimer != null) {
      return;
    }

    // Calculate the accurate duration just before starting the timer
    if (_controller._streamStartTime != null) {
      var now = DateTime.now();
      _controller.streamDuration =
          now.difference(_controller._streamStartTime!);
    } else {
      _controller.streamDuration = Duration.zero;
    }

    _controller.streamTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        try {
          if (_controller._streamStartTime != null) {
            // Use wall-clock elapsed time so app background pauses (notably iOS)
            // don't freeze the stream timer.
            final elapsed =
                DateTime.now().difference(_controller._streamStartTime!);
            _controller.streamDuration =
                elapsed.isNegative ? Duration.zero : elapsed;
          } else {
            _controller.streamDuration += const Duration(
              seconds: 1,
            );
          }
          final currentStreamId = _controller.streamId;
          final currentSeconds = _controller.streamDuration.inSeconds;
          if (currentStreamId != null &&
              currentStreamId.isNotEmpty &&
              currentSeconds > 0 &&
              currentSeconds % 30 == 0) {
            final isHost = _controller.isHost;
            if (_controller._lastHeartbeatStreamId == currentStreamId &&
                _controller._lastHeartbeatSecondEmitted == currentSeconds) {
              return;
            }
            _controller._lastHeartbeatStreamId = currentStreamId;
            _controller._lastHeartbeatSecondEmitted = currentSeconds;
            IsmLiveDelegate.trackEvent(
              IsmLiveAnalyticsEvent.streamHeartbeat,
              properties: [
                {
                  'stream_id': currentStreamId,
                  'watch_duration_seconds': currentSeconds,
                  'is_host': isHost,
                  'participant_role': isHost ? 'host' : 'viewer',
                  'user_id': _controller.user?.userId ?? '',
                  'user_name': _controller.user?.userName ??
                      _controller.user?.name ??
                      '',
                }
              ],
            );
          }
        } catch (e) {
          IsmLiveLog.error('Stream timer tick error: $e');
          timer.cancel(); // Stops the timer permanently
          return;
        }
      },
    );
  }
}
