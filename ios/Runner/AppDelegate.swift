import UIKit
import Flutter
import TSMobileAnalytics

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
    guard let controller = window?.rootViewController as? FlutterViewController else {
        fatalError("rootViewController is not type FlutterViewController")
    }
    let channel = FlutterMethodChannel(name: "com.example.app/native", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [self] (call, result) in
        if call.method == "initializeFramework" {
            if let args = call.arguments as? [String: Any],
               let cpid = args["cpId"] as? String,
               let appName = args["appName"] as? String,
               let isPanelistOnly = args["isPanelistOnly"] as? Bool,
               let isLogEnabled = args["isLogEnabled"] as? Bool,
               let isWebViewBased = args["isWebViewBased"] as? Bool {
                let success = initializeFramework(cpid: cpid, appName: appName, isPanelistOnly: isPanelistOnly, isLogEnabled: isLogEnabled, isWebViewBased: isWebViewBased)
                result(success)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for 'initializeFramework'", details: nil))
            }
        } else if call.method == "sendTag" {
            if let args = call.arguments as? [String: Any],
                  let category = args["category"] as? String,
                  let contentID = args["contentID"] as? String {
                   // Send tag with Sifo SDK
                TSMobileAnalytics.sendTag(withCategories: [category], contentID: contentID) { success, error in
                       if let tError = error {
                           print("Error: \(tError.localizedDescription)")
                           result(FlutterError(code: "TAG_SEND_ERROR", message: tError.localizedDescription, details: nil))
                       } else {
                           result(nil)
                       }
                   }
               } else {
                   result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for 'sendTag'", details: nil))
               }
        }
    }
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    print(options)
    return TSMobileAnalytics.application(app, open: url, options: options)
  }

  private func initializeFramework(cpid: String, appName: String, isPanelistOnly: Bool, isLogEnabled: Bool, isWebViewBased: Bool) -> Bool {
    TSMobileAnalytics.setLogPrintsActivated(isLogEnabled)
    TSMobileAnalytics.initialize(withCPID: cpid,
                                 applicationName: appName,
                                 trackingType: .TrackUsersAndPanelists,
                                 enableSystemIdentifierTracking: isPanelistOnly,
                                 isWebViewBased: isWebViewBased,
                                 keychainAccessGroup: nil,
                                 additionals: [:])
    return true
  }
}
