part of '../stream_controller.dart';

mixin StreamJoinMixin {
  IsmLiveStreamController get _controller => Get.find<IsmLiveStreamController>();

  bool isMeetingOn = false;

  Future<void> joinStream(
    IsmLiveStreamModel stream,
  ) async {
    var data = await _controller.getRTCToken(stream.streamId ?? '');
    if (data == null) {
      return;
    }
    var now = DateTime.now();
    _controller.streamDuration = now.difference(stream.startTime ?? now);

    IsmLiveLog.success(_controller.streamDuration);

    await connectStream(
      token: data.rtcToken,
      streamId: stream.streamId!,
      isHost: false,
    );
  }

  Future<void> startStream() async {
    var data = await _controller.createStream();
    if (data == null) {
      return;
    }
    _controller.streamDuration = Duration.zero;

    await connectStream(
      token: data.rtcToken,
      streamId: data.streamId!,
      isHost: true,
    );
  }

  Future<void> connectStream({
    required String token,
    required String streamId,
    bool audioCallOnly = false,
    required bool isHost,
  }) async {
    if (isMeetingOn) {
      return;
    }
    isMeetingOn = true;
    IsmLiveUtility.showLoader();
    try {
      var room = Room(
          // roomOptions: RoomOptions(
          //   defaultCameraCaptureOptions: CameraCaptureOptions(
          //     deviceId: _controller.configuration?.projectConfig.deviceId,
          //     cameraPosition: CameraPosition.front,
          //     params: VideoParametersPresets.h720_169,
          //   ),
          //   defaultAudioCaptureOptions: AudioCaptureOptions(
          //     deviceId: _controller.configuration?.projectConfig.deviceId,
          //     noiseSuppression: true,
          //     echoCancellation: true,
          //     autoGainControl: true,
          //     highPassFilter: true,
          //     typingNoiseDetection: true,
          //   ),
          //   defaultVideoPublishOptions: VideoPublishOptions(
          //     videoEncoding: VideoParametersPresets.h720_169.encoding,
          //     videoSimulcastLayers: [
          //       VideoParametersPresets.h180_169,
          //       VideoParametersPresets.h360_169,
          //     ],
          //   ),
          //   defaultAudioPublishOptions: const AudioPublishOptions(
          //     dtx: true,
          //   ),
          // ),
          );

      // Create a Listener before connecting
      final listener = room.createListener();

      // Try to connect to the room
      await room.connect(
        IsmLiveApis.wsUrl,
        token,
      );
      room.localParticipant?.setTrackSubscriptionPermissions(
        allParticipantsAllowed: true,
        trackPermissions: [const ParticipantTrackPermission('allowed-identity', true, null)],
      );

      if (isHost) {
        var localVideo = await LocalVideoTrack.createCameraTrack(
          const CameraCaptureOptions(
            cameraPosition: CameraPosition.front,
            params: VideoParametersPresets.h720_169,
          ),
        );
        await room.localParticipant?.publishVideoTrack(localVideo);
      }

      await room.localParticipant?.setMicrophoneEnabled(isHost);

      IsmLiveUtility.closeLoader();

      startStreamTimer();

      await IsmLiveRouteManagement.goToStreamView(
        isHost: isHost,
        room: room,
        listener: listener,
        streamId: streamId,
        audioCallOnly: audioCallOnly,
      );
      isMeetingOn = false;
    } catch (e, st) {
      isMeetingOn = false;
      IsmLiveLog.error(e, st);
    }
  }

  void startStreamTimer() {
    _controller._streamTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _controller.streamDuration += const Duration(seconds: 1);
    });
  }
}
