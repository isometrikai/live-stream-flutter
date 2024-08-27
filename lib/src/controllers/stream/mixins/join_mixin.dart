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
    IsmLiveStreamDataModel stream,
    bool isHost, {
    bool joinByScrolling = false,
    bool isScrolling = false,
  }) async {
    initialize(_controller.streams.indexOf(stream));

    await joinStream(stream, isHost,
        joinByScrolling: joinByScrolling, isScrolling: isScrolling);
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
    lk.VideoParameters? videoFilter;
    if (_controller.isRestreamBroadcast) {
      videoFilter = const lk.VideoParameters(
        dimensions: lk.VideoDimensions(480, 640),
        encoding: lk.VideoEncoding(
          maxFramerate: 30,
          maxBitrate: 2500000,
        ),
      );
    }

    final tracks = await Future.wait([
      lk.LocalVideoTrack.createCameraTrack(lk.CameraCaptureOptions(
          params: videoFilter ?? lk.VideoParametersPresets.h720_169)),
      lk.LocalAudioTrack.create(),
    ]);
    var localVideo = tracks[0] as lk.LocalVideoTrack;
    var localAudio = tracks[1] as lk.LocalAudioTrack;

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
    IsmLiveStreamDataModel stream,
    bool isHost, {
    bool joinByScrolling = false,
    bool isScrolling = false,
    bool isInteractive = false,
    VoidCallback? onStreamEnd,
  }) async {
    // Get the token for the stream based on whether the user is a host or not
    if (onStreamEnd != null) {
      IsmLiveApp.onStreamEnd = onStreamEnd;
    }

    var token = '';
    if (isHost) {
      token = await _dbWrapper.getSecuredValue(stream.streamId ?? '');

      if (token.trim().isEmpty) {
        await _controller.stopStream(
            stream.streamId ?? '', _controller.user?.userId ?? '');
        return;
      }
    } else {
      var data = await _controller.getRTCToken(stream.streamId ?? '');
      if (data == null) {
        return;
      }

      token = data.rtcToken;
    }

    _controller.isRtmp = stream.rtmpIngest ?? false;
    _controller.isPremium = stream.isPaid ?? false;

    if (_controller.isPremium) {
      _controller.premiumStreamCoinsController.text = stream.amount.toString();
    }

    var now = DateTime.now();
    _controller.streamDuration = now.difference(stream.startDateTime ?? now);

    // Connect to the stream
    await connectStream(
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
    );
  }

// Start streaming
  Future<void> startStream({bool isNewStream = true}) async {
    if (_controller.isPremium &&
        _controller.premiumStreamCoinsController.isEmpty) {
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
    } else {
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
      if (data.model?.rtcToken.isEmpty ?? true) {
        IsmLiveUtility.showDialog(
          IsmLiveScheduleDialog(
            message: _controller.scheduleLiveDate,
          ),
        );
        await _controller.getStreams(type: IsmLiveStreamType.scheduledStreams);

        return;
      }

      stream = data.model!;
      image = data.image;
    }

    var now = DateTime.now();
    _controller.streamDuration = now.difference(stream.startTime ?? now);

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
    );
  }

  // Connect to the stream
  Future<void> connectStream({
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
  }) async {
    // Subscribe to the stream
    _controller.streamId = streamId;

    // Show a loader while connecting
    _controller.isModerationWarningVisible = true;
    _controller.descriptionController.text =
        streamDiscription ?? _controller.descriptionController.text;

    _controller.pkStages = null;

    _controller.userRole =
        isHost ? IsmLiveUserRole.host() : IsmLiveUserRole.viewer();

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
    if (!isCopublisher) {
      await _controller._mqttController?.subscribeStream(
        streamId,
      );
    }

    // Show appropriate message based on the user's role
    final translation = Get.context?.liveTranslations?.streamTranslations;
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
    } else if (isPkGust) {
      message = translation?.pkMessage ?? IsmLiveStrings.pkMessage;
    } else {
      message =
          translation?.joiningLiveStream ?? IsmLiveStrings.joiningLiveStream;
    }
    if (!joinByScrolling) {
      IsmLiveUtility.showLoader(message);
    }

    try {
      final videoQuality = hdBroadcast || restream
          ? const lk.VideoParameters(
              dimensions: lk.VideoDimensions(480, 640),
              encoding: lk.VideoEncoding(
                maxFramerate: 30,
                maxBitrate: 2500000,
              ),
            )
          : lk.VideoParametersPresets.h540_169;
      var room = lk.Room(
        roomOptions: lk.RoomOptions(
          defaultCameraCaptureOptions: lk.CameraCaptureOptions(
            cameraPosition: lk.CameraPosition.front,
            params: videoQuality,
          ),
          defaultAudioCaptureOptions: const lk.AudioCaptureOptions(
            noiseSuppression: true,
            echoCancellation: true,
            autoGainControl: true,
            highPassFilter: true,
            typingNoiseDetection: true,
          ),
          defaultVideoPublishOptions: lk.VideoPublishOptions(
            videoEncoding: videoQuality.encoding,
          ),
          defaultAudioPublishOptions: const lk.AudioPublishOptions(
            dtx: true,
          ),
        ),
      );

      _controller.room = room;

      /// Dispose listener if it was active on `scroll` streams
      await _controller.listener?.dispose();

      // Create a Listener before connecting
      _controller.listener = room.createListener();

      // Try to connect to the room
      try {
        await room.connect(IsmLiveApis.wsUrl, token);
      } catch (e, st) {
        IsmLiveLog.error(e, st);
        IsmLiveUtility.closeLoader();
        return;
      }

      // Set track subscription permissions
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

      // Enable video if the user is a host or copublisher
      if (!_controller.isRtmp) {
        if (isHost || isCopublisher || isPkGust) {
          await enableMyVideo();
        }
        // Toggle audio if the user is a host or copublisher
        unawaited(
          _controller.toggleAudio(
            value: isHost || isCopublisher,
          ),
        );
      }

      if (!joinByScrolling) {
        IsmLiveUtility.closeLoader();
      }

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
      _controller.initializeStream(
        streamId: streamId,
        isHost: isHost,
      );

      startStreamTimer();

      if (!joinByScrolling) {
        IsmLiveGifts.threeD.map((e) => IsmLiveGif.preCache(e.path));
        IsmLiveGifts.animated.map((e) => IsmLiveGif.preCache(e.path));

        await IsmLiveRouteManagement.goToStreamView(
          isHost: isHost,
          isNewStream: isNewStream,
          room: room,
          isScrolling: isScrolling,
          streamImage: streamImage,
          listener: _controller.listener!,
          streamId: streamId,
          isInteractive: isInteractive,
        );
      }

      // _controller.update([IsmLiveStreamView.updateId]);
    } catch (e, st) {
      unawaited(
        _controller._mqttController?.unsubscribeStream(
          streamId,
        ),
      );
      _controller.userRole = null;
      IsmLiveLog.error(e, st);
    }
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
    IsmLiveStreamDataModel stream,
  ) {
    _controller.userRole = IsmLiveUserRole.host();
    var details = stream.userDetails;

    _controller.streamDetails = stream;

    _controller.hostDetails = IsmLiveMemberDetailsModel(
        isAdmin: false,
        isPublishing: false,
        joinTime: 0,
        metaData: details?.userMetaData ?? const IsmLiveMetaData(),
        userId: details?.id ?? '',
        userIdentifier: '',
        userName: details?.userName ?? '',
        userProfileImageUrl: details?.userProfile ?? '');
    _controller.room = lk.Room();
    IsmLiveRouteManagement.goToStreamView(
      isHost: true,
      isNewStream: false,
      room: lk.Room(),
      isScrolling: false,
      streamImage: stream.streamImage,
      listener: lk.Room().createListener(),
      streamId: stream.streamId ?? '',
      isSchedule: true,
    );
  }

  void editScheduleStream() async {
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
      image = await _controller.uploadImage(type, bytes);
    }

    var res = await _controller.editScheduledStream(
      eventId: _controller.streamDetails?.eventId ?? '',
      streamImage: image ?? _controller.streamDetails?.streamImage,
      streamDescription: _controller.descriptionController.text.trim(),
    );
    _controller.streamDetails = null;
    if (res) {
      IsmLiveUtility.showDialog(
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
    _controller.streamTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _controller.streamDuration += const Duration(
          seconds: 1,
        );
      },
    );
  }
}
