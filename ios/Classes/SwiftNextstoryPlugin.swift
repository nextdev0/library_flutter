import Flutter
import UIKit

public class SwiftNextstoryPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nextstory", binaryMessenger: registrar.messenger())
    let instance = SwiftNextstoryPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "enableAndroidTransparentNavigationBar") {
      result(nil)
      return
    }

    if (call.method == "mediaScan") {
      result(nil)
      return
    }

    if (call.method == "disableDelayTouchesBeganIOS") {
      let window = (UIApplication.shared.delegate as! FlutterAppDelegate).window!;
      (window.gestureRecognizers![0] as UIGestureRecognizer).delaysTouchesBegan = false
      (window.gestureRecognizers![1] as UIGestureRecognizer).delaysTouchesBegan = false
      result(nil)
      return
    }
  }
}
