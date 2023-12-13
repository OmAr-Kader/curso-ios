import SwiftUI

struct Main: View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    
    var body: some View {
        let isSplash = pref.state.homeScreen == Screen.SPLASH_SCREEN_ROUTE
        NavigationStack(path: $pref.navigationPath) {
            targetScreen(
                pref.state.homeScreen, app, pref
            ).navigationDestination(for: Screen.self) { route in
                targetScreen(route, app, pref).toolbar(.hidden, for: .navigationBar)
            }
        }.prepareStatusBarConfigurator(
            isSplash ? pref.theme.background : pref.theme.primary, isSplash, pref.theme.isDarkStatusBarText
        )
    }
}

struct SplashScreen : View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve

    @State private var scale: Double = 1
    @State private var isStudent: Bool = false
    @State private var width: CGFloat = 50
    var body: some View {
        FullZStack {
            Image(
                uiImage: UIImage(
                    named: "AppIcon"
                )?.withTintColor(
                    UIColor(pref.theme.textColor)
                ) ?? UIImage()
            ).resizable()
                .scaleEffect(scale)
                .frame(width: width, height: width, alignment: .center)
                .onAppear {
                    withAnimation() {
                        width = 150
                    }
                    pref.findUserBase { it in
                        guard let it else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                pref.navigateHome(isStudent ? Screen.LOG_IN_STUDENT_SCREEN_ROUTE : Screen.LOG_IN_LECTURER_SCREEN_ROUTE)
                            }
                            return
                        }
                        pref.checkIsUserValid(userBase: it, isStudent: isStudent) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                let route = isStudent ? Screen.HOME_STUDENT_SCREEN_ROUTE : Screen.HOME_LECTURER_SCREEN_ROUTE
                                pref.writeArguments(
                                    route: isStudent ? HOME_STUDENT_SCREEN_ROUTE : HOME_LECTURER_SCREEN_ROUTE,
                                    one: it.id,
                                    two: it.name,
                                    three: it.courses,
                                    obj: ""
                                )
                                pref.navigateHome(route)
                            }
                        } failed: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                pref.navigateHome(isStudent ? Screen.LOG_IN_STUDENT_SCREEN_ROUTE : Screen.LOG_IN_LECTURER_SCREEN_ROUTE)
                            }
                        }
                    }
                }
        }.background(pref.theme.background)
    }
}
