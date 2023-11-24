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
    @StateObject var dependency = AppModule()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(dependency)
        }
    }
}
	
	
