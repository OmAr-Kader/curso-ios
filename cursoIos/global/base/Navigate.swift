import SwiftUI

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
    
    @ViewBuilder func targetScreen(
        _ app: AppModule,
        _ pref: PrefObserve
    ) -> some View {
        switch self {
            case .LOG_IN_LECTURER_SCREEN_ROUTE :
                LoginScreen(app, pref)
            default:
                SplashScreen(app, pref)
        }
    }
    
}
