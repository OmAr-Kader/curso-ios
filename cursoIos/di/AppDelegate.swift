//
//  AppDelegate.swift
//  firstApp
//
//  Created by OmAr on 21/11/2023.
//

import Foundation
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      let options = FirebaseOptions.init(
          googleAppID: FIREBASE_APP_ID,
          gcmSenderID: FIREBASE_SENDER_ID
      )
      options.apiKey = FIREBASE_API_KEY
      options.storageBucket = FIREBASE_STORAGE_BUCKET
      options.projectID = FIREBASE_PROJECT_ID
      FirebaseApp.configure(options: options)

    return true
  }
}
