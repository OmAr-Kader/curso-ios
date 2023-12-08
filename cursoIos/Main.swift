import SwiftUI

struct Main: View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @Environment(\.colorScheme) var colorScheme
    /*.toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(pref.theme.isDarkStatusBarText ? .light : .dark, for: .navigationBar
        ).overlay(alignment: .top) {
            Color.clear
                .background(pref.state.homeScreen == Screen.SPLASH_SCREEN_ROUTE ? pref.theme.background : pref.theme.primary
                )
                .ignoresSafeArea(edges: .top)
                .frame(height: 0)
        }*/
    
    var body: some View {
        NavigationStack(path: $pref.navigationPath) {
            targetScreen(
                pref.state.homeScreen, app, pref
            ).navigationDestination(for: Screen.self) { route in
                targetScreen(route, app, pref)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarColorScheme(
                        pref.theme.isDarkStatusBarText ? .dark : .light, for: .navigationBar
                    ).navigationBarBackButtonHidden(true)
            }
        }.overlay(alignment: .top) {
            Color.clear
                .background(pref.state.homeScreen == Screen.SPLASH_SCREEN_ROUTE ? pref.theme.background : pref.theme.primary
                )
                .ignoresSafeArea(edges: .top)
                .frame(height: 0)
        }.prepareStatusBarConfigurator(pref.theme.isDarkStatusBarText)
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
        }.overlay(alignment: .top) {
            pref.theme.background
                .background(pref.theme.background)
                .ignoresSafeArea(edges: .top)
                .frame(height: 0)
        }
        //.preferredColorScheme(pref.theme.isDarkMode ? .dark : .light)
    }
}

/*extension UIApplication {
    static var hostingController: HostingController<AnyView>? = nil
    
    static var statusBarStyleHierarchy: [UIStatusBarStyle] = []
    static var statusBarStyle: UIStatusBarStyle = .darkContent
    
    /*///Sets the App to start at rootView
    func setHostingController(rootView: AnyView) {
        let hostingController = HostingController(rootView: AnyView(rootView))
        windows.first?.rootViewController = hostingController
        UIApplication.hostingController = hostingController
    }*/
    
    static func setStatusBarStyle(_ style: UIStatusBarStyle) {
        statusBarStyle = style
        hostingController?.setNeedsStatusBarAppearanceUpdate()
    }
}

class HostingController<Content: View>: UIHostingController<Content> {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.statusBarStyle
    }
}*/
