import Foundation
import FirebaseMessaging
import UserNotifications

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
    @available(*, deprecated)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // [START_EXCLUDE]
        // Print message ID.
        /*if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }*/
        // [END_EXCLUDE]
        let n = PushNotification.init(info: userInfo)

        print(userInfo)
        print(n)
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo

    // [START_EXCLUDE]
    // Print message ID.
      /*if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
      }*/
    // [END_EXCLUDE]

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.

      let n = PushNotification.init(info: userInfo)

      print(userInfo)
      print(n)

      completionHandler()
    }
    /*
     func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification) async
       -> UNNotificationPresentationOptions {
       let userInfo = notification.request.content.userInfo

       // With swizzling disabled you must let Messaging know about the message, for Analytics
       // Messaging.messaging().appDidReceiveMessage(userInfo)

       // ...

       // Print full message.
       print(userInfo)

       // Change this to your preferred presentation option
       return [[.alert, .sound, .badge]]
     }

     func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse) async {
       let userInfo = response.notification.request.content.userInfo

       // ...

       // With swizzling disabled you must let Messaging know about the message, for Analytics
       // Messaging.messaging().appDidReceiveMessage(userInfo)

       // Print full message.
       print(userInfo)
     }
     */
}
// [END ios_10_message_handling]


extension AppDelegate : MessagingDelegate {
  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")
    
    let dataDict:[String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  // [END refresh_token]
}
