part of '../stream_controller.dart';

/// Shared stream-session state and heart-queue fields used across ongoing mixins.
mixin StreamOngoingMixin {
  IsmLiveStreamController get _controller => Get.find();
  IsmLivePkController get _pkController => Get.find();

  // Debouncer to handle sorting of participants
  final _participantDebouncer = IsmLiveDebouncer();

  Timer? _heartDebounceTimer;
  int _pendingHeartCount = 0;
  int _heartIdCounter = 0;
  int _lastHeartbeatSecondEmitted = -1;
  String? _lastHeartbeatStreamId;

  /// Single queue that all incoming heart IDs feed into. A self-scheduling
  /// drain timer pulls one heart at a time, so batch boundaries from MQTT
  /// flushes (e.g. 15 + 15) become invisible — hearts just stream out of one
  /// pipe at an adaptive rate.
  final List<String> _heartSpawnQueue = [];
  Timer? _heartDrainTimer;
}
