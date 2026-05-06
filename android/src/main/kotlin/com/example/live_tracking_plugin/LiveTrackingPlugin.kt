package com.example.live_tracking_plugin

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** LiveTrackingPlugin */
class LiveTrackingPlugin: FlutterPlugin, ActivityAware, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  private lateinit var channel : MethodChannel
  private var context: Context? = null
  private var activityPluginBinding: ActivityPluginBinding? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "live_tracking_plugin")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityPluginBinding = binding
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activityPluginBinding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activityPluginBinding = binding
  }

  override fun onDetachedFromActivity() {
    activityPluginBinding = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "getDeviceInfo" -> {
        val deviceInfo = mapOf(
          "platform" to "Android",
          "osVersion" to android.os.Build.VERSION.RELEASE,
          "apiLevel" to android.os.Build.VERSION.SDK_INT,
          "device" to android.os.Build.DEVICE,
          "manufacturer" to android.os.Build.MANUFACTURER,
          "model" to android.os.Build.MODEL
        )
        result.success(deviceInfo)
      }
      "checkLocationServices" -> {
        val isEnabled = LocationServiceChecker.isLocationServiceEnabled(context)
        result.success(isEnabled)
      }
      "enableLocationServices" -> {
        // Android 5.0 and above: Users need to enable location through settings
        // We can prompt the user or just inform them
        result.success(true)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
  }
}

