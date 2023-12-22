part of '../stream_controller.dart';

mixin StreamJoinMixin {
  IsmLiveStreamController get _controller => Get.find<IsmLiveStreamController>();

  bool isMeetingOn = false;

  Future<void> connectStream({
    required String token,
    required String streamId,
    bool audioCallOnly = false,
    bool isCreating = false,
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

      if (isCreating) {
        var localVideo = await LocalVideoTrack.createCameraTrack(
          const CameraCaptureOptions(
            cameraPosition: CameraPosition.front,
            params: VideoParametersPresets.h720_169,
          ),
        );
        await room.localParticipant?.publishVideoTrack(localVideo);
      }

      await room.localParticipant?.setMicrophoneEnabled(isCreating);

      IsmLiveUtility.closeLoader();

      await IsLiveRouteManagement.goToStreamView(
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
}
