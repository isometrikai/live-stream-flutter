part of '../stream_controller.dart';

// Go-live camera setup and local A/V track management.
mixin StreamJoinCameraMixin on StreamJoinMixin {
  static const IsmLiveVideoEffectPreset _defaultVideoEffectPreset =
      IsmLiveVideoEffectPreset.none;
  static const double _defaultVideoEffectsBlurPower = 0.7;
  static const double _defaultVideoEffectsBeautificationPower = 1.0;
  static const double _defaultVideoEffectsSharpeningStrength = 0.8;
  static const double _defaultVideoEffectsColorFilterStrength = 0.5;
  static const double _defaultVideoEffectsLowLightStrength = 0.7;
  static const double _defaultVideoEffectsSmartZoomLevel = 0.5;

  IsmLiveVideoEffectsConfig get _videoEffectsConfig =>
      IsmLiveDelegate.goLiveScreenConfigure?.videoEffectsConfig ??
      const IsmLiveVideoEffectsConfig();

  String? _resolvedVideoEffectsCustomerId() {
    final config = _videoEffectsConfig;
    final customerId = config.customerId?.trim();
    if (!config.isEnabled) return null;
    if (customerId == null || customerId.isEmpty) {
      IsmLiveLog.error(
        'Video effects are enabled, but customerId is missing. Falling back to normal camera capture.',
      );
      return null;
    }
    return customerId;
  }

  lk.CameraCaptureOptions _buildCameraCaptureOptions(
    lk.VideoParameters captureParams,
    lk.CameraPosition resolvedCameraPosition,
  ) {
    final customerId = _resolvedVideoEffectsCustomerId();
    if (customerId != null) {
      lk.VideoEffectsSDKExt.initialize(customerId);
    }
    return lk.CameraCaptureOptions(
      cameraPosition: resolvedCameraPosition,
      params: captureParams,
      effectsSdkRequired: customerId != null,
    );
  }

  String labelForVideoEffectPreset(IsmLiveVideoEffectPreset preset) {
    switch (preset) {
      case IsmLiveVideoEffectPreset.none:
        return 'Off';
      case IsmLiveVideoEffectPreset.blur:
        return 'Blur';
      case IsmLiveVideoEffectPreset.backgroundReplace:
        return 'Background Replace';
      case IsmLiveVideoEffectPreset.beautification:
        return 'Beautification';
      case IsmLiveVideoEffectPreset.sharpening:
        return 'Sharpening';
      case IsmLiveVideoEffectPreset.lowLight:
        return 'Low Light';
      case IsmLiveVideoEffectPreset.colorCorrection:
        return 'Color Correction';
      case IsmLiveVideoEffectPreset.smartZoom:
        return 'Smart Zoom';
    }
  }

  IconData iconForVideoEffectPreset(IsmLiveVideoEffectPreset preset) {
    switch (preset) {
      case IsmLiveVideoEffectPreset.none:
        return Icons.block;
      case IsmLiveVideoEffectPreset.blur:
        return Icons.blur_on;
      case IsmLiveVideoEffectPreset.backgroundReplace:
        return Icons.wallpaper;
      case IsmLiveVideoEffectPreset.beautification:
        return Icons.face_retouching_natural;
      case IsmLiveVideoEffectPreset.sharpening:
        return Icons.details;
      case IsmLiveVideoEffectPreset.lowLight:
        return Icons.wb_twilight;
      case IsmLiveVideoEffectPreset.colorCorrection:
        return Icons.palette_outlined;
      case IsmLiveVideoEffectPreset.smartZoom:
        return Icons.zoom_in;
    }
  }

  Future<bool> _authenticateVideoEffectsIfNeeded(
      lk.LocalVideoTrack track) async {
    final customerId = _resolvedVideoEffectsCustomerId();
    if (customerId == null) return false;
    if (kIsWeb) {
      _controller.videoEffectsAuthenticated = true;
      return true;
    }
    if (_controller.videoEffectsAuthenticated) return true;

    try {
      final status = await track.auth(customerId);
      if (status != webrtc.AuthStatus.active) {
        IsmLiveLog.error('Video effects auth failed with status: $status');
        return false;
      }
      _controller.videoEffectsAuthenticated = true;
      return true;
    } catch (e) {
      IsmLiveLog.error('Video effects auth failed: $e');
      return false;
    }
  }

  Future<webrtc.EffectsSdkImage> _defaultBackgroundReplaceImage() async {
    final data = await rootBundle.load(
      'packages/${IsmLiveConstants.packageName}/${IsmLiveAssetConstants.videoEffectBackground}',
    );
    return webrtc.EffectsSdkImage.fromEncoded(data.buffer.asUint8List());
  }

  Future<void> _disableVideoEffectPreset(
    lk.LocalVideoTrack track,
    IsmLiveVideoEffectPreset preset,
  ) async {
    switch (preset) {
      case IsmLiveVideoEffectPreset.none:
        return;
      case IsmLiveVideoEffectPreset.blur:
      case IsmLiveVideoEffectPreset.backgroundReplace:
        await track.setPipelineMode(webrtc.PipelineMode.noEffects);
      case IsmLiveVideoEffectPreset.beautification:
        await track.enableBeautification(false);
      case IsmLiveVideoEffectPreset.sharpening:
        await track.enableSharpening(false);
      case IsmLiveVideoEffectPreset.lowLight:
      case IsmLiveVideoEffectPreset.colorCorrection:
        await track.setColorCorrectionMode(
          webrtc.ColorCorrectionMode.noFilterMode,
        );
        await track.setColorFilterStrength(0);
      case IsmLiveVideoEffectPreset.smartZoom:
        await track.setZoomLevel(0);
    }
  }

  Future<void> _enableVideoEffectPreset(
    lk.LocalVideoTrack track,
    IsmLiveVideoEffectPreset preset,
  ) async {
    switch (preset) {
      case IsmLiveVideoEffectPreset.none:
        return;
      case IsmLiveVideoEffectPreset.blur:
        await track.setPipelineMode(webrtc.PipelineMode.blur);
        await track.setBlurPower(_defaultVideoEffectsBlurPower);
      case IsmLiveVideoEffectPreset.backgroundReplace:
        await track.setPipelineMode(webrtc.PipelineMode.replace);
        await track.setBackgroundImage(await _defaultBackgroundReplaceImage());
      case IsmLiveVideoEffectPreset.beautification:
        await track.enableBeautification(true);
        await track.setBeautificationPower(
          _defaultVideoEffectsBeautificationPower,
        );
      case IsmLiveVideoEffectPreset.sharpening:
        await track.enableSharpening(true);
        await track.setSharpeningStrength(
          _defaultVideoEffectsSharpeningStrength,
        );
      case IsmLiveVideoEffectPreset.lowLight:
        await track.setColorCorrectionMode(
          webrtc.ColorCorrectionMode.lowLightMode,
        );
        await track.setColorFilterStrength(
          _defaultVideoEffectsLowLightStrength,
        );
      case IsmLiveVideoEffectPreset.colorCorrection:
        await track.setColorCorrectionMode(
          webrtc.ColorCorrectionMode.colorCorrectionMode,
        );
        await track.setColorFilterStrength(
          _defaultVideoEffectsColorFilterStrength,
        );
      case IsmLiveVideoEffectPreset.smartZoom:
        await track.setZoomLevel(_defaultVideoEffectsSmartZoomLevel);
    }
  }

  Future<void> _applyDefaultVideoEffectsIfNeeded(
    lk.LocalVideoTrack track,
  ) async {
    final isReady = await _authenticateVideoEffectsIfNeeded(track);
    if (!isReady) return;
    try {
      await _enableVideoEffectPreset(
        track,
        _controller.selectedVideoEffectPreset,
      );
    } catch (e) {
      IsmLiveLog.error(
        'Applying default video effect ${_controller.currentVideoEffectLabel} failed: $e',
      );
    }
  }

  Future<void> selectVideoEffectPreset(
    IsmLiveVideoEffectPreset preset,
  ) async {
    final customerId = _resolvedVideoEffectsCustomerId();
    if (customerId == null) return;
    if (_controller.isApplyingVideoEffect) return;
    if (_controller.selectedVideoEffectPreset == preset) return;

    final participant = _controller.room?.localParticipant;
    final track =
        participant?.getTrackPublicationBySource(lk.TrackSource.camera)?.track;

    // Go Live / pre-publish: store the choice only. It is applied when the
    // LiveKit camera track is created at stream start.
    if (track is! lk.LocalVideoTrack) {
      _controller.selectedVideoEffectPreset = preset;
      _controller.update([
        IsmGoLiveView.updateId,
        IsmLiveControlsWidget.updateId,
        IsmLiveVideoEffectsSheet.updateId,
      ]);
      return;
    }

    final previousPreset = _controller.selectedVideoEffectPreset;
    _controller.isApplyingVideoEffect = true;
    _controller.selectedVideoEffectPreset = preset;
    _controller.update([
      IsmLiveControlsWidget.updateId,
      IsmLiveVideoEffectsSheet.updateId,
    ]);

    try {
      final isReady = await _authenticateVideoEffectsIfNeeded(track);
      if (!isReady) {
        throw StateError('Video effects auth is not active');
      }
      // Differential update only — full reset races CameraX/ImageReader and
      // crashes after a few rapid switches.
      await _disableVideoEffectPreset(track, previousPreset);
      await _enableVideoEffectPreset(track, preset);
    } catch (e) {
      IsmLiveLog.error('Selecting video effect $preset failed: $e');
      _controller.selectedVideoEffectPreset = previousPreset;
      try {
        await _enableVideoEffectPreset(track, previousPreset);
      } catch (_) {}
    } finally {
      _controller.isApplyingVideoEffect = false;
      _controller.update([
        IsmLiveControlsWidget.updateId,
        IsmLiveVideoEffectsSheet.updateId,
      ]);
    }
  }

  Future<void> _setupPublishedCameraEffectsIfNeeded(
    lk.LocalParticipant participant,
  ) async {
    // Fresh track needs a fresh auth session.
    _controller.videoEffectsAuthenticated = false;
    final track =
        participant.getTrackPublicationBySource(lk.TrackSource.camera)?.track;
    if (track is! lk.LocalVideoTrack) return;
    await _applyDefaultVideoEffectsIfNeeded(track);
  }

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
      await _controller.cameraController?.dispose();
      _controller.cameraController = null;
      _controller.cameraFuture = null;
    }
  }

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
      final captureOptions = _buildCameraCaptureOptions(
        captureParams,
        resolvedCameraPosition,
      );

      final tracks = await Future.wait([
        lk.LocalVideoTrack.createCameraTrack(captureOptions),
        lk.LocalAudioTrack.create(),
      ]);
      var localVideo = tracks[0] as lk.LocalVideoTrack;
      var localAudio = tracks[1] as lk.LocalAudioTrack;

      _controller.videoEffectsAuthenticated = false;
      await _applyDefaultVideoEffectsIfNeeded(localVideo);

      await Future.wait<dynamic>([
        _controller.room!.localParticipant!.publishVideoTrack(localVideo),
        _controller.room!.localParticipant!.publishAudioTrack(localAudio),
      ]);
      // Keep UI flag in sync so settings / sync helpers donâ€™t think video is off
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
  /// Used when the host backgrounds with video â€œoffâ€: `setCameraEnabled(false)`
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
      await _setupPublishedCameraEffectsIfNeeded(participant);
      await _syncPublishedCameraToControllerPosition(participant);
      _controller.update();
    } catch (error) {
      // After a full rejoin, `enableMyVideo()` may already publish camera; a second
      // `setCameraEnabled(true)` can throw. Donâ€™t force UI/video off if track exists.
      final pub =
          participant.getTrackPublicationBySource(lk.TrackSource.camera);
      final trackAlive = pub?.track != null;
      if (trackAlive) {
        IsmLiveLog.info(
            'resumeHostCameraAfterBackground: setCameraEnabled failed but camera track still present: $error');
        _controller.videoOn = true;
        await _setupPublishedCameraEffectsIfNeeded(participant);
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
}
