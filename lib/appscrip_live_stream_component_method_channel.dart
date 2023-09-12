import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'appscrip_live_stream_component_platform_interface.dart';

/// An implementation of [AppscripLiveStreamComponentPlatform] that uses method channels.
class MethodChannelAppscripLiveStreamComponent extends AppscripLiveStreamComponentPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('appscrip_live_stream_component');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
