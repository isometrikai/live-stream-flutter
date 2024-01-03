part of '../stream_controller.dart';

mixin StreamJoinMixin {
  IsmLiveStreamController get _controller => Get.find();

  IsmLiveDBWrapper get _dbWrapper => Get.find();

  IsmLiveMqttController? get _mqttController {
    if (Get.isRegistered<IsmLiveMqttController>()) {
      return Get.find<IsmLiveMqttController>();
    }
    return null;
  }

  bool isMeetingOn = false;

  Future<void> joinStream(
    IsmLiveStreamModel stream,
    bool isHost,
  ) async {
    var token = '';
    if (isHost) {
      token = await _dbWrapper.getSecuredValue(stream.streamId ?? '');
      if (token.trim().isEmpty) {
        return;
      }
    } else {
      var data = await _controller.getRTCToken(stream.streamId ?? '');
      if (data == null) {
        return;
      }
      token = data.rtcToken;
    }

    var now = DateTime.now();
    _controller.streamDuration = now.difference(stream.startTime ?? now);

    await connectStream(
      token: token,
      streamId: stream.streamId!,
      isHost: isHost,
      isNewStream: false,
    );
  }

  Future<void> startStream() async {
    var stream = await _controller.createStream();
    if (stream == null) {
      return;
    }
    var now = DateTime.now();
    _controller.streamDuration = now.difference(stream.startTime ?? now);

    await connectStream(
      token: stream.rtcToken,
      streamId: stream.streamId!,
      isHost: true,
      isNewStream: true,
    );
  }

  Future<void> connectStream({
    required String token,
    required String streamId,
    bool audioCallOnly = false,
    required bool isHost,
    required bool isNewStream,
  }) async {
    if (isMeetingOn) {
      return;
    }
    isMeetingOn = true;
    _controller.isHost = isHost;
    unawaited(_mqttController?.subscribeStream(streamId));

    final translation = Get.context?.liveTranslations.streamTranslations;
    var message = '';
    if (isHost) {
      if (isNewStream) {
        message = translation?.preparingYourStream ??
            IsmLiveStrings.preparingYourStream;
      } else {
        message = translation?.reconnecting ?? IsmLiveStrings.reconnecting;
      }
    } else {
      message =
          translation?.joiningLiveStream ?? IsmLiveStrings.joiningLiveStream;
    }
    IsmLiveUtility.showLoader(message);

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
      try {
        await room.connect(
          IsmLiveApis.wsUrl,
          token,
        );
      } catch (e, st) {
        IsmLiveLog.error(e, st);
        IsmLiveUtility.closeLoader();
        return;
      }

      room.localParticipant?.setTrackSubscriptionPermissions(
        allParticipantsAllowed: true,
        trackPermissions: [
          const ParticipantTrackPermission('allowed-identity', true, null)
        ],
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

      _controller.update([IsmLiveStreamView.updateId]);

      startStreamTimer();

      await IsmLiveRouteManagement.goToStreamView(
        isHost: isHost,
        isNewStream: isNewStream,
        room: room,
        listener: listener,
        streamId: streamId,
        audioCallOnly: audioCallOnly,
      );
      unawaited(_mqttController?.unsubscribeStream(streamId));
      _controller.isHost = null;
      isMeetingOn = false;
    } catch (e, st) {
      _controller.isHost = null;
      isMeetingOn = false;
      IsmLiveLog.error(e, st);
    }
  }

  void startStreamTimer() {
    _controller._streamTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      _controller.streamDuration += const Duration(seconds: 1);
    });
  }
}
