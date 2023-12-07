import SwiftUI

extension View {
    /*
    internal var del: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("could not get app delegate ")
        }
        return delegate
    }

    internal var appGet: AppModule {
        return AppDelegate.del!.app
    }

    internal var prefGet: PrefObserve {
        return AppDelegate.del!.pref
    }*/

    @ViewBuilder func targetScreen(
        _ target: Screen,
        _ app: AppModule,
        _ pref: PrefObserve
    ) -> some View {
        switch target {
            case .LOG_IN_LECTURER_SCREEN_ROUTE :
                LoginScreenLecturer(
                    app: app,
                    pref: pref,
                    loginObs: LogInObserveLecturer(app)
                )
            case .LECTURER_SCREEN_ROUTE :
                LecturerScreen(app: app, pref: pref, obs: LecturerObserve(app))
            case .CREATE_COURSE_SCREEN_ROUTE :
                CreateCourseScreen(app: app, pref: pref, obs: CreateCourseObserve(app))
            case .HOME_LECTURER_SCREEN_ROUTE :
                HomeLecturerScreen(
                    app: app,
                    pref: pref,
                    homeObs: HomeLecturerObserve(app)
                )
            default:
                SplashScreen(
                    app: app,
                    pref: pref
                )
        }
    }
}

enum Screen {
    case SPLASH_SCREEN_ROUTE
    case HOME_LECTURER_SCREEN_ROUTE
    case LOG_IN_LECTURER_SCREEN_ROUTE
    case HOME_STUDENT_SCREEN_ROUTE
    case LOG_IN_STUDENT_SCREEN_ROUTE
    case CREATE_COURSE_SCREEN_ROUTE
    case CREATE_ARTICLE_SCREEN_ROUTE
    case COURSE_SCREEN_ROUTE
    case ARTICLE_SCREEN_ROUTE
    case TIMELINE_SCREEN_ROUTE
    case VIDEO_SCREEN_ROUTE
    case IMAGE_SCREEN_ROUTE
    case LECTURER_SCREEN_ROUTE
    case STUDENT_SCREEN_ROUTE

}
