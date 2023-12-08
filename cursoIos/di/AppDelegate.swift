import Foundation
import SwiftUI
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    static private(set) var del: AppDelegate! = nil
    private(set) var appSet: AppModule! = nil
    private(set) var prefSet: PrefObserve! = nil
    
    var app: AppModule {
        guard let appSet else {
            let ap = AppModule()
            self.appSet = ap
            return ap
        }
        return appSet
    }
    
    var pref: PrefObserve {
        guard let prefSet else {
            let pre = PrefObserve(
                app,
                Theme(isDarkMode: UITraitCollection.current.userInterfaceStyle.isDarkMode)
            )
            self.prefSet = pre
            return pre
        }
        return prefSet
    }
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        AppDelegate.del = self
        
        
        /*let options = FirebaseOptions.init(
         googleAppID: FIREBASE_APP_ID,
         gcmSenderID: FIREBASE_SENDER_ID
         )
         //options.apiKey = FIREBASE_API_KEY
         options.storageBucket = FIREBASE_STORAGE_BUCKET
         options.projectID = FIREBASE_PROJECT_ID
         FirebaseApp.configure(options: options)*/
        
        FirebaseApp.configure()
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        /*
         // [END register_for_notifications]
         let storyBoard = UIStoryboard(name: "Main", bundle: nil)
         
         var viewController = UIViewController()
         
         if (launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary) != nil {
         viewController = storyBoard.instantiateViewController(withIdentifier: "storyboardIdentifier") // user tap notification
         }else{
         viewController = storyBoard.instantiateViewController(withIdentifier: "storyboardIdentifier") // User not tap notificaiton
         }
         self.window?.rootViewController = viewController
         self.window?.makeKeyAndVisible()*/
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        /*if let messageID = userInfo[gcmMessageIDKey] {
         print("Message ID: \(messageID)")
         }*/
        
        // Print full message.
        print(userInfo)
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        /*if let messageID = userInfo[gcmMessageIDKey] {
         print("Message ID: \(messageID)")
         }*/
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}
