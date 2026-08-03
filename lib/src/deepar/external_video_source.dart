import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Native WebRTC external video track used to publish DeepAR frames to LiveKit.
///
/// Creates a local `MediaStream` + video track via `flutter_webrtc`'s
/// `PeerConnectionFactory`, then accepts raw RGBA/BGRA frames.
class IsmLiveExternalVideoSource {
  IsmLiveExternalVideoSource._();

  static const _channel = MethodChannel('appscrip_live_stream_component');

  /// Creates an empty external video track.
  ///
  /// Returns a map shaped like `getUserMedia`:
  /// `{ streamId, audioTracks: [], videoTracks: [{ id, kind, ... }] }`.
  static Future<Map<dynamic, dynamic>> createTrack({
    required int width,
    required int height,
    int fps = 30,
  }) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'createExternalVideoTrack',
      {
        'width': width,
        'height': height,
        'fps': fps,
      },
    );
    if (result == null) {
      throw StateError('createExternalVideoTrack returned null');
    }
    return result;
  }

  /// Pushes one AR-processed frame into the active external track.
  static Future<void> pushFrame({
    required Uint8List data,
    required int width,
    required int height,
    required String format,
    required int timestampMs,
    int rotation = 0,
    bool mirror = false,
  }) {
    return _channel.invokeMethod<void>(
      'pushExternalVideoFrame',
      {
        'data': data,
        'width': width,
        'height': height,
        'format': format,
        'timestampMs': timestampMs,
        'rotation': rotation,
        'mirror': mirror,
      },
    );
  }

  /// Releases the external track / capturer.
  static Future<void> disposeTrack() {
    return _channel.invokeMethod<void>('disposeExternalVideoTrack');
  }
}
