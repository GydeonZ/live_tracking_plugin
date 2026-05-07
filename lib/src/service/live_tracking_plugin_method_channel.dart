import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'live_tracking_plugin_platform_interface.dart';

/// An implementation of [LiveTrackingPluginPlatform] that uses method channels.
class MethodChannelLiveTrackingPlugin extends LiveTrackingPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('live_tracking_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
