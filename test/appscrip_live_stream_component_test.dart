import 'package:flutter_test/flutter_test.dart';
import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/appscrip_live_stream_component_platform_interface.dart';
import 'package:appscrip_live_stream_component/appscrip_live_stream_component_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAppscripLiveStreamComponentPlatform
    with MockPlatformInterfaceMixin
    implements AppscripLiveStreamComponentPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AppscripLiveStreamComponentPlatform initialPlatform = AppscripLiveStreamComponentPlatform.instance;

  test('$MethodChannelAppscripLiveStreamComponent is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAppscripLiveStreamComponent>());
  });

  test('getPlatformVersion', () async {
    AppscripLiveStreamComponent appscripLiveStreamComponentPlugin = AppscripLiveStreamComponent();
    MockAppscripLiveStreamComponentPlatform fakePlatform = MockAppscripLiveStreamComponentPlatform();
    AppscripLiveStreamComponentPlatform.instance = fakePlatform;

    expect(await appscripLiveStreamComponentPlugin.getPlatformVersion(), '42');
  });
}
