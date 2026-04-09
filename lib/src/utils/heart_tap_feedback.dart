import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Like/heart control feedback: native vibrator / haptic only (no click sound).
/// On channel failure, falls back to Flutter `HapticFeedback` (WebRTC can make the
/// engine haptic channel less reliable than native).
class IsmLiveHeartTapFeedback {
  IsmLiveHeartTapFeedback._();

  static const MethodChannel _channel =
      MethodChannel('appscrip_live_stream_component');

  /// Safe to call from a control tap handler (fire-and-forget).
  static void trigger() {
    if (kIsWeb) return;
    unawaited(_invoke());
  }

  static Future<void> _invoke() async {
    try {
      await _channel.invokeMethod<void>('heartTapFeedback');
    } catch (_) {
      await HapticFeedback.mediumImpact();
    }
  }
}
