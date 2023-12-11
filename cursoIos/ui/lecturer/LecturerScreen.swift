import SwiftUI

struct LecturerScreen : View {
    
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: LecturerObserve
    @State private var toast: Toast? = nil
    @State private var currentPage: Int = 1
    var lecturerId: String {
        return pref.getArgumentOne(it: LECTURER_SCREEN_ROUTE) ?? ""
    }
    
    var lecturerName: String {
        return pref.getArgumentTwo(it: LECTURER_SCREEN_ROUTE) ?? ""
    }
    
    var mode: Int {
        return pref.getArgumentThree(it: LECTURER_SCREEN_ROUTE) ?? 0
    }
    
    var body: some View {
        let state = obs.state
        ZStack {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    VStack(alignment: .center) {
                        ImageCacheView(state.lecturer.imageUri)
                    }.frame(width: 100, height: 100).clipShape(Circle())
                    Text(state.lecturer.lecturerName.ifEmpty {
                        lecturerName
                    }).foregroundStyle(pref.theme.textColor).padding(leading: 5, trailing: 5).font(.system(size: 14))
                    if mode == 1 {
                        Spacer().frame(height: 5)
                        CardButton(
                            onClick: {
                                if (state.studentId.isEmpty) {
                                    toast = Toast(style: .error, message: "Failed")
                                }
                                obs.followUnfollow(state.studentId, state.alreadyFollowed, {
                                }) {
                                    toast = Toast(style: .error, message: "Failed")
                                }
                            },
                            text: state.alreadyFollowed ? "Unfollow" : "Folloe",
                            color: state.alreadyFollowed ? .green : pref.theme.primary,
                            textColor: pref.theme.textForPrimaryColor
                        )
                    }
                    Spacer().frame(height: 5)
                    HStack(alignment: .center) {
                        ProfileItems(
                            icon: "video",
                            color: Color.blue,
                            theme: pref.theme,
                            title: "Courses",
                            numbers: String(state.courses.count)
                        )
                        ProfileItems(
                            icon: "profile",
                            color: Color.green,
                            theme: pref.theme,
                            title: "Followers",
                            numbers: obs.lecturerFollowers(mode: mode)
                        )
                        ProfileItems(
                            icon: "star",
                            color: Color.yellow,
                            theme: pref.theme,
                            title: "Rate",
                            numbers: obs.lecturerRate
                        )
                        PagerTab(currentPage: currentPage, onPageChange: { it in
                            currentPage = it
                        }, list: ["About", "Courses", "Articles"], theme: pref.theme) {
                            TextFullPageScrollable(
                                text: state.lecturer.brief,
                                textColor: pref.theme.textColor
                            ).tag(0)
                            LecturerCoursesView(
                                courses: state.courses,
                                theme: pref.theme
                            ) { course in
                                pref.writeArguments(
                                    route: COURSE_SCREEN_ROUTE,
                                    one: course.id,
                                    two: course.title,
                                    three: mode == 1 ? COURSE_MODE_STUDENT : COURSE_MODE_NONE,
                                    obj: course
                                )
                                pref.navigateTo(.COURSE_SCREEN_ROUTE)
                            }.tag(1)
                            HomeAllArticlesView(
                                articles: state.articles,
                                theme: pref.theme
                            ) { article in
                                pref.writeArguments(
                                    route: ARTICLE_SCREEN_ROUTE,
                                    one: article.id,
                                    two: article.title,
                                    three: mode == 1 ? COURSE_MODE_STUDENT : COURSE_MODE_NONE,
                                    obj: article
                                )
                                pref.navigateTo(.ARTICLE_SCREEN_ROUTE)
                            }.tag(2)
                        }
                    }
                }
            }.toastView(toast: $toast).onAppear {
                pref.findPrefString(key: PREF_USER_ID) { id in
                    if id != nil {
                        obs.fetchLecturer(lecturerId: lecturerId, studentId: id!)
                    }
                }
            }
            BackButton {
                pref.backPress()
            }
        }
    }
}
