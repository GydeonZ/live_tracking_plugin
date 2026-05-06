// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:live_tracking_plugin/live_tracking_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Plugin initialization test', (WidgetTester tester) async {
    await LiveTrackingPlugin.initialize(apiBaseUrl: 'https://test.com');
    expect(LiveTrackingPlugin.isInitialized, isTrue);
    await LiveTrackingPlugin.dispose();
  });
}
