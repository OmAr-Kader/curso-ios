import SwiftUI

struct Main: View {
    @ObservedObject var app: AppModule
    @ObservedObject var pref: PrefObserve

    init(_ app: AppModule) {
        self.app = app
        self.pref = PrefObserve(app)
    }
    
    var body: some View {
        NavigationStack(path: $pref.navigationPath) {
            pref.state.homeScreen.targetScreen(app, pref)
        }
    }
}

struct SplashScreen : View {
    @ObservedObject var app: AppModule
    @ObservedObject var pref: PrefObserve
    @State private var scale: Double = 1
    @State private var isStudent: Bool = false
    
    init(_ app: AppModule,_ pref: PrefObserve) {
        self.app = app
        self.pref = pref
    }

    var body: some View {
        ZStack {
            Image(
                uiImage: UIImage(
                    named: "photo.circle"
                )?.withTintColor(
                    UIColor(app.theme.textColor)
                ) ?? UIImage()
            ).resizable()
                .scaleEffect(scale)
                .scaledToFit()
                .frame(width: 100, height: 100)
        }.onAppear {
            withAnimation(Animation.easeInOut(duration: 1)) {
                scale = 3
            }
            pref.findUserBase { it in
                if (it == nil) {
                    pref.navigateHome(isStudent ? Screen.LOG_IN_STUDENT_SCREEN_ROUTE : Screen.LOG_IN_LECTURER_SCREEN_ROUTE)
                } else {
                    pref.checkIsUserValid(userBase: it!, isStudent: isStudent) {
                        let route = isStudent ? Screen.HOME_STUDENT_SCREEN_ROUTE : Screen.HOME_LECTURER_SCREEN_ROUTE
                        pref.writeArguments(
                            route: isStudent ? HOME_STUDENT_SCREEN_ROUTE : HOME_LECTURER_SCREEN_ROUTE,
                            one: it!.id,
                            two: it!.name,
                            three: it!.courses,
                            obj: ""
                        )
                        pref.navigateHome(route)
                    } failed: {
                        pref.navigateHome(isStudent ? Screen.LOG_IN_STUDENT_SCREEN_ROUTE : Screen.LOG_IN_LECTURER_SCREEN_ROUTE)
                    }
                }
            }
        }.navigationDestination(for: Screen.self) { route in
            pref.state.homeScreen.targetScreen(app, pref)
        }
    }
}
