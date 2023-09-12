import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appscrip_live_stream_component/appscrip_live_stream_component_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAppscripLiveStreamComponent platform = MethodChannelAppscripLiveStreamComponent();
  const MethodChannel channel = MethodChannel('appscrip_live_stream_component');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
