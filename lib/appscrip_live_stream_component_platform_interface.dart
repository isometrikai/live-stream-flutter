import 'package:appscrip_live_stream_component/appscrip_live_stream_component_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class AppscripLiveStreamComponentPlatform extends PlatformInterface {
  /// Constructs a AppscripLiveStreamComponentPlatform.
  AppscripLiveStreamComponentPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppscripLiveStreamComponentPlatform _instance =
      MethodChannelAppscripLiveStreamComponent();

  /// The default instance of [AppscripLiveStreamComponentPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppscripLiveStreamComponent].
  static AppscripLiveStreamComponentPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppscripLiveStreamComponentPlatform] when
  /// they register themselves.
  static set instance(AppscripLiveStreamComponentPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
