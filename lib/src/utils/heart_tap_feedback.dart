import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Like/heart control feedback: prefers native vibrator + system tone on mobile.
/// Flutter's `SystemSound.play` is often silent on Android; WebRTC can make the
/// Flutter haptic channel feel unreliable.
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
      // await SystemSound.play(SystemSoundType.click);
    }
  }
}
