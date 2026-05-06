import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_tracking_plugin/live_tracking_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelLiveTrackingPlugin platform = MethodChannelLiveTrackingPlugin();
  const MethodChannel channel = MethodChannel('live_tracking_plugin');

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
