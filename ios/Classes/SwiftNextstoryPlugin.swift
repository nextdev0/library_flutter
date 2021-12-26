import Flutter
import UIKit

public class SwiftNextstoryPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nextstory", binaryMessenger: registrar.messenger())
    let instance = SwiftNextstoryPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // no-op
  }
}
