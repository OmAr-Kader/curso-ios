import SwiftUI

@main
struct cursoIosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            Main(app: delegate.app, pref: delegate.pref)
        }
    }
}

