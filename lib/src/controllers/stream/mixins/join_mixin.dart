part of '../stream_controller.dart';

// This mixin provides methods for joining and initializing streams
mixin StreamJoinMixin {
  // Get references to the necessary controllers and wrappers using Get.find()
  IsmLiveStreamController get _controller => Get.find();
  IsmLiveDBWrapper get _dbWrapper => Get.find();

  // Check if Go Live is enabled by checking if the description controller is not empty
  bool get isGoLiveEnabled => _controller.descriptionController.isNotEmpty;

// Initialize the Go Live process by requesting camera permission and initializing the camera controller
  Future<void> initializationOfGoLive() async {
    await Permission.camera.request();
    _controller.cameraController = CameraController(
      IsmLiveUtility.cameras[1],
      ResolutionPreset.medium,
    );
    _controller.cameraFuture = _controller.cameraController!.initialize();
    _controller.update([IsmGoLiveView.updateId]);
  }

// Initialize and join a stream
  Future<void> initializeAndJoinStream(
    IsmLiveStreamModel stream,
    bool isHost, {
    bool joinByScrolling = false,
  }) async {
    initialize(_controller.streams.indexOf(stream));

    await joinStream(stream, isHost, joinByScrolling: joinByScrolling);
  }

// Initialize the page controller
  void initialize(int index) {
    _controller.pageController = PageController(initialPage: index);
  }

  // Enable the user's video
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

  Future<void> unpublishTracks() =>
      _controller.room!.localParticipant!.unpublishAllTracks();

// Join a stream
  Future<void> joinStream(
    IsmLiveStreamModel stream,
    bool isHost, {
    bool joinByScrolling = false,
  }) async {
    // Get the token for the stream based on whether the user is a host or not
    var token = '';
    if (isHost) {
      token = await _dbWrapper.getSecuredValue(stream.streamId ?? '');
      if (token.trim().isEmpty) {
        await _controller.stopStream(stream.streamId ?? '');
      }
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

    // Connect to the stream
    await connectStream(
      token: token,
      streamId: stream.streamId!,
      streamImage: stream.streamImage,
      streamDiscription: stream.streamDescription,
      isHost: isHost,
      isNewStream: false,
      joinByScrolling: joinByScrolling,
      hdBroadcast: stream.hdBroadcast ?? false,
    );
  }

// Start streaming
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
    // Create a stream
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

    // Connect to the created stream
    await connectStream(
      token: stream.rtcToken,
      streamId: stream.streamId!,
      streamImage: data.image,
      isHost: true,
      isNewStream: true,
      hdBroadcast: _controller.isHdBroadcast,
    );
  }

  // Connect to the stream
  Future<void> connectStream({
    required String token,
    required String streamId,
    String? streamImage,
    String? streamDiscription,
    bool audioCallOnly = false,
    bool hdBroadcast = false,
    required bool isHost,
    bool isCopublisher = false,
    required bool isNewStream,
    bool joinByScrolling = false,
  }) async {
    // if (isMeetingOn) {
    //   return;
    // }
    // Show a loader while connecting
    _controller.isModerationWarningVisible = true;
    _controller.descriptionController.text =
        streamDiscription ?? _controller.descriptionController.text;

    // Subscribe to the stream
    _controller.streamId = streamId;
    _controller.isHost = isHost;
    _controller.isCopublisher = isCopublisher;
    unawaited(
      _controller._mqttController?.subscribeStream(
        streamId,
      ),
    );

// Show appropriate message based on the user's role
    final translation = Get.context?.liveTranslations.streamTranslations;
    var message = '';
    if (isHost) {
      if (isNewStream) {
        message = translation?.preparingYourStream ??
            IsmLiveStrings.preparingYourStream;
      } else {
        message = translation?.reconnecting ?? IsmLiveStrings.reconnecting;
      }
    } else if (isCopublisher) {
      message =
          translation?.enablingYourVideo ?? IsmLiveStrings.enablingYourVideo;
    } else {
      message =
          translation?.joiningLiveStream ?? IsmLiveStrings.joiningLiveStream;
    }
    IsmLiveUtility.showLoader(message);

    try {
      final videoQuality = hdBroadcast
          ? VideoParametersPresets.h720_169
          : VideoParametersPresets.h540_169;
      var room = Room(
        roomOptions: RoomOptions(
          defaultCameraCaptureOptions: CameraCaptureOptions(
            cameraPosition: CameraPosition.front,
            params: videoQuality,
          ),
          defaultAudioCaptureOptions: const AudioCaptureOptions(
            noiseSuppression: true,
            echoCancellation: true,
            autoGainControl: true,
            highPassFilter: true,
            typingNoiseDetection: true,
          ),
          defaultVideoPublishOptions: VideoPublishOptions(
            videoEncoding: videoQuality.encoding,
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

      // Set track subscription permissions
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

      // Enable video if the user is a host or copublisher
      if (isHost || isCopublisher) {
        await enableMyVideo();
      }
      // Toggle audio if the user is a host or
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
