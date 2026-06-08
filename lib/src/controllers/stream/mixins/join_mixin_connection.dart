part of '../stream_controller.dart';

// LiveKit room connection and deferred-connect completion.
mixin StreamJoinConnectionMixin on StreamJoinMixin, StreamJoinCameraMixin {
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
    // When true, heavy LiveKit connection work is deferred and completed
    // from `stream_view` after navigation for a smoother transition.
    bool deferConnection = false,
  }) async {
    final startedAt = DateTime.now();
    final trackedStartDateTime = (startTime ??
            stream?.startDateTime ??
            _controller.streamDetails?.startDateTime)
        ?.toIso8601String();

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.connectStreamAttemptDetailed,
      properties: [
        {
          'stream_id': streamId,
          'is_host': isHost,
          'is_new_stream': isNewStream,
          're_join': reJoin,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          'is_copublisher': isCopublisher,
          'is_pk': isPk,
          'is_pk_guest': isPkGust,
          'hd_broadcast': hdBroadcast,
          'restream': restream,
          'defer_connection': deferConnection,
          'event_id': eventId,
          'is_scheduled_stream': isScheduledStream,
          'start_date_time': trackedStartDateTime ?? '',
        }
      ],
    );

    // Reset single-fire guards for the new stream lifecycle. Done here
    // (centralized funnel for all connect paths: host startStream, viewer
    // initializeAndJoinStream, scroll join, PK rejoin, copublisher reconnect)
    // instead of streamDispose to avoid the host-end vs viewer-leave race
    // where streamDispose during route teardown would prematurely re-arm
    // closeStreamView and cause a double Navigator.pop on an empty stack.
    _controller.resetOnStreamEndTrigger();

    // Store token for background lifecycle / deferred connect flows.
    // Persist for both host and viewer to support foreground rejoin with cached token.
    _controller.rtcToken = token;
    unawaited(_dbWrapper.saveValueSecurely(streamId, token));

    // When connecting to a different stream than the one we currently
    // hold data for, proactively clear any stale chat messages.
    //
    // The previous stream's `streamDispose()` (which clears the chat list)
    // runs via `IsmLiveUtility.updateLater` (next frame + 10ms). If the user
    // joins a new stream within that window, the next view can briefly show
    // the previous stream's chat. Skipped when `reJoin` is true so that
    // intentional preserve-state flows (PK guest, foreground rejoin) keep
    // their existing messages.
    if (!reJoin &&
        _controller.streamId != null &&
        _controller.streamId!.isNotEmpty &&
        _controller.streamId != streamId &&
        _controller.streamMessagesList.isNotEmpty) {
      _controller.streamMessagesList.clear();
    }

    // Subscribe to the stream
    final previousStreamId = _controller.streamId;
    _controller.streamId = streamId;
    if (previousStreamId != streamId) {
      _controller.realtimeStreamLikeCount = 0;
    }

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.streamConnectAttempt,
      properties: [
        {
          'stream_id': streamId,
          'is_host': isHost,
          'is_new_stream': isNewStream,
          're_join': reJoin,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          'is_copublisher': isCopublisher,
          'is_pk': isPk,
          'is_pk_guest': isPkGust,
          'hd_broadcast': hdBroadcast,
          'restream': restream,
          'defer_connection': deferConnection,
          'event_id': eventId,
          'is_scheduled_stream': isScheduledStream,
          'start_date_time': trackedStartDateTime ?? '',
        }
      ],
    );

    final hadExistingStreamDetails = _controller.streamDetails != null;
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
    if (hadExistingStreamDetails && startTime != null) {
      _controller.streamDetails =
          _controller.streamDetails?.copyWith(startDateTime: startTime);
    }

    // Reset callback trigger flag for new stream
    _controller._streamViewLoadedCallbackTriggered = false;

    // Set up background lifecycle management
    _controller.setStreamActive(
      true,
      isHost,
      isCopublisher: isCopublisher,
      isPkGuest: isPkGust,
    );

    // Show a loader while connecting
    _controller.isModerationWarningVisible = true;
    _controller.descriptionController.text =
        streamDiscription ?? _controller.descriptionController.text;

    _controller.pkStages = null;

    _controller.userRole =
        isHost ? IsmLiveUserRole.host() : IsmLiveUserRole.viewer();
    _controller.isViewerJoiningStream = !isHost;

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
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.connectStreamMqttSubscribeAttempt,
        properties: [
          {
            'stream_id': streamId,
            'is_host': isHost,
            'uses_custom_subscribe_callback':
                IsmLiveDelegate.subscribStreamById != null,
            'is_copublisher': isCopublisher,
            'has_mqtt_controller': _controller._mqttController != null,
          }
        ],
      );
      if (IsmLiveDelegate.subscribStreamById != null) {
        IsmLiveDelegate.subscribStreamById!(streamId);
      } else {
        if (!isCopublisher && _controller._mqttController != null) {
          // Don't block join/start on MQTT topic subscription/reconnect.
          unawaited(_controller._mqttController?.subscribeStream(streamId));
        }
      }
    } catch (e) {
      IsmLiveLog.error('MQTT subscription error: $e');
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.connectStreamMqttSubscribeFailure,
        properties: [
          {
            'stream_id': streamId,
            'error': e.toString(),
          }
        ],
      );
    }

    // If we want a snappier transition for host-initiated streams,
    // defer the heavy LiveKit connection to `stream_view` and navigate now.
    if (deferConnection && !joinByScrolling) {
      _controller.pendingConnection = true;
      try {
        final dummyRoom = lk.Room();
        final dummyListener = dummyRoom.createListener();

        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.connectStreamDeferredNavigationAttempt,
          properties: [
            {
              'stream_id': streamId,
              'is_host': isHost,
              'is_new_stream': isNewStream,
              're_join': reJoin,
              'is_scrolling': isScrolling,
              'duration_ms':
                  DateTime.now().difference(startedAt).inMilliseconds,
            }
          ],
        );

        await IsmLiveRouteManagement.goToStreamView(
          isHost: isHost,
          isNewStream: isNewStream,
          room: dummyRoom,
          isScrolling: isScrolling,
          streamImage: streamImage,
          listener: dummyListener,
          streamId: streamId,
          isInteractive: isInteractive,
          reJoin: reJoin,
        );
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.connectStreamDeferredNavigationSuccess,
          properties: [
            {
              'stream_id': streamId,
              'duration_ms':
                  DateTime.now().difference(startedAt).inMilliseconds,
            }
          ],
        );
      } catch (e, st) {
        IsmLiveLog.error('Navigation error (deferred connect): $e', st);
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.connectStreamDeferredNavigationFailure,
          properties: [
            {
              'stream_id': streamId,
              'duration_ms':
                  DateTime.now().difference(startedAt).inMilliseconds,
              'error': e.toString(),
            }
          ],
        );
      }
      return;
    }

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.connectRoomAndInitializeAttempt,
      properties: [
        {
          'stream_id': streamId,
          'is_host': isHost,
          'is_new_stream': isNewStream,
          're_join': reJoin,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          'duration_ms': 0,
          'start_date_time': trackedStartDateTime ?? '',
        }
      ],
    );

    try {
      await _connectRoomAndInitialize(
        stream: stream,
        token: token,
        streamId: streamId,
        streamImage: streamImage,
        streamDiscription: streamDiscription,
        hdBroadcast: hdBroadcast,
        restream: restream,
        isHost: isHost,
        isCopublisher: isCopublisher,
        isPk: isPk,
        isPkGust: isPkGust,
        isNewStream: isNewStream,
        joinByScrolling: joinByScrolling,
        isScrolling: isScrolling,
        isInteractive: isInteractive,
        startTime: startTime,
        context: context,
        eventId: eventId,
        reJoin: reJoin,
        isScheduledStream: isScheduledStream,
        products: products,
        performNavigation: !joinByScrolling,
        showLoader: true,
      );
    } catch (e) {
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.connectRoomAndInitializeFailure,
        properties: [
          {
            'stream_id': streamId,
            'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error': e.toString(),
          }
        ],
      );
      rethrow;
    }
  }

  Future<void> _connectRoomAndInitialize({
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
    required bool performNavigation,
    bool showLoader = true,
  }) async {
    final sw = Stopwatch()..start();
    var loaderShown = false;
    if (!joinByScrolling && showLoader) {
      // Show a generic loader; detailed user-facing message was already
      // computed in the calling method.
      IsmLiveUtility.showLoader();
      loaderShown = true;
    }

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.roomInitStart,
      properties: [
        {
          'stream_id': streamId,
          'event_id': eventId,
          'is_host': isHost,
          'is_new_stream': isNewStream,
          're_join': reJoin,
          'join_by_scrolling': joinByScrolling,
          'is_scrolling': isScrolling,
          'is_interactive': isInteractive,
          'perform_navigation': performNavigation,
          'defer_loader': !showLoader,
        }
      ],
    );

    try {
      // Setting video presets based on the hdBroadcast param
      final resolvedVideoParams = _resolveLkVideoParams(
        hdBroadcast: hdBroadcast,
        restream: restream,
      );

      // First join: use app delegate default. Host/co-publisher rejoin (e.g. after
      // background): keep last camera facing so back camera isnâ€™t reset to front.
      final lk.CameraPosition resolvedCameraPosition;
      final preserveCameraOnReconnect =
          reJoin && (isHost || isCopublisher || isPkGust);
      if (preserveCameraOnReconnect) {
        resolvedCameraPosition = _controller.position;
      } else {
        resolvedCameraPosition = (IsmLiveDelegate.initialCameraPositionStream ==
                IsmLiveCameraPosition.front)
            ? lk.CameraPosition.front
            : lk.CameraPosition.back;
        _controller.position = resolvedCameraPosition;
      }

      final previousRoom = _controller.room;
      // Listener is always bound to the previous room; drop it before disconnect.
      try {
        await _controller.listener?.dispose();
      } catch (e) {
        IsmLiveLog.error('Listener dispose error: $e');
      }
      _controller.listener = null;

      if (previousRoom != null) {
        try {
          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.previousRoomDisconnectAttempt,
            properties: [
              {
                'stream_id': streamId,
                're_join': reJoin,
              }
            ],
          );
          // Always await disconnect â€” not only when connectionState != disconnected.
          // If we skip this when the client already shows `disconnected`, the server
          // can still hold the participant and the next `connect` with the same
          // host token hits `DisconnectReason.duplicateIdentity` (camera drops
          // ~1s later when the server kicks the duplicate session).
          await previousRoom.disconnect();
        } catch (e) {
          IsmLiveLog.error('Previous room disconnect error: $e');
        }
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.previousRoomDisconnectDone,
          properties: [
            {
              'stream_id': streamId,
              'duration_ms': sw.elapsedMilliseconds,
            }
          ],
        );
        // Same-token rejoins (host) need a beat for the SFU to release identity.
        await Future.delayed(
          reJoin
              ? const Duration(milliseconds: 900)
              : const Duration(milliseconds: 400),
        );
      }

      lk.Room buildConfiguredRoom() => lk.Room(
            roomOptions: lk.RoomOptions(
              defaultCameraCaptureOptions: lk.CameraCaptureOptions(
                cameraPosition: resolvedCameraPosition,
                params: resolvedVideoParams,
              ),
              defaultAudioCaptureOptions: const lk.AudioCaptureOptions(
                noiseSuppression: true,
                echoCancellation: true,
                autoGainControl: true,
                highPassFilter: true,
                typingNoiseDetection: true,
              ),
              defaultVideoPublishOptions: lk.VideoPublishOptions(
                videoEncoding: resolvedVideoParams.encoding,
              ),
              defaultAudioPublishOptions: const lk.AudioPublishOptions(
                dtx: true,
              ),
              // SFU still fans out to many viewers; these client flags help per-device
              // CPU/bandwidth. Without adaptiveStream, remote video defaults to HIGH for
              // every subscriber (see livekit_client RemoteTrackPublication defaults).
              adaptiveStream: true,
              // Reduces publisher encode work for simulcast layers no subscriber needs.
              dynacast: true,
            ),
          );

      var room = buildConfiguredRoom();
      _controller.room = room;
      IsmLiveLog.info('Joining streamId(roomId): $streamId');

      // Create a listener before connecting.
      _controller.listener = room.createListener();

      // Pre-connect guard: if the stream was disposed while we were setting
      // up (e.g. viewer closed the view during the previous-room disconnect
      // delay), abort before the expensive room.connect() call. Without this,
      // the room would connect, start receiving remote audio, and the viewer
      // would hear the streamer even after leaving the view.
      if (_controller.streamId == null || _controller.streamId != streamId) {
        IsmLiveLog.info(
            'Stream disposed during room setup for $streamId, aborting connection');
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.preconnectAbortedStreamDisposed,
          properties: [
            {
              'stream_id': streamId,
              'current_stream_id': _controller.streamId ?? '',
              'duration_ms': sw.elapsedMilliseconds,
            }
          ],
        );
        try {
          _controller.listener?.dispose();
        } catch (_) {}
        _controller.listener = null;
        _controller.room = null;
        _controller.isViewerJoiningStream = false;
        if (loaderShown) {
          IsmLiveUtility.closeLoader();
        }
        return;
      }

      // Try to connect with one guarded retry for transport timeouts.
      // Rarely, socket/ICE setup can timeout in production and a fresh room
      // instance resolves it without requiring the user to manually re-enter.
      var connectAttempt = 1;
      while (true) {
        try {
          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.roomConnectAttempt,
            properties: [
              {
                'stream_id': streamId,
                'duration_ms': sw.elapsedMilliseconds,
                'attempt': connectAttempt,
              }
            ],
          );
          await room.connect(IsmLiveApis.wsUrl, token);
          break;
        } catch (e, st) {
          final isTimeoutError = e is TimeoutException ||
              e.toString().contains('TimeoutException');
          final canRetry = isTimeoutError &&
              connectAttempt == 1 &&
              _controller.streamId == streamId;

          IsmLiveLog.error(
              'Room connection error(attempt=$connectAttempt): $e', st);
          _controller.isViewerJoiningStream = false;

          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.roomConnectFailure,
            properties: [
              {
                'stream_id': streamId,
                'duration_ms': sw.elapsedMilliseconds,
                'error': e.toString(),
                'attempt': connectAttempt,
                'will_retry': canRetry,
              }
            ],
          );

          // Release failed room resources (WebSocket, ICE agents, etc.).
          try {
            await room.disconnect();
          } catch (_) {}

          if (!canRetry) {
            if (loaderShown) {
              IsmLiveUtility.closeLoader();
              loaderShown = false;
            }
            return;
          }

          try {
            await _controller.listener?.dispose();
          } catch (_) {}
          _controller.listener = null;

          // Brief cool-off gives backend/client transport state time to settle.
          await Future.delayed(const Duration(milliseconds: 1200));

          if (_controller.streamId != streamId) {
            if (loaderShown) {
              IsmLiveUtility.closeLoader();
              loaderShown = false;
            }
            return;
          }

          connectAttempt++;
          room = buildConfiguredRoom();
          _controller.room = room;
          _controller.listener = room.createListener();
        }
      }

      // Stale connection guard: if the user scrolled to a different stream
      // while ICE negotiation was in progress, discard this connection so
      // we don't overwrite state belonging to the newer stream.
      if (_controller.streamId != streamId) {
        IsmLiveLog.info(
            'Discarding stale connection for $streamId (current: ${_controller.streamId})');
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.roomConnectDiscardedStale,
          properties: [
            {
              'stream_id': streamId,
              'current_stream_id': _controller.streamId ?? '',
              'duration_ms': sw.elapsedMilliseconds,
            }
          ],
        );
        try {
          await room.disconnect();
        } catch (_) {}
        _controller.isViewerJoiningStream = false;
        if (loaderShown) {
          IsmLiveUtility.closeLoader();
        }
        return;
      }

      if (!isHost) {
        _controller.isViewerJoiningStream = false;
      }

      if (!isHost) {
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.streamJoin,
          properties: [
            {
              'stream_id': streamId,
              'event_id': eventId ?? stream?.eventId ?? '',
              'stream_description': stream?.streamDescription ??
                  _controller.streamDetails?.streamDescription ??
                  '',
              'start_date_time': (stream?.startDateTime ??
                          _controller.streamDetails?.startDateTime)
                      ?.toIso8601String() ??
                  '',
              'is_scheduled_stream': stream?.isScheduledStream ??
                  _controller.streamDetails?.isScheduledStream ??
                  false,
              'initiator_user_id': _controller.user?.userId ?? '',
              'initiator_user_name':
                  _controller.user?.userName ?? _controller.user?.name ?? '',
              'user_id': stream?.userId ??
                  stream?.userDetails?.id ??
                  _controller.streamDetails?.userId ??
                  _controller.streamDetails?.userDetails?.id ??
                  '',
              'user_name': stream?.userDetails?.userName ??
                  stream?.userDetails?.name ??
                  _controller.streamDetails?.userDetails?.userName ??
                  _controller.streamDetails?.userDetails?.name ??
                  '',
            }
          ],
        );
      }
      if (isHost && isNewStream) {
        IsmLiveDelegate.trackEvent(
          IsmLiveAnalyticsEvent.streamStarted,
          properties: [
            {
              'stream_id': streamId,
              'event_id': eventId ?? '',
              'is_scheduled_stream': isScheduledStream ?? false,
              'user_id': _controller.user?.userId ?? '',
              'user_name':
                  _controller.user?.userName ?? _controller.user?.name ?? '',
            }
          ],
        );
      }

      // Route audio to the loudspeaker. Mobile WebRTC defaults to the
      // earpiece; live-stream participants expect loudspeaker output.
      // The helper respects external devices (Bluetooth/wired) on Android.
      // withRetry: true schedules retries to guard against WebRTC resetting
      // the audio route when remote tracks arrive.
      await _ensureLoudspeakerRouting(withRetry: true, forRoom: room);

      // Store the token for background lifecycle reconnection
      _controller.storeToken(token);

      // Allow every participant to subscribe to our published tracks.
      void applyOpenSubscriptionPermissions() {
        try {
          room.localParticipant?.setTrackSubscriptionPermissions(
            allParticipantsAllowed: true,
          );
        } catch (e) {
          IsmLiveLog.error('Track subscription permissions error: $e');
        }
      }

      applyOpenSubscriptionPermissions();

      // Enable video if the user is a host or copublisher.
      // RTMP host ingests via OBS; only co-publishers / PK guests publish from the app.
      final shouldPublishFromDevice =
          isCopublisher || isPkGust || (!_controller.isRtmp && isHost);
      if (shouldPublishFromDevice) {
        try {
          await enableMyVideo();
          // Re-send after publish so co-publisher camera tracks are subscribable.
          applyOpenSubscriptionPermissions();
          unawaited(
            _controller.toggleAudio(
              value: isHost || isCopublisher,
            ),
          );
        } catch (e) {
          IsmLiveLog.error('Video/Audio enable error: $e');
        }
      }

      // iOS audio-session fix for viewer â†’ copublisher promotion:
      // After disconnectâ†’reconnect the AVAudioSession can remain in
      // playback-only mode. We post synthetic AVAudioSession interruption
      // notifications (began â†’ ended/shouldResume) which is exactly what
      // iOS does on backgroundâ†’foreground â€” forcing WebRTC's RTCAudioSession
      // to tear down and rebuild its audio unit with playAndRecord.
      if (Platform.isIOS && isCopublisher) {
        unawaited(Future.delayed(
          const Duration(milliseconds: 1200),
          () async {
            if (_controller.room?.connectionState !=
                lk.ConnectionState.connected) {
              return;
            }
            try {
              await _controller._liveStreamBridge.reactivateAudioSession();
              // Re-apply speaker routing after the interruption cycle
              // completes (~300ms internal delay in native side).
              await Future.delayed(const Duration(milliseconds: 500));
              if (_controller.room?.connectionState ==
                  lk.ConnectionState.connected) {
                lk.Hardware.instance.setSpeakerphoneOn(true);
              }
            } catch (e) {
              IsmLiveLog.error('iOS audio session reactivation error: $e');
            }
          },
        ));
      }

      if (loaderShown) {
        IsmLiveUtility.closeLoader();
        loaderShown = false;
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

      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.postConnectApiKickoff,
        properties: [
          {
            'stream_id': streamId,
            'is_host': isHost,
            'duration_ms': sw.elapsedMilliseconds,
          }
        ],
      );

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
      }

      startStreamTimer();

      if (performNavigation) {
        try {
          IsmLiveGifts.threeD.map((e) => IsmLiveGif.preCache(e.path, context));
          IsmLiveGifts.animated
              .map((e) => IsmLiveGif.preCache(e.path, context));
        } catch (e) {
          IsmLiveLog.error('Gift pre-cache error: $e');
        }
        try {
          // Check if listener is null before calling goToStreamView
          if (_controller.listener == null) {
            IsmLiveLog.error('Cannot join stream: listener is null');
            return;
          }

          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.goToStreamViewAttempt,
            properties: [
              {
                'stream_id': streamId,
                'is_host': isHost,
                're_join': reJoin,
                'duration_ms': sw.elapsedMilliseconds,
              }
            ],
          );

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

          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.goToStreamViewSuccess,
            properties: [
              {
                'stream_id': streamId,
                'duration_ms': sw.elapsedMilliseconds,
              }
            ],
          );
        } catch (e) {
          IsmLiveLog.error('Navigation error: $e');
          IsmLiveDelegate.trackEvent(
            IsmLiveAnalyticsEvent.goToStreamViewFailure,
            properties: [
              {
                'stream_id': streamId,
                'duration_ms': sw.elapsedMilliseconds,
                'error': e.toString(),
              }
            ],
          );
        }
      }
    } catch (e, st) {
      _controller.isViewerJoiningStream = false;
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
      IsmLiveDelegate.trackEvent(
        IsmLiveAnalyticsEvent.connectFlowOuterFailure,
        properties: [
          {
            'stream_id': streamId,
            'duration_ms': sw.elapsedMilliseconds,
            'error': e.toString(),
          }
        ],
      );
    } finally {
      sw.stop();
      if (loaderShown) {
        IsmLiveUtility.closeLoader();
      }
    }
  }

  /// Completes a previously deferred LiveKit connection from `stream_view`.
  Future<void> completeDeferredConnection({
    required BuildContext context,
    required bool isHost,
    required bool isNewStream,
    required bool isInteractive,
    required bool isSchedule,
  }) async {
    if (!_controller.pendingConnection ||
        _controller.rtcToken == null ||
        _controller.streamId == null) {
      return;
    }

    final token = _controller.rtcToken!;
    final streamId = _controller.streamId!;
    final details = _controller.streamDetails;

    final streamImage = details?.streamImage;
    final streamDiscription =
        details?.streamDescription ?? _controller.descriptionController.text;
    final hdBroadcast = details?.hdBroadcast ?? _controller.isHdBroadcast;
    final restream = details?.restream ?? _controller.isRestreamBroadcast;

    // Capture the flag early. If onStreamScroll clears pendingConnection
    // while _connectRoomAndInitialize is awaiting room.connect(), the stale
    // connection guard inside _connectRoomAndInitialize will detect the
    // streamId mismatch and discard the connection automatically.
    _controller.pendingConnection = false;

    await _connectRoomAndInitialize(
      stream: details,
      token: token,
      streamId: streamId,
      streamImage: streamImage,
      streamDiscription: streamDiscription,
      hdBroadcast: hdBroadcast,
      restream: restream,
      isHost: isHost,
      isCopublisher: false,
      isPk: details?.isPkChallenge ?? false,
      isPkGust: false,
      isNewStream: isNewStream,
      joinByScrolling: false,
      isScrolling: false,
      isInteractive: isInteractive,
      startTime: details?.startDateTime,
      context: context,
      eventId: details?.eventId,
      reJoin: false,
      isScheduledStream: details?.isScheduledStream ?? isSchedule,
      products: details?.products,
      performNavigation: false,
      showLoader: false,
    );
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
    } else {
      _controller.streamDuration = Duration.zero;
    }

    _controller.streamTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        try {
          if (_controller._streamStartTime != null) {
            // Use wall-clock elapsed time so app background pauses (notably iOS)
            // don't freeze the stream timer.
            final elapsed =
                DateTime.now().difference(_controller._streamStartTime!);
            _controller.streamDuration =
                elapsed.isNegative ? Duration.zero : elapsed;
          } else {
            _controller.streamDuration += const Duration(
              seconds: 1,
            );
          }
          final currentStreamId = _controller.streamId;
          final currentSeconds = _controller.streamDuration.inSeconds;
          if (currentStreamId != null &&
              currentStreamId.isNotEmpty &&
              currentSeconds > 0 &&
              currentSeconds % 30 == 0) {
            final isHost = _controller.isHost;
            if (_controller._lastHeartbeatStreamId == currentStreamId &&
                _controller._lastHeartbeatSecondEmitted == currentSeconds) {
              return;
            }
            _controller._lastHeartbeatStreamId = currentStreamId;
            _controller._lastHeartbeatSecondEmitted = currentSeconds;
            IsmLiveDelegate.trackEvent(
              IsmLiveAnalyticsEvent.streamHeartbeat,
              properties: [
                {
                  'stream_id': currentStreamId,
                  'watch_duration_seconds': currentSeconds,
                  'is_host': isHost,
                  'participant_role': isHost ? 'host' : 'viewer',
                  'user_id': _controller.user?.userId ?? '',
                  'user_name': _controller.user?.userName ??
                      _controller.user?.name ??
                      '',
                }
              ],
            );
          }
        } catch (e) {
          IsmLiveLog.error('Stream timer tick error: $e');
          timer.cancel(); // Stops the timer permanently
          return;
        }
      },
    );
  }
}