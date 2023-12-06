import SwiftUI

struct Main: View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack(path: $pref.navigationPath) {
            targetScreen(pref.state.homeScreen, app, pref)
        }.preferredColorScheme(pref.theme.isDarkStatusBarText ? .light : .dark)
            .overlay(alignment: .top) {
                Color.clear
                    .background(pref.theme.primary)
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 0)
            }
    }
}

struct SplashScreen : View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve

    @State private var scale: Double = 1
    @State private var isStudent: Bool = false

    var body: some View {
        
        FullZStack {
            VStack(alignment: .center) {
                Image(
                    uiImage: UIImage(
                        named: "AppIcon"
                    )?.withTintColor(
                        UIColor(pref.theme.textColor)
                    ) ?? UIImage()
                ).resizable()
                    .scaleEffect(scale)
                    .frame(width: 100, height: 100, alignment: .center)
            }.frame(alignment: .center).onAppear {
                withAnimation(Animation.easeIn(duration: 1.5)) {
                    scale = 3
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
            }.preferredColorScheme(pref.theme.isDarkMode ? .dark : .light)
        }.navigationDestination(for: Screen.self) { route in
            targetScreen(pref.state.homeScreen, app, pref)
        }.background(pref.theme.background)
            .preferredColorScheme(pref.theme.isDarkMode ? .dark : .light)
            .overlay(alignment: .top) {
                pref.theme.background
                    .background(pref.theme.primary)
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 0)
            }
    }
}
