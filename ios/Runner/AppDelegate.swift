import UIKit
import Flutter
import workmanager
import shared_preferences_foundation
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(with: registry)
      }
      UNUserNotificationCenter.current().delegate = self
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }
    WorkmanagerPlugin.register(with: self.registrar(forPlugin: "be.tramckrijte.workmanager.WorkmanagerPlugin")!)
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*30))
    WorkmanagerPlugin.registerTask(withIdentifier: "transactionNotificationTask")
    WorkmanagerPlugin.registerTask(withIdentifier: "priceNotificationTask")
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        AppDelegate.registerPlugins(with: registry)
        SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")!)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    static func registerPlugins(with registry: FlutterPluginRegistry) {
               GeneratedPluginRegistrant.register(with: registry)
          }

    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler(.alert)
     }

}
