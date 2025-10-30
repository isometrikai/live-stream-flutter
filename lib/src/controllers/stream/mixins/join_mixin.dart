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
    required BuildContext context,
    bool reJoin = false,
  }) async {
    // Auto-detect rejoin scenario: if controller already has data for this stream
    // and we're not explicitly setting reJoin to false, treat it as rejoin
    // Note: Don't check listener as it might be cleared during disposal
    var isRejoinScenario = reJoin ||
        (_controller.streamId == stream.streamId && _controller.room != null);

    if (isRejoinScenario && !reJoin) {
      print(
          'initializeAndJoinStream: Auto-detected rejoin scenario for stream ${stream.streamId}');
      reJoin = true;
    }

    // Set preventDispose flag immediately for rejoin scenarios to prevent data clearing
    if (reJoin) {
      _controller.preventDispose = true;
      print(
          'initializeAndJoinStream: Set preventDispose=true for rejoin scenario');
    }

    initialize(_controller.streams.indexOf(stream));
    print('initializeAndJoinStream called ${stream.streamId}, reJoin=$reJoin');
    if (stream.isScheduledStream == true &&
        (stream.streamId == null ||
            stream.streamId?.isEmpty == true ||
            stream.streamId?.contains('0000') == true)) {
      startSeduleStream(stream, isScrolling: isScrolling);
    } else {
      await joinStream(stream, isHost,
          joinByScrolling: joinByScrolling,
          isScrolling: isScrolling,
          context: context,
          reJoin: reJoin);
    }
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

      // Resolve initial camera position for manual track creation as well
      final resolvedCameraPosition =
          (IsmLiveDelegate.initialCameraPositionStream ==
                  IsmLiveCameraPosition.front)
              ? lk.CameraPosition.front
              : lk.CameraPosition.back;

      final tracks = await Future.wait([
        lk.LocalVideoTrack.createCameraTrack(
          lk.CameraCaptureOptions(
            cameraPosition: resolvedCameraPosition,
            params: videoFilter ?? lk.VideoParametersPresets.h720_169,
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

      // Log the complete RTC response for debugging
      print('  startTime: ${data.startTime}');

      // Store the start time for later calculation instead of calculating duration immediately
      _controller._streamStartTime = data.startTime;
    }

    _controller.isRtmp = stream.rtmpIngest ?? false;
    _controller.isPremium = stream.isPaid ?? false;

    if (_controller.isPremium) {
      _controller.premiumStreamCoinsController.text = stream.amount.toString();
    }

    // Store fallback start time for later calculation
    if (_controller._streamStartTime == null && stream.startDateTime != null) {
      _controller._streamStartTime = stream.startDateTime;
      print(
          'StreamTimer JOIN stored fallback startDateTime: ${stream.startDateTime} (UTC: ${stream.startDateTime!.toUtc()})');
    }

    // Initialize stream duration to zero - will be calculated just before timer starts
    _controller.streamDuration = Duration.zero;

    // Connect to the stream
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
        reJoin: reJoin);
  }

// Start streaming
  Future<void> startStream(
      {bool isNewStream = true, required BuildContext context}) async {
    if (_controller.isPremium &&
        _controller.premiumStreamCoinsController.isEmpty) {
      _controller.premiumStreamSheet();
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

    // Log the complete create stream response for debugging
    print('StreamTimer Create Stream Response Debug:');
    print('  startTime: ${stream.startTime}');
    print('  startTime UTC: ${stream.startTime?.toUtc()}');

    // Store the start time for later calculation instead of calculating duration immediately
    _controller._streamStartTime = stream.startTime;
    if (stream.startTime != null) {
      print(
          'StreamTimer CREATE stored server startTime: ${stream.startTime} (UTC: ${stream.startTime!.toUtc()})');
    } else {
      print('StreamTimer CREATE no start time available');
    }

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
  }) async {
    // Subscribe to the stream
    _controller.streamId = streamId;
    print('initializeAndJoinStream initialized with streamId: $streamId');
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

    // Reset callback trigger flag for new stream
    _controller._streamViewLoadedCallbackTriggered = false;

    // Set up background lifecycle management
    _controller.setStreamActive(true, isHost);

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

    // Add null safety check for MQTT controller
    try {
      if (IsmLiveDelegate.subscribStreamById != null) {
        IsmLiveDelegate.subscribStreamById!(streamId);
      } else {
        if (!isCopublisher && _controller._mqttController != null) {
          await _controller._mqttController?.subscribeStream(streamId);
        }
      }
    } catch (e) {
      IsmLiveLog.error('MQTT subscription error: $e');
    }

    // Show appropriate message based on the user's role
    var message = '';
    try {
      final translation = context.liveTranslations?.streamTranslations;
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
    } catch (e) {
      // Fallback message if context access fails
      message = isHost
          ? (isNewStream ? 'Preparing your stream...' : 'Reconnecting...')
          : 'Joining live stream...';
      IsmLiveLog.error('Translation access error: $e');
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
      // Resolve initial camera position from global UI configuration
      final resolvedCameraPosition =
          (IsmLiveDelegate.initialCameraPositionStream ==
                  IsmLiveCameraPosition.front)
              ? lk.CameraPosition.front
              : lk.CameraPosition.back;

      var room = lk.Room(
        roomOptions: lk.RoomOptions(
          defaultCameraCaptureOptions: lk.CameraCaptureOptions(
            cameraPosition: resolvedCameraPosition,
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
      try {
        await _controller.listener?.dispose();
      } catch (e) {
        IsmLiveLog.error('Listener dispose error: $e');
      }

      // Create a Listener before connecting
      _controller.listener = room.createListener();

      // Try to connect to the room with better error handling
      try {
        await room.connect(IsmLiveApis.wsUrl, token);

        // Store the token for background lifecycle reconnection
        _controller.storeToken(token);
      } catch (e, st) {
        IsmLiveLog.error('Room connection error: $e', st);
        IsmLiveUtility.closeLoader();
        return;
      }
      print('initializeAndJoinStream 444444');

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

      if (!joinByScrolling) {
        IsmLiveUtility.closeLoader();
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
        print(
            'StreamTimer CONNECT stored direct startTime: $startTime (UTC: ${startTime.toUtc()})');
      }

      startStreamTimer();

      print(
          'initializeAndJoinStream: joinByScrolling=$joinByScrolling, will call goToStreamView: ${!joinByScrolling}');

      if (!joinByScrolling) {
        try {
          IsmLiveGifts.threeD.map((e) => IsmLiveGif.preCache(e.path, context));
          IsmLiveGifts.animated
              .map((e) => IsmLiveGif.preCache(e.path, context));
        } catch (e) {
          IsmLiveLog.error('Gift pre-cache error: $e');
        }
        print('initializeAndJoinStream 555555');
        try {
          print(
              'initializeAndJoinStream: About to call goToStreamView with reJoin=$reJoin');

          // Check if listener is null before calling goToStreamView
          if (_controller.listener == null) {
            print(
                'initializeAndJoinStream: ERROR - listener is null, cannot proceed with goToStreamView');
            IsmLiveLog.error('Cannot join stream: listener is null');
            return;
          }

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

          print('initializeAndJoinStream: goToStreamView completed');
        } catch (e) {
          IsmLiveLog.error('Navigation error: $e');
          print('initializeAndJoinStream: Navigation error details: $e');
        }
      } else {
        print(
            'initializeAndJoinStream: Skipping goToStreamView due to joinByScrolling=true');
      }

      // _controller.update([IsmLiveStreamView.updateId]);
    } catch (e, st) {
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

  void startSeduleStream(IsmLiveStreamDataModel stream,
      {bool isHost = true, bool isScrolling = false}) {
    _controller._streamViewLoadedCallbackTriggered = false;
    _controller.userRole =
        isHost ? IsmLiveUserRole.host() : IsmLiveUserRole.viewer();
    var details = stream.userDetails;

    _controller.streamDetails = stream;

    _controller.hostDetails = IsmLiveMemberDetailsModel(
        isAdmin: false,
        isPublishing: false,
        joinTime: 0,
        metaData: details?.userMetaData ?? const IsmLiveMetaData(),
        userId: details?.id ?? '',
        userIdentifier: details?.appUserId ?? '',
        userName: details?.userName ?? '',
        userProfileImageUrl: details?.userProfile ?? '');

    _controller.room = lk.Room();
    IsmLiveRouteManagement.goToStreamView(
      isHost: true,
      isNewStream: false,
      room: lk.Room(),
      isScrolling: isScrolling,
      streamImage: stream.streamImage,
      listener: lk.Room().createListener(),
      streamId: stream.streamId ?? '',
      isSchedule: true,
      reJoin: false, // This is for scheduled streams, not rejoin
    );

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
      print(
          'StreamTimer CALCULATED duration at timer start: ${_controller.streamDuration}');
      print(
          'StreamTimer CALCULATED using startTime: ${_controller._streamStartTime} (UTC: ${_controller._streamStartTime!.toUtc()})');
      print('StreamTimer CALCULATED current time: $now (UTC: ${now.toUtc()})');
      print(
          'StreamTimer CALCULATED user: ${_controller.user?.userId} streamId: ${_controller.streamId}');
    } else {
      _controller.streamDuration = Duration.zero;
      print(
          'StreamTimer CALCULATED no start time available, initializing to zero');
    }

    print(
        'StreamTimer startStreamTimer duration: ${_controller.streamDuration}');
    print(
        'StreamTimer startStreamTimer user: ${_controller.user?.userId} streamId: ${_controller.streamId}');

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
