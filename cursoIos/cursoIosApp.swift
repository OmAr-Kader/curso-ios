//
//  cursoIosApp.swift
//  cursoIos
//
//  Created by OmAr on 21/11/2023.
//

import SwiftUI

@main
struct cursoIosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var isDarkMode = UITraitCollection.current.userInterfaceStyle.isDarkMode

    var body: some Scene {
        WindowGroup {
            Main(
                delegate.app,
                isDarkMode
            )
        }
    }
}

