import SwiftUI

struct Main: View {
    @EnvironmentObject var app: AppModule
    @EnvironmentObject var pref: PrefObserve
    
    var body: some View {
        NavigationStack(path: $pref.navigationPath) {
            pref.state.homeScreen.targetScreen
                .environmentObject(app)
                .environmentObject(pref)
        }
    }
}

struct SplashScreen : View {
    @EnvironmentObject var app: AppModule
    @EnvironmentObject var pref: PrefObserve

    var body: some View {
        Button("click mE") {
            pref.navigateHome(.LOG_IN_LECTURER_SCREEN_ROUTE)
        }.navigationDestination(for: Screen.self) { route in
            route.targetScreen.environmentObject(app).environmentObject(pref)
        }
    }
}
