import 'package:appscrip_live_stream_component/src/utils/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Opens the OS app-settings page so the user can enable permissions.
class IsmLiveAppSettings {
  IsmLiveAppSettings._();

  static const MethodChannel _channel =
      MethodChannel('appscrip_live_stream_component');

  /// Prefer the plugin channel (reliable Android intent). Falls back to
  /// [permission_handler]'s [ph.openAppSettings] if the channel fails.
  static Future<bool> open() async {
    if (kIsWeb) return false;
    try {
      final opened = await _channel.invokeMethod<bool>('openAppSettings');
      if (opened == true) return true;
    } catch (e) {
      IsmLiveLog.error('Native openAppSettings failed: $e');
    }
    try {
      return await ph.openAppSettings();
    } catch (e) {
      IsmLiveLog.error('permission_handler openAppSettings failed: $e');
      return false;
    }
  }
}
