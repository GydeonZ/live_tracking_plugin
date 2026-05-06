import 'package:flutter_test/flutter_test.dart';
import 'package:live_tracking_plugin/live_tracking_plugin.dart';

void main() {
  test('Plugin can be initialized', () async {
    await LiveTrackingPlugin.initialize(apiBaseUrl: 'https://test.com');
    expect(LiveTrackingPlugin.isInitialized, isTrue);
    await LiveTrackingPlugin.dispose();
  });
}
