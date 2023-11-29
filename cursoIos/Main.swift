//
//  ContentView.swift
//  cursoIos
//
//  Created by OmAr on 21/11/2023.
//

import SwiftUI

struct Main: View {
    @EnvironmentObject var app: AppModule
    @EnvironmentObject var pref: PrefObserve
    var body: some View {
        NavigationStack(path: $pref.navigationPath) {
            SplashScreen().environmentObject(app).environmentObject(pref)
        }
    }
}

struct SplashScreen : View {
    @EnvironmentObject var app: AppModule
    @EnvironmentObject var pref: PrefObserve

    var body: some View {
        Button("click mE") {
            pref.navigateCon(.LOG_IN_LECTURER_SCREEN_ROUTE)
        }.navigationDestination(for: Screen.self) { route in
            LoginScreen().environmentObject(app)
                .environmentObject(pref)

        }
    }
}
