import Flutter
import UIKit
import CoreLocation

public class LiveTrackingPlugin: NSObject, FlutterPlugin {
  private var locationManager: CLLocationManager?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "live_tracking_plugin", binaryMessenger: registrar.messenger())
    let instance = LiveTrackingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getDeviceInfo":
      let deviceInfo: [String: Any] = [
        "platform": "iOS",
        "osVersion": UIDevice.current.systemVersion,
        "device": UIDevice.current.model,
        "systemName": UIDevice.current.systemName
      ]
      result(deviceInfo)
    case "checkLocationServices":
      let isEnabled = CLLocationManager.locationServicesEnabled()
      result(isEnabled)
    case "checkLocationPermission":
      let status = CLLocationManager.authorizationStatus()
      let permissionStatus: String
      switch status {
      case .notDetermined:
        permissionStatus = "notDetermined"
      case .restricted:
        permissionStatus = "restricted"
      case .denied:
        permissionStatus = "denied"
      case .authorizedAlways:
        permissionStatus = "authorizedAlways"
      case .authorizedWhenInUse:
        permissionStatus = "authorizedWhenInUse"
      @unknown default:
        permissionStatus = "unknown"
      }
      result(permissionStatus)
    case "enableLocationServices":
      // iOS: Users need to enable location through settings
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  + (BOOL)dummyMethodToEnforceBundling {
    [GeneratedPluginRegistrant register];
    return NO;
  }
}

