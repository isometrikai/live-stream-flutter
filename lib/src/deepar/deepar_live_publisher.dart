import 'dart:async';
import 'dart:io';

import 'package:appscrip_live_stream_component/src/deepar/deepar_config.dart';
import 'package:appscrip_live_stream_component/src/deepar/deepar_effect.dart';
import 'package:appscrip_live_stream_component/src/deepar/external_video_source.dart';
import 'package:appscrip_live_stream_component/src/utils/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_deepar/flutter_deepar.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
// ignore: implementation_imports
import 'package:flutter_webrtc/src/native/media_stream_impl.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

/// Owns DeepAR capture and forwards processed frames into a LiveKit
/// [lk.LocalVideoTrack] via a native external WebRTC video source.
class IsmLiveDeepArPublisher {
  IsmLiveDeepArPublisher(this.config);

  final IsmLiveDeepArConfig config;

  final DeepARController _deepAr = DeepARController();
  StreamSubscription<DeepARFrame>? _frameSub;
  webrtc.MediaStream? _mediaStream;
  lk.LocalVideoTrack? _videoTrack;
  IsmLiveDeepArEffect _currentEffect = IsmLiveDeepArEffect.none;
  bool _started = false;
  bool _pushInFlight = false;
  bool _isFrontCamera = true;
  int _frameCount = 0;
  int _droppedCount = 0;

  bool get isStarted => _started;
  bool get isFrontCamera => _isFrontCamera;
  IsmLiveDeepArEffect get currentEffect => _currentEffect;
  lk.LocalVideoTrack? get videoTrack => _videoTrack;

  /// Initializes DeepAR + external track and begins frame forwarding.
  ///
  /// Returns a LiveKit camera [lk.LocalVideoTrack] ready to publish, or
  /// throws if setup fails (caller should fall back to normal camera).
  Future<lk.LocalVideoTrack> start({
    required bool frontCamera,
    lk.VideoParameters? params,
  }) async {
    if (_started) {
      final existing = _videoTrack;
      if (existing != null) return existing;
    }

    final licenseKey = config.licenseKeyForPlatform;
    if (licenseKey == null || licenseKey.isEmpty) {
      throw StateError('DeepAR license key missing for this platform');
    }

    final width = config.outputWidth;
    final height = config.outputHeight;

    final initialized = await _deepAr.initialize(
      licenseKey: licenseKey,
      outputWidth: width,
      outputHeight: height,
    );
    if (!initialized) {
      throw StateError('DeepAR initialize failed');
    }

    final response = await IsmLiveExternalVideoSource.createTrack(
      width: width,
      height: height,
    );
    final streamId = response['streamId'] as String;
    final stream = MediaStreamNative(streamId, 'local');
    stream.setMediaTracks(
      response['audioTracks'] ?? const <dynamic>[],
      response['videoTracks'] ?? const <dynamic>[],
    );
    _mediaStream = stream;

    final videoTracks = stream.getVideoTracks();
    if (videoTracks.isEmpty) {
      throw StateError('External video track missing');
    }

    // ignore: invalid_use_of_internal_member
    _videoTrack = lk.LocalVideoTrack(
      lk.TrackSource.camera,
      stream,
      videoTracks.first,
      lk.CameraCaptureOptions(
        cameraPosition:
            frontCamera ? lk.CameraPosition.front : lk.CameraPosition.back,
        params: params ?? lk.VideoParametersPresets.h720_169,
      ),
    );

    _frameSub = _deepAr.frameStream.listen(_onFrame, onError: (Object e) {
      IsmLiveLog.error('DeepAR frameStream error: $e');
    });

    _isFrontCamera = frontCamera;
    await _deepAr.startCapture(front: frontCamera);

    _currentEffect = config.resolveDefaultEffect();
    await applyEffect(_currentEffect);

    _started = true;
    IsmLiveLog.info(
      'DeepAR publisher started (${width}x$height, front=$frontCamera)',
    );
    return _videoTrack!;
  }

  void _onFrame(DeepARFrame frame) {
    if (!_started) return;
    // Backpressure: drop if previous push still in flight.
    if (_pushInFlight) {
      _droppedCount++;
      return;
    }
    _pushInFlight = true;
    _frameCount++;
    IsmLiveExternalVideoSource.pushFrame(
      data: frame.data,
      width: frame.width,
      height: frame.height,
      format: frame.format,
      timestampMs: frame.timestamp,
      // Do NOT bake a horizontal flip into published frames. DeepAR's output
      // (incl. watermark) is already correctly oriented; flipping made
      // "DeepAR.ai" render backwards and on the wrong side.
      mirror: false,
    ).catchError((Object e) {
      if (_frameCount <= 3 || _frameCount % 500 == 0) {
        IsmLiveLog.error('DeepAR pushExternalVideoFrame #$_frameCount: $e');
      }
    }).whenComplete(() => _pushInFlight = false);
  }

  Future<void> applyEffect(IsmLiveDeepArEffect effect) async {
    _currentEffect = effect;
    if (!_deepAr.isInitialized) return;
    if (effect.isNone) {
      await _deepAr.clearEffect();
    } else {
      await _deepAr.loadEffect(effect.assetPath);
    }
  }

  Future<void> switchCamera() async {
    if (!_started) return;
    final facing = await _deepAr.switchCamera();
    if (facing != null) {
      _isFrontCamera = facing;
    } else {
      _isFrontCamera = !_isFrontCamera;
    }
  }

  Future<void> stop() async {
    _started = false;
    await _frameSub?.cancel();
    _frameSub = null;
    try {
      await _deepAr.stopCapture();
    } catch (_) {}
    try {
      await _deepAr.dispose();
    } catch (_) {}
    try {
      await _videoTrack?.stop();
    } catch (_) {}
    _videoTrack = null;
    try {
      await _mediaStream?.dispose();
    } catch (_) {}
    _mediaStream = null;
    try {
      await IsmLiveExternalVideoSource.disposeTrack();
    } catch (_) {}
    IsmLiveLog.info(
      'DeepAR publisher stopped (sent $_frameCount, dropped $_droppedCount)',
    );
    _frameCount = 0;
    _droppedCount = 0;
  }

  /// Convenience: whether DeepAR should be attempted on this process.
  static bool shouldUse(IsmLiveDeepArConfig? config) {
    if (config == null || !config.isActive) return false;
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}
