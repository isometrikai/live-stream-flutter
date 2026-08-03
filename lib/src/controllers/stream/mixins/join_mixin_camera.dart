part of '../stream_controller.dart';

// Go-live camera setup and local A/V track management.
mixin StreamJoinCameraMixin on StreamJoinMixin {
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

  Future<void> enableMyVideo() async {
    if (_controller.room == null) {
      return;
    }

    try {
      // Ensure the Camera plugin controller is released before WebRTC / DeepAR
      // opens the camera.
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

      final resolvedCameraPosition = _controller.position;
      final useDeepAr = IsmLiveDeepArPublisher.shouldUse(
        IsmLiveDelegate.deepArConfig,
      );

      late final lk.LocalVideoTrack localVideo;
      late final lk.LocalAudioTrack localAudio;

      if (useDeepAr) {
        try {
          await _controller.deepArPublisher?.stop();
          final publisher =
              IsmLiveDeepArPublisher(IsmLiveDelegate.deepArConfig);
          _controller.deepArPublisher = publisher;
          localVideo = await publisher.start(
            frontCamera:
                resolvedCameraPosition == lk.CameraPosition.front,
            params: captureParams,
          );
          // Apply UI-selected effect if any.
          IsmLiveDeepArEffect? selected;
          for (final e in IsmLiveDelegate.deepArConfig.effects) {
            if (e.id == _controller.selectedDeepArEffectId) {
              selected = e;
              break;
            }
          }
          if (selected != null) {
            await publisher.applyEffect(selected);
          }
          localAudio = await lk.LocalAudioTrack.create();
        } catch (e) {
          IsmLiveLog.error(
            'DeepAR publish failed, falling back to LiveKit camera: $e',
          );
          await _controller.deepArPublisher?.stop();
          _controller.deepArPublisher = null;
          final tracks = await Future.wait([
            lk.LocalVideoTrack.createCameraTrack(
              lk.CameraCaptureOptions(
                cameraPosition: resolvedCameraPosition,
                params: captureParams,
              ),
            ),
            lk.LocalAudioTrack.create(),
          ]);
          localVideo = tracks[0] as lk.LocalVideoTrack;
          localAudio = tracks[1] as lk.LocalAudioTrack;
        }
      } else {
        final tracks = await Future.wait([
          lk.LocalVideoTrack.createCameraTrack(
            lk.CameraCaptureOptions(
              cameraPosition: resolvedCameraPosition,
              params: captureParams,
            ),
          ),
          lk.LocalAudioTrack.create(),
        ]);
        localVideo = tracks[0] as lk.LocalVideoTrack;
        localAudio = tracks[1] as lk.LocalAudioTrack;
      }

      await Future.wait<dynamic>([
        _controller.room!.localParticipant!.publishVideoTrack(localVideo),
        _controller.room!.localParticipant!.publishAudioTrack(localAudio),
      ]);
      _controller.videoOn = true;
      _controller.audioOn = true;
    } catch (e) {
      IsmLiveLog.error('enableMyVideo error: $e');
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