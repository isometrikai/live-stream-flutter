part of '../stream_controller.dart';

mixin StreamJoinMixin {
  IsmLiveStreamController get _controller => Get.find();

  IsmLiveDBWrapper get _dbWrapper => Get.find();

  // bool isMeetingOn = false;

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

  Future<void> initializeAndJoinStream(
    IsmLiveStreamModel stream,
    bool isHost, {
    bool joinByScrolling = false,
  }) async {
    initialize(_controller.streams.indexOf(stream));
    await joinStream(stream, isHost, joinByScrolling: joinByScrolling);
  }

  void initialize(int index) {
    _controller.pageController = PageController(initialPage: index);
  }

  Future<void> enableMyVideo() async {
    if (_controller.room == null) {
      return;
    }
    final tracks = await Future.wait([
      LocalVideoTrack.createCameraTrack(),
      LocalAudioTrack.create(),
    ]);
    var localVideo = tracks[0] as LocalVideoTrack;
    var localAudio = tracks[1] as LocalAudioTrack;

    await Future.wait<dynamic>([
      _controller.room!.localParticipant!.publishVideoTrack(localVideo),
      _controller.room!.localParticipant!.publishAudioTrack(localAudio),
    ]);
  }

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
      streamImage: stream.streamImage,
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

    var data = await _controller.createStream();
    if (data == null) {
      return;
    }
    if (data.model == null) {
      return;
    }
    final stream = data.model!;
    var now = DateTime.now();
    _controller.streamDuration = now.difference(stream.startTime ?? now);

    await connectStream(
      token: stream.rtcToken,
      streamId: stream.streamId!,
      streamImage: data.image,
      isHost: true,
      isNewStream: true,
    );
  }

  Future<void> connectStream({
    required String token,
    required String streamId,
    String? streamImage,
    bool audioCallOnly = false,
    required bool isHost,
    bool isCopublisher = false,
    required bool isNewStream,
    bool joinByScrolling = false,
  }) async {
    // if (isMeetingOn) {
    //   return;
    // }
    _controller.isModerationWarningVisible = true;
    _controller.streamId = streamId;
    _controller.isHost = isHost;
    _controller.isCopublisher = isCopublisher;
    unawaited(
      _controller._mqttController?.subscribeStream(
        streamId,
      ),
    );

    final translation = Get.context?.liveTranslations.streamTranslations;
    var message = '';
    if (isHost) {
      if (isNewStream) {
        message = translation?.preparingYourStream ?? IsmLiveStrings.preparingYourStream;
      } else {
        message = translation?.reconnecting ?? IsmLiveStrings.reconnecting;
      }
    } else if (isCopublisher) {
      message = translation?.enablingYourVideo ?? IsmLiveStrings.enablingYourVideo;
    } else {
      message = translation?.joiningLiveStream ?? IsmLiveStrings.joiningLiveStream;
    }
    IsmLiveUtility.showLoader(message);

    try {
      var room = Room(
        roomOptions: RoomOptions(
          defaultCameraCaptureOptions: const CameraCaptureOptions(
            cameraPosition: CameraPosition.front,
            params: VideoParametersPresets.h720_169,
          ),
          defaultAudioCaptureOptions: const AudioCaptureOptions(
            noiseSuppression: true,
            echoCancellation: true,
            autoGainControl: true,
            highPassFilter: true,
            typingNoiseDetection: true,
          ),
          defaultVideoPublishOptions: VideoPublishOptions(
            videoEncoding: VideoParametersPresets.h720_169.encoding,
            videoSimulcastLayers: [
              VideoParametersPresets.h180_169,
              VideoParametersPresets.h360_169,
            ],
          ),
          defaultAudioPublishOptions: const AudioPublishOptions(
            dtx: true,
          ),
        ),
      );
      _controller.room = room;

      // Create a Listener before connecting
      final listener = room.createListener();

      _controller.listener = listener;

      // Try to connect to the room
      try {
        await room.connect(IsmLiveApis.wsUrl, token);
      } catch (e, st) {
        IsmLiveLog.error(e, st);
        // isMeetingOn = false;
        IsmLiveUtility.closeLoader();
        return;
      }

      room.localParticipant?.setTrackSubscriptionPermissions(
        allParticipantsAllowed: true,
        trackPermissions: [
          const ParticipantTrackPermission(
            'allowed-identity',
            true,
            null,
          ),
        ],
      );

      if (isHost || isCopublisher) {
        await enableMyVideo();
      }

      unawaited(
        _controller.toggleAudio(
          value: isHost || isCopublisher,
        ),
      );

      IsmLiveUtility.closeLoader();

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

      _controller.update([IsmLiveStreamView.updateId]);

      startStreamTimer();
      // isMeetingOn = true;

      if (!joinByScrolling) {
        IsmLiveGifts.threeD.map((e) => IsmLiveGif.preCache(e.path));
        IsmLiveGifts.animated.map((e) => IsmLiveGif.preCache(e.path));

        unawaited(
          IsmLiveRouteManagement.goToStreamView(
            isHost: isHost,
            isNewStream: isNewStream,
            room: room,
            streamImage: streamImage,
            listener: listener,
            streamId: streamId,
            audioCallOnly: audioCallOnly,
          ),
        );
      }
    } catch (e, st) {
      unawaited(
        _controller._mqttController?.unsubscribeStream(
          streamId,
        ),
      );
      _controller.isHost = null;
      // isMeetingOn = false;
      IsmLiveLog.error(e, st);
    }
  }

  void startStreamTimer() {
    _controller._streamTimer = Timer.periodic(
        const Duration(
          seconds: 1,
        ), (timer) {
      _controller.streamDuration += const Duration(
        seconds: 1,
      );
    });
  }
}
