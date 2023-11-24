//
//  Messaging.swift
//  firstApp
//
//  Created by OmAr on 21/11/2023.
//

import Foundation
import UserNotifications
import FirebaseMessaging
import FirebaseCore
import UIKit

func registerForNotification() {
    UIApplication.shared.registerForRemoteNotifications()
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        /*if ((error != nil)) {
            UIApplication.shared.registerForRemoteNotifications()
        }*/
    }
}
/*
 func request() async{
         do {
             try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
              await getAuthStatus()
         } catch{
             print(error)
         }
     }
     
     func getAuthStatus() async {
         let status = await UNUserNotificationCenter.current().notificationSettings()
         switch status.authorizationStatus {
         case .authorized, .ephemeral, .provisional:
             hasPermission = true
         default:
             hasPermission = false
         }
     }
*/

@inlinable func notificationPermission(invoke: @escaping  () -> ()) {
    let current = UNUserNotificationCenter.current()

    current.getNotificationSettings(completionHandler: { (settings) in
        if settings.authorizationStatus == .notDetermined {
            // Notification permission has not been asked yet, go for it!
            invoke()
        } else if settings.authorizationStatus == .denied {
            // Notification permission was previously denied, go to settings & privacy to re-enable
            invoke()
        } else if settings.authorizationStatus == .authorized {
            // Notification permission was already granted
        }
    })
}

func getFcmToken(invoke: @escaping  (String) -> Unit, failed: @escaping () -> Unit) {
    FirebaseMessaging.Messaging.messaging().token { it, e in
        if (it == nil) {
            failed()
            loggerError("fcmToken", e?.localizedDescription ?? "")
            return
        }
        invoke(it!)
    }
}

func subscribeToTopic(courseId: String, invoke: @escaping () -> Unit) {
    FirebaseMessaging.Messaging.messaging().subscribe(
        toTopic: "/topics/" + courseId) { e in
            loggerError("subscribeToTopic", e?.localizedDescription ?? "Done")
            invoke()
        }
}

func unsubscribeToTopic(courseId: String) {
    FirebaseMessaging.Messaging.messaging().unsubscribe(fromTopic: "/topics/" + courseId, completion: { e in
        loggerError("unsubscribeToTopic", e?.localizedDescription ?? "Done")
    })
}

func getFcmLogout(invoke: () -> Unit) {
    FirebaseMessaging.Messaging.messaging().deleteToken { e in
        loggerError("deleteFcmToken", e?.localizedDescription ?? "")
    }
}
