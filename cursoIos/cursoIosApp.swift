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
    @StateObject var app = AppModule()
    @StateObject var pref = PrefObserve()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some Scene {
        WindowGroup {
            Main().environmentObject(
                app.initTheme(
                    isDarkMode: colorScheme == .dark
                )
            ).environmentObject(pref)
        }
    }
}

