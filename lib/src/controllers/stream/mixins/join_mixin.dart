part of '../stream_controller.dart';

mixin StreamJoinMixin {
  IsmLiveStreamController get _controller => Get.find();

  IsmLiveDBWrapper get _dbWrapper => Get.find();

  bool isMeetingOn = false;

  bool get isGoLiveEnabled => _controller.descriptionController.isNotEmpty;

  Future<void> initializationOfGoLive() async {
    await Permission.camera.request();
    _controller.cameraController = CameraController(
      IsmLiveUtility.cameras[1],
      ResolutionPreset.medium,
    );
    _controller.cameraFuture = _controller.cameraController!.initialize();
    _controller.update([IsmGoLiveView.updateId]);
  }

  void initialize(int index) {
    _controller.pageController = PageController(initialPage: index);
  }

  Future<void> joinStream(
    IsmLiveStreamModel stream,
    bool isHost, {
    bool joinByScrolling = false,
  }) async {
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
      imageUrl: stream.streamImage,
      isHost: isHost,
      isNewStream: false,
      joinByScrolling: joinByScrolling,
    );
  }

  Future<void> startStream() async {
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
    String? imageUrl,
    bool audioCallOnly = false,
    required bool isHost,
    required bool isNewStream,
    bool joinByScrolling = false,
  }) async {
    if (isMeetingOn) {
      return;
    }
    _controller.streamId = streamId;
    _controller.isHost = isHost;
    unawaited(_controller._mqttController?.subscribeStream(streamId));

    final translation = Get.context?.liveTranslations.streamTranslations;
    var message = '';
    if (isHost) {
      if (isNewStream) {
        message = translation?.preparingYourStream ?? IsmLiveStrings.preparingYourStream;
      } else {
        message = translation?.reconnecting ?? IsmLiveStrings.reconnecting;
      }
    } else {
      message = translation?.joiningLiveStream ?? IsmLiveStrings.joiningLiveStream;
    }
    IsmLiveUtility.showLoader(message);

    try {
      var room = Room();
      _controller.room = room;

      // Create a Listener before connecting
      final listener = room.createListener();

      _controller.listener = listener;

      // Try to connect to the room
      try {
        await room.connect(IsmLiveApis.wsUrl, token);
      } catch (e, st) {
        IsmLiveLog.error(e, st);
        isMeetingOn = false;
        IsmLiveUtility.closeLoader();
        return;
      }

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

      unawaited(Future.wait([
        _controller.getStreamMembers(streamId: streamId, limit: 10, skip: 0),
        _controller.getStreamViewer(streamId: streamId, limit: 10, skip: 0),
      ]));

      _controller.update([IsmLiveStreamView.updateId]);

      startStreamTimer();
      isMeetingOn = true;

      if (!joinByScrolling) {
        unawaited(IsmLiveRouteManagement.goToStreamView(
          isHost: isHost,
          room: room,
          imageUrl: imageUrl,
          listener: listener,
          streamId: streamId,
          audioCallOnly: audioCallOnly,
        ));
      }
    } catch (e, st) {
      unawaited(_controller._mqttController?.unsubscribeStream(streamId));
      _controller.isHost = null;
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
