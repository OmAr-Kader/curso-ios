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
    @Environment(\.colorScheme) var colorScheme

    var body: some Scene {
        WindowGroup {
            Main(
                delegate.app.initTheme(
                    isDarkMode: colorScheme == .dark
                )
            )
        }
    }
}

