part of '../stream_controller.dart';

mixin StreamOngoingChatMixin on StreamOngoingMixin {
  /// Stop MQTT-disconnected chat fallback polling (used on app background).
  void pauseMqttDisconnectedChatFallback() {
    _stopMqttDisconnectedChatFallback();
  }

  /// Resume MQTT-disconnected chat fallback polling if needed (used on resume).
  void resumeMqttDisconnectedChatFallbackIfNeeded() {
    final streamId = _controller.streamId;
    if (streamId == null || streamId.isEmpty) return;
    if (_controller.isInBackground) return;
    _controller.nudgeMqttReconnectAfterAppResume();

    if (IsmLiveApp.isMqttConnected) {
      // Even when `isMqttConnected` reports true, mobile OSes commonly
      // suspend the MQTT socket while backgrounded, and the broker is not
      // guaranteed to replay messages that arrived during the suspend
      // window. Without a one-shot API catch-up here, messages other users
      // sent while we were backgrounded never appear after foregrounding.
      // Duplicates with live MQTT delivery are safely deduped via
      // IsmLiveChatModel equality (streamId + messageId).
      unawaited(_fetchChatCatchUpMessages(streamId));
      return;
    }
    unawaited(_startMqttDisconnectedChatFallback(streamId));
  }

  void _setupMqttDisconnectedChatFallback({
    required String streamId,
  }) {
    _stopMqttDisconnectedChatFallback();
    _controller._mqttChatFallbackConnSubscription?.cancel();
    _controller._mqttChatFallbackConnSubscription =
        IsmLiveApp.isMqttConnectedRx.stream.listen((connected) {
      if (connected) {
        // MQTT is back: stop interval mechanism immediately.
        _stopMqttDisconnectedChatFallback();
        return;
      }

      // MQTT disconnected: start interval mechanism (if not already running).
      if (!_controller.isInBackground) {
        unawaited(_startMqttDisconnectedChatFallback(streamId));
      }
    });

    // Start immediately if MQTT is already disconnected at join time.
    if (!IsmLiveApp.isMqttConnected) {
      unawaited(_startMqttDisconnectedChatFallback(streamId));
    }
  }

  void _stopMqttDisconnectedChatFallback() {
    _controller._mqttChatFallbackTimer?.cancel();
    _controller._mqttChatFallbackTimer = null;
    _controller._mqttChatFallbackInFlight = false;
  }

  Future<void> _startMqttDisconnectedChatFallback(String streamId) async {
    if (_controller.isInBackground) return;
    if (IsmLiveApp.isMqttConnected) return;
    if (_controller._mqttChatFallbackTimer != null) return;

    // If we have no messages yet, do a one-time initial catch-up using the
    // existing pagination API.
    if (_controller.streamMessagesList.isEmpty) {
      await _controller.fetchMessagesCount(
        showLoading: false,
        getMessageModel: IsmLiveGetMessageModel(
          streamId: streamId,
          messageType:
              IsmLiveDelegate.streamScreenConfigure.resolvedChatMessageTypes,
        ),
      );

      if (_controller.messagesCount != 0) {
        await _controller.fetchMessages(
          showLoading: false,
          getMessageModel: IsmLiveGetMessageModel(
            streamId: streamId,
            messageType:
              IsmLiveDelegate.streamScreenConfigure.resolvedChatMessageTypes,
            sort: 1,
            skip: _controller.messagesCount < 10
                ? 0
                : (_controller.messagesCount - 10),
            limit: 10,
            senderIdsExclusive: false,
          ),
        );
      }
    }

    // Interval mechanism: run only while MQTT is disconnected.
    final interval = IsmLiveDelegate.mqttChatFallbackInterval;
    final safeInterval =
        interval.inMilliseconds <= 0 ? const Duration(seconds: 6) : interval;
    _controller._mqttChatFallbackTimer = Timer.periodic(
      safeInterval,
      (timer) => unawaited(_pollNewMqttMessages(streamId)),
    );
    // Immediate run so we don't wait for the first tick.
    unawaited(_pollNewMqttMessages(streamId));
  }

  Future<void> _pollNewMqttMessages(String streamId) async {
    // Only fetch while MQTT is disconnected.
    if (IsmLiveApp.isMqttConnected) {
      _stopMqttDisconnectedChatFallback();
      return;
    }
    await _fetchChatCatchUpMessages(streamId);
  }

  /// Shared chat catch-up fetch. Two callers:
  ///   1. The periodic MQTT-disconnected poll [_pollNewMqttMessages] â€”
  ///      runs only while MQTT is down so the chat keeps updating.
  ///   2. The foreground resume path
  ///      [resumeMqttDisconnectedChatFallbackIfNeeded] â€” runs once on
  ///      foreground regardless of MQTT state, to recover messages that
  ///      arrived while the OS had the MQTT socket suspended in background.
  ///
  /// Skips during background and dedupes concurrent callers via
  /// `_controller._mqttChatFallbackInFlight`. Uses since-timestamp fetch on
  /// subsequent runs so existing messages are not refetched, and falls back
  /// to the pagination API when the local list is still empty.
  Future<void> _fetchChatCatchUpMessages(String streamId) async {
    if (_controller.isInBackground) return;
    if (_controller._mqttChatFallbackInFlight) return;
    _controller._mqttChatFallbackInFlight = true;
    try {
      if (_controller.streamId == null || _controller.streamId!.isEmpty) {
        return;
      }

      // If there are no messages yet (e.g. host joined while MQTT was connected),
      // do a one-time initial catch-up using the existing pagination API.
      if (_controller.streamMessagesList.isEmpty) {
        await _controller.fetchMessagesCount(
          showLoading: false,
          getMessageModel: IsmLiveGetMessageModel(
            streamId: streamId,
            messageType:
              IsmLiveDelegate.streamScreenConfigure.resolvedChatMessageTypes,
          ),
        );

        if (_controller.messagesCount != 0) {
          await _controller.fetchMessages(
            showLoading: false,
            getMessageModel: IsmLiveGetMessageModel(
              streamId: streamId,
              messageType:
              IsmLiveDelegate.streamScreenConfigure.resolvedChatMessageTypes,
              sort: 1,
              skip: _controller.messagesCount < 10
                  ? 0
                  : (_controller.messagesCount - 10),
              limit: 10,
              senderIdsExclusive: false,
            ),
          );
        }
        return;
      }

      // Use only non-event chat messages as the cursor for normal-message
      // catch-up. If we include event/system items, a newer event timestamp can
      // move the cursor past normal chat messages sent by others while we were
      // backgrounded, causing them to be skipped.
      final lastTimestampMs = _controller.streamMessagesList
          .where((m) => !m.isEvent)
          .map((m) => m.timeStamp.millisecondsSinceEpoch)
          .fold<int>(0, (prev, ms) => ms > prev ? ms : prev);

      if (lastTimestampMs == 0) return;

      await _controller.fetchNewMessagesSinceTimestamp(
        streamId: streamId,
        // Some backends treat `lastMessageTimestamp` as inclusive (>=).
        // Bump by 1ms so we truly fetch "newer than" and avoid duplicating the
        // most recent message on foreground resume / reconnect polls.
        lastMessageTimestamp: lastTimestampMs + 1,
        limit: 10,
        showDialog: false,
      );
    } catch (e, st) {
      IsmLiveLog.error('MQTT chat fallback poll failed: $e', st);
    } finally {
      _controller._mqttChatFallbackInFlight = false;
    }
  }

// Function to manage moderator status
  void _manageModerator(String streamId) async {
    /// this is to check user is a moderator or not via API call
    /// By passing User name in search tag  it will give us the filtered list
    await _controller._fetchModerators(
      streamId: streamId,
      searchTag: _controller.user?.userName,
    );

    if (!Get.isRegistered<IsmLiveStreamController>()) return;

    var isModerator = _controller.moderatorsList.any(
      (e) => e.userId == _controller.user?.userId,
    );

    if (isModerator) {
      _controller.userRole?.makeModerator();
    } else {
      _controller.userRole?.leaveModeration();
    }

    _controller.update();

    ///This is to update the List of moderators without search
    unawaited(_controller.fetchModerators(
      forceFetch: true,
      streamId: streamId,
    ));
  }

  // Function to add viewers to the stream
  Future<void> addViewers(
      List<IsmLiveViewerModel> viewers, bool isFirstCall) async {
    if (isFirstCall) {
      _controller.streamViewersList.clear();
    }
    if (viewers.isEmpty) {
      return;
    }
    final list = List<IsmLiveViewerModel>.from(_controller.streamViewersList);
    for (final v in viewers) {
      if (v.userId.isEmpty) {
        continue;
      }
      final i = list.indexWhere((e) => e.userId == v.userId);
      if (i >= 0) {
        list[i] = v;
      } else {
        list.add(v);
      }
    }
    _controller.streamViewersList = list;
  }

// Function to add messages to the stream
  Future<void> addMessages(
    List<IsmLiveMessageModel> messages, [
    bool isMqtt = true,
  ]) async {
    if (messages.isEmpty) {
      return;
    }

    final chats =
        messages.map((e) => _controller.convertMessageToChat(e)).toList();

    if (isMqtt) {
      _controller.streamMessagesList.addAll(chats);
    } else {
      _controller.streamMessagesList.insertAll(0, chats);
    }

    _controller.streamMessagesList =
        _controller.streamMessagesList.toSet().toList();
  }
}
