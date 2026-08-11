part of '../stream_controller.dart';

mixin StreamOngoingSocialMixin on StreamOngoingMixin {
  static const int _heartFlushThreshold = 8;

  void addHeart(IsmLiveMessageModel message, {int count = 1}) {
    if (count <= 0) return;
    for (var i = 0; i < count; i++) {
      _heartSpawnQueue.add('${message.messageId}_$i');
    }
    if (_heartDrainTimer == null) {
      _drainNextHeart();
    }
  }

  /// Constant drain interval so that 8 hearts (one flush) drain in ~1050ms,
  /// closely matching the sender's inter-flush cadence at fast tap rates.
  /// This keeps the queue from emptying before the next MQTT batch arrives.
  static const int _heartDrainIntervalMs = 150;

  void _drainNextHeart() {
    _heartDrainTimer?.cancel();
    _heartDrainTimer = null;
    if (_heartSpawnQueue.isEmpty) return;
    final id = _heartSpawnQueue.removeAt(0);
    _insertHeartAnimation(id);
    if (_heartSpawnQueue.isNotEmpty) {
      _heartDrainTimer = Timer(
        const Duration(milliseconds: _heartDrainIntervalMs),
        _drainNextHeart,
      );
    }
  }

  void _addLocalHeart() {
    final id = 'local_${_heartIdCounter++}';
    _insertHeartAnimation(id);
  }

  void _insertHeartAnimation(String id) {
    final key = ValueKey(id);
    final seed = id.hashCode & 0x7fffffff;
    final startX = ((seed % 31) - 15).toDouble();
    final durationMs = 2500 + (seed % 1500);
    final pathVariant = seed % 6;
    final maxHorizontalDrift = 18 + (seed % 24).toDouble();
    final travelHeightFactor = 0.74 + (((seed >> 3) % 14) / 100);
    final baseScale = 0.42 + (((seed >> 5) % 42) / 100);
    _controller.heartList.insert(
      0,
      IsmLiveFloatingHeartView(
        key: key,
        durationMs: durationMs,
        startX: startX,
        maxHorizontalDrift: maxHorizontalDrift,
        pathVariant: pathVariant,
        travelHeightFactor: travelHeightFactor,
        child: Transform.scale(
          scale: baseScale,
          child: IsmLiveHeartButton(size: IsmLiveDimens.fifty),
        ),
        onComplete: () {
          _controller.heartList.removeWhere((e) => e.key == key);
        },
      ),
    );
  }

  void _scheduleHeartFlush() {
    _pendingHeartCount++;
    if (_pendingHeartCount >= _heartFlushThreshold) {
      _heartDebounceTimer?.cancel();
      _heartDebounceTimer = null;
      _flushPendingHearts();
      return;
    }
    _heartDebounceTimer?.cancel();
    _heartDebounceTimer = Timer(
      const Duration(milliseconds: 500),
      _flushPendingHearts,
    );
  }

  void _flushPendingHearts() {
    final count = _pendingHeartCount;
    _pendingHeartCount = 0;
    _heartDebounceTimer?.cancel();
    _heartDebounceTimer = null;
    if (count <= 0) return;
    final streamId = _controller.streamId ?? '';
    if (streamId.isEmpty) return;
    unawaited(_flushHeartsWithDelegate(streamId, count));
  }

  Future<void> _flushHeartsWithDelegate(String streamId, int count) async {
    await _controller.sendHeartMessage(streamId, count: count);
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.streamReaction,
      properties: [
        {
          'stream_id': streamId,
          'is_host': _controller.isHost,
          'reaction_count': count,
          'user_id': _controller.user?.userId ?? '',
          'user_name':
              _controller.user?.userName ?? _controller.user?.name ?? '',
        }
      ],
    );
    final delegate = IsmLiveDelegate.streamScreenConfigure.heartBatchFlushCallback;
    if (delegate != null) {
      unawaited(_invokeHeartBatchFlushDelegate(delegate, streamId, count));
    } else {
      unawaited(_invokeInternalHeartBatchFlush(streamId, count));
    }
  }

  Future<void> _invokeInternalHeartBatchFlush(
    String streamId,
    int count,
  ) async {
    try {
      final senderId = _controller.user?.userId ?? '';
      if (senderId.isEmpty) return;
      await _controller.sendHearts(
        streamId: streamId,
        senderId: senderId,
        likeCount: count,
        sentViaMqtt: true,
      );
    } catch (e, st) {
      IsmLiveLog.error('sendHearts (stream/like) error: $e', st);
    }
  }

  Future<void> _invokeHeartBatchFlushDelegate(
    HeartBatchFlushCallback delegate,
    String streamId,
    int count,
  ) async {
    try {
      await delegate(streamId, count);
    } catch (e, st) {
      IsmLiveLog.error('heartBatchFlushCallback error: $e', st);
    }
  }

  void cancelHeartDebounce() {
    _heartDebounceTimer?.cancel();
    _heartDebounceTimer = null;
    _pendingHeartCount = 0;
    _heartIdCounter = 0;
    _heartDrainTimer?.cancel();
    _heartDrainTimer = null;
    _heartSpawnQueue.clear();
    _lastHeartbeatSecondEmitted = -1;
    _lastHeartbeatStreamId = null;
  }

  // Function to add gift message to the stream
  void addGift(IsmLiveMessageModel message, Map<String, dynamic> payload) {
    _controller.giftMessages.add(message);
    if (_controller.giftMessages.length == 1) {
      _handleGift(message, payload);
    }
  }

  void _handleGift(IsmLiveMessageModel message, Map<String, dynamic> payload) {
    if (message.customType == null) {
      return;
    }
    final key = ValueKey(message.messageId);

    final data = payload['metaData'];
    final giftPath = data is Map ? data['message']?.toString() ?? '' : '';

    final child = IsmLiveGif(path: giftPath);
    _controller.giftList.insert(
      0,
      IsmLiveGiftView(
        key: key,
        child: child,
        onComplete: () {
          _controller.giftList.removeWhere((e) => e.key == key);
          _controller.giftMessages.removeAt(0);
          if (_controller.giftMessages.isNotEmpty) {
            _handleGift(_controller.giftMessages.first, payload);
          }
        },
      ),
    );
  }

}