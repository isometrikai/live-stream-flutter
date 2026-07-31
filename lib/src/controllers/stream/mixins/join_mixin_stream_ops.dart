part of '../stream_controller.dart';

// Host start and viewer join entry points.
mixin StreamJoinStreamOpsMixin on StreamJoinMixin, StreamJoinConnectionMixin, StreamJoinScheduleMixin {
  Future<void> initializeAndJoinStream(
    IsmLiveStreamDataModel stream,
    bool isHost, {
    bool joinByScrolling = false,
    bool isScrolling = false,
    required BuildContext context,
    bool reJoin = false,
    VoidCallback? onStreamEnd,
  }) async {
    final startedAt = DateTime.now();
    _controller.resetOnStreamEndTrigger();

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.controllerInitializeAndJoinAttempt,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'is_host': isHost,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          're_join': reJoin,
          'has_existing_room': _controller.room != null,
          'existing_stream_id': _controller.streamId ?? '',
        }
      ],
    );

    // Auto-detect rejoin scenario: if controller already has data for this stream
    // and we're not explicitly setting reJoin to false, treat it as rejoin
    // Note: Don't check listener as it might be cleared during disposal
    var isRejoinScenario = reJoin ||
        (_controller.streamId == stream.streamId && _controller.room != null);

    if (isRejoinScenario && !reJoin) {
      reJoin = true;

      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.controllerRejoinAutoDetected,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'reason': 'same_stream_id_and_room_present',
          }
        ],
      );
    }

    // Set preventDispose flag immediately for rejoin scenarios to prevent data clearing
    if (reJoin) {
      _controller.preventDispose = true;

      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.controllerPreventDisposeEnabled,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
          }
        ],
      );
    }

    final streamIndex = _controller.streams.indexOf(stream);
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.controllerInitializeIndex,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'index': streamIndex,
        }
      ],
    );

    initialize(streamIndex);

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.controllerJoinStreamAttempt,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'is_host': isHost,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          're_join': reJoin,
        }
      ],
    );

    try {
      await joinStream(
        stream,
        isHost,
        joinByScrolling: joinByScrolling,
        isScrolling: isScrolling,
        context: context,
        reJoin: reJoin,
        onStreamEnd: onStreamEnd,
      );
    } catch (e) {
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.controllerJoinStreamFailure,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': e.toString(),
          }
        ],
      );
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.controllerInitializeAndJoinFailure,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': e.toString(),
          }
        ],
      );
      rethrow;
    }
  }

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
    final startedAt = DateTime.now();
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.joinStreamAttempt,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'is_host': isHost,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          're_join': reJoin,
          'is_scheduled_stream': stream.isScheduledStream ?? false,
          'is_pk': stream.isPkChallenge ?? false,
          'hd_broadcast': stream.hdBroadcast ?? false,
          'restream': stream.restream ?? false,
          'audio_only': stream.audioOnly ?? false,
        }
      ],
    );

    // Handle scheduled stream not started yet here to avoid duplicate navigation during scrolling
    if (isScheduleStreamNotStartedYet(stream)) {
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.joinStreamEarlyReturnScheduledNotStarted,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'is_host': isHost,
            'join_by_scrolling': joinByScrolling,
            'is_scrolling': isScrolling,
            're_join': reJoin,
          }
        ],
      );
      startSeduleStream(
        stream,
        isHost: isHost,
        isScrolling: isScrolling,
        joinByScrolling: joinByScrolling,
      );
      return;
    }
    // Get the token for the stream based on whether the user is a host or not
    if (onStreamEnd != null) {
      IsmLiveApp.onStreamEnd = onStreamEnd;
    }

    var token = '';
    var viewerUsedCachedToken = false;
    if (isHost) {
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.joinStreamTokenFetchHost,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
          }
        ],
      );
      token = await _dbWrapper.getSecuredValue(stream.streamId ?? '');

      if (token.trim().isEmpty) {
        final streamId = stream.streamId ?? '';
        final userId = _controller.user?.userId ?? '';
        final stopCallback = IsmLiveDelegate.missingHostTokenStopStreamCallback;
        var shouldCallStopStreamApi = true;

        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.joinStreamMissingHostToken,
          properties: [
            {
              'stream_id': streamId,
              'event_id': stream.eventId ?? '',
              'user_id': userId,
              'has_stop_callback': stopCallback != null,
            }
          ],
        );

        if (stopCallback != null) {
          try {
            shouldCallStopStreamApi =
                await stopCallback(context, streamId, userId);
          } catch (error, stackTrace) {
            IsmLiveLog.error(
              'missingHostTokenStopStreamCallback failed: $error',
              stackTrace,
            );
            // Preserve legacy behavior if host callback fails unexpectedly.
            shouldCallStopStreamApi = true;
          }
        } else {
          final shouldStopFromSheet =
              await IsmLiveUtility.openCustomBottomSheet<bool>(
            title: IsmLiveStrings.alreadyLiveOnAnotherDevice,
            leftLabel: IsmLiveStrings.no,
            rightLabel: IsmLiveStrings.yes,
            onLeft: () => IsmLiveRoute.pop(false),
            onRight: () => IsmLiveRoute.pop(true),
          );
          shouldCallStopStreamApi = shouldStopFromSheet ?? false;
        }

        if (shouldCallStopStreamApi) {
          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.joinStreamStopStreamCalled,
            properties: [
              {
                'stream_id': streamId,
                'event_id': stream.eventId ?? '',
                'user_id': userId,
              }
            ],
          );
          await _controller.stopStream(streamId, userId);
        }
        return;
      }
    } else {
      final streamId = stream.streamId ?? '';
      var existingToken = (await _dbWrapper.getSecuredValue(streamId)).trim();

      if (existingToken.isNotEmpty) {
        token = existingToken;
        viewerUsedCachedToken = true;
      } else {
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.joinStreamTokenFetchViewer,
          properties: [
            {
              'stream_id': stream.streamId ?? '',
              'event_id': stream.eventId ?? '',
            }
          ],
        );
        var data = await _controller.getRTCToken(streamId);
        if (data == null) {
          return;
        }

        token = data.rtcToken;

        // Store the start time for later calculation instead of calculating duration immediately
        _controller._streamStartTime = data.startTime;
      }
    }

    _controller.isRtmp = stream.rtmpIngest ?? false;
    _controller.isPremium = stream.isPaid ?? false;

    if (_controller.isPremium) {
      _controller.premiumStreamCoinsController.text = stream.amount.toString();
    }

    // Store fallback start time for later calculation
    if (_controller._streamStartTime == null && stream.startDateTime != null) {
      _controller._streamStartTime = stream.startDateTime;
    }

    // Initialize stream duration to zero - will be calculated just before timer starts
    _controller.streamDuration = Duration.zero;

    // Connect to the stream
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.joinStreamConnectStreamAttempt,
      properties: [
        {
          'stream_id': stream.streamId ?? '',
          'event_id': stream.eventId ?? '',
          'is_host': isHost,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          're_join': reJoin,
          'defer_connection': true,
        }
      ],
    );

    try {
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
          reJoin: reJoin,
          deferConnection: true);
    } catch (e, st) {
      if (!isHost && viewerUsedCachedToken) {
        final streamId = stream.streamId ?? '';
        IsmLiveLog.error(
          'joinStream: cached viewer RTC token failed, retrying with fresh token: $e',
          st,
        );
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.joinStreamTokenFetchViewer,
          properties: [
            {
              'stream_id': stream.streamId ?? '',
              'event_id': stream.eventId ?? '',
            }
          ],
        );
        final freshData = await _controller.getRTCToken(streamId);
        if (freshData != null && freshData.rtcToken.trim().isNotEmpty) {
          token = freshData.rtcToken;
          _controller._streamStartTime = freshData.startTime;
          try {
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
                reJoin: reJoin,
                deferConnection: true);
            return;
          } catch (_) {}
        }
      }
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.joinStreamConnectStreamFailure,
        properties: [
          {
            'stream_id': stream.streamId ?? '',
            'event_id': stream.eventId ?? '',
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': e.toString(),
          }
        ],
      );
      rethrow;
    }
  }

// Start streaming
  Future<void> startStream(
      {bool isNewStream = true, required BuildContext context}) async {
    if (_controller.isPremium &&
        _controller.premiumStreamCoinsController.isEmpty) {
      _controller.premiumStreamSheet();
      return;
    }

    // Check if cover photo is selected - show toast immediately if not
    if (_controller.pickedImage == null &&
        (_controller.streamDetails?.streamImage?.isEmpty ?? true)) {
      final toastContext = IsmLiveUtility.navigatorKey.currentContext;

      Fluttertoast.showToast(
        msg: IsmLiveStrings.pleaseSelectCoverPhoto,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: toastContext != null
            ? toastContext.dynamicTextTheme.bodyMedium?.fontSize ?? 16.0
            : 16.0,
      );
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
      _controller.streamDetails =
          _controller.streamDetails?.copyWith(startDateTime: res.startTime);
    } else {
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

    // Store the start time for later calculation instead of calculating duration immediately
    _controller._streamStartTime = stream.startTime;

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
      deferConnection: true,
    );
  }
}