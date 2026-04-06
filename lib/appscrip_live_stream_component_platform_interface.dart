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

  Future<bool> isPictureInPictureSupported() {
    throw UnimplementedError(
        'isPictureInPictureSupported() has not been implemented.');
  }

  Future<bool> startPictureInPicture({String? trackId}) {
    throw UnimplementedError(
        'startPictureInPicture() has not been implemented.');
  }

  Future<bool> stopPictureInPicture() {
    throw UnimplementedError(
        'stopPictureInPicture() has not been implemented.');
  }

  /// Deactivate + reactivate AVAudioSession on iOS to force WebRTC
  /// to reinitialize its audio unit (fixes silent mic after role change).
  Future<bool> reactivateAudioSession() {
    throw UnimplementedError(
        'reactivateAudioSession() has not been implemented.');
  }
}
