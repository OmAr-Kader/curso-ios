import SwiftUI

struct HomeLecturerScreen : View {
    
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var homeObs: HomeLecturerObserve// = HomeLecturerObserve(AppDelegate.del!.app)

    @State var isOpen = false
    @State private var toast: Toast? = nil
    @Environment(\.colorScheme) var colorScheme

    @State private var scrollTo: ScrollViewProxy? = nil
    private let buttonsList = ["Courses", "Articles", "Timelines", "All Courses", "All Articles"]
    
    
    private var userName: String {
        return (pref.getArgumentTwo(it: HOME_LECTURER_SCREEN_ROUTE) ?? "").firstSpace
    }
    
    private func switchView(tab: Int) {
        let userId = pref.getArgumentOne(it: HOME_LECTURER_SCREEN_ROUTE) ?? ""
        switch tab {
            case 0 : homeObs.getCoursesForLecturer(id: userId)
            case 1 : homeObs.getArticlesForLecturer(id: userId)
            case 2 : homeObs.getUpcomingLecturerTimeline()
            case 3 : homeObs.allCourses()
            case 4 : homeObs.allArticles()
            default: return
        }
    }

    var body: some View {
        let state = homeObs.state
        VStack {
            DrawerView(isOpen: $isOpen, overlayColor: shadowColor, theme: pref.theme) {
                VStack {
                    VStack {
                        VStack {
                            VStack {
                                HStack {
                                    VStack {
                                        Button {
                                            withAnimation {
                                                isOpen.toggle()
                                            }
                                        } label: {
                                            ImageAsset(
                                                icon: "menu",
                                                tint: pref.theme.textForPrimaryColor
                                            )
                                        }.padding(8)
                                    }.padding(leading: 10).frame(width: 48, height: 48)
                                    Spacer()
                                    Text(
                                        "Hello " + userName
                                    ).foregroundStyle(pref.theme.textForPrimaryColor).lineLimit(1)
                                    Spacer()
                                    VStack {
                                        Button {
                                            
                                        } label: {
                                            ImageAsset(
                                                icon: "bell",
                                                tint: pref.theme.textForPrimaryColor
                                            )
                                        }.padding(8).background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(shadowColor)
                                        )
                                    }.padding(trailing: 10).frame(width: 48, height: 48)
                                }.padding(15).frame(height: 60)
                                VStack {
                                    TextField("", text: Binding(get: {
                                        ""
                                    }, set: { _ in
                                        
                                    })).multilineTextAlignment(.center).placeholder(when: true, alignment: .center) {
                                        Text("Search").foregroundColor(pref.theme.textHintColor)
                                    }.frame(height: 55)
                                        .lineLimit(1)
                                        .background(RoundedRectangle(cornerRadius: 15).fill(pref.theme.backDarkSec))
                                }.padding(leading: 15, bottom: 15, trailing: 15)
                            }
                        }.background(pref.theme.primary)
                    }.clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 20,
                            bottomTrailingRadius: 20,
                            topTrailingRadius: 0
                        )
                    )
                    UpperNavBar(
                        list: buttonsList,
                        currentIndex: state.currentTab,
                        theme: pref.theme
                    ) { tab in
                        homeObs.updateCurrentTabIndex(it: tab)
                        switchView(tab: tab)
                    }
                    VStack {
                        switch state.currentTab {
                        case 1: HomeArticlesView(
                            articles: state.articles,
                            theme: pref.theme
                        ) { it in
                            pref.writeArguments(
                                route: ARTICLE_SCREEN_ROUTE,
                                one: it.id,
                                two: it.title,
                                three: COURSE_MODE_LECTURER,
                                obj: it
                            )
                            pref.navigateTo(.ARTICLE_SCREEN_ROUTE)
                        } edit: { id, title in
                            pref.writeArguments(
                                route: CREATE_ARTICLE_SCREEN_ROUTE,
                                one: id,
                                two: title
                            )
                            pref.navigateTo(.CREATE_ARTICLE_SCREEN_ROUTE)
                        }
                        case 2 : HomeTimeLineView(
                            sessions: state.sessionForDisplay,
                            theme: pref.theme
                        ) { course in
                            pref.writeArguments(
                                route: TIMELINE_SCREEN_ROUTE,
                                one: "",two: "",
                                obj: course
                            )
                            pref.navigateTo(.TIMELINE_SCREEN_ROUTE)
                        } edit: { courseId, courseName in
                            pref.writeArguments(
                                route: CREATE_COURSE_SCREEN_ROUTE,
                                one: courseId,
                                two: courseName
                            )
                            pref.navigateTo(.CREATE_COURSE_SCREEN_ROUTE)
                        }
                        case 3: HomeAllCoursesView(
                            courses: state.allCourses,
                            theme: pref.theme
                        ) { course in
                            pref.writeArguments(
                                route: COURSE_SCREEN_ROUTE,
                                one: course.id,
                                two: course.title,
                                three: COURSE_MODE_NONE,
                                obj: course
                            )
                            pref.navigateTo(.COURSE_SCREEN_ROUTE)
                        }
                        case 4: HomeAllArticlesView(
                            articles: state.allArticles,
                            theme: pref.theme
                        ) { article in
                            pref.writeArguments(
                                route: ARTICLE_SCREEN_ROUTE,
                                one: article.id,
                                two: article.title,
                                three: COURSE_MODE_NONE,
                                obj: article
                            )
                            pref.navigateTo(.ARTICLE_SCREEN_ROUTE)
                        }
                        default: HomeCoursesView(
                            courses: state.courses,
                            theme: pref.theme,
                            nav: { course in
                                pref.writeArguments(
                                    route: COURSE_SCREEN_ROUTE,
                                    one: course.id,
                                    two: course.title,
                                    three: COURSE_MODE_LECTURER,
                                    obj: course
                                )
                                pref.navigateTo(.COURSE_SCREEN_ROUTE)
                            }) { id, title in
                                pref.writeArguments(
                                    route: CREATE_COURSE_SCREEN_ROUTE,
                                    one: id,
                                    two: title
                                )
                                pref.navigateTo(.CREATE_COURSE_SCREEN_ROUTE)
                            }
                        }
                    }
                }.background(pref.theme.background).overlay {
                    MultipleFloatingButton(icon: "plus", theme: pref.theme) {
                        pref.writeArguments(
                            route: CREATE_ARTICLE_SCREEN_ROUTE,
                            one: "",
                            two: ""
                        )
                        pref.navigateTo(.CREATE_ARTICLE_SCREEN_ROUTE)
                    } actionCourse: {
                        pref.writeArguments(
                            route: CREATE_COURSE_SCREEN_ROUTE,
                            one: "",
                            two: ""
                        )
                        pref.navigateTo(.CREATE_COURSE_SCREEN_ROUTE)
                    }
                }
            } drawer: {
                VStack {
                    HStack {
                        VStack {
                            DrawerText(
                                itemColor: pref.theme.primary,
                                text: "Curso",
                                textColor: pref.theme.textForPrimaryColor
                            ) {
                                withAnimation {
                                    isOpen.toggle()
                                }
                            }.frame(width: 250)
                            DrawerItem(
                                itemColor: pref.theme.primary,
                                icon: "profile",
                                text: "Profile",
                                textColor: pref.theme.textColor
                            ) {
                                pref.writeArguments(
                                    route: LECTURER_SCREEN_ROUTE,
                                    one: pref.getArgumentOne(it: HOME_LECTURER_SCREEN_ROUTE) ?? "",
                                    two: pref.getArgumentTwo(it: HOME_LECTURER_SCREEN_ROUTE) ?? ""
                                )
                                pref.navigateTo(.LECTURER_SCREEN_ROUTE)
                            }.frame(width: 250)
                            Divider()
                            DrawerItem(
                                itemColor: pref.theme.primary,
                                icon: "exit",
                                text: "Sign out",
                                textColor: pref.theme.textColor
                            ) {
                                pref.signOut({
                                    exit(0)
                                }) {
                                    toast = Toast(style: .error, message: "Failed")
                                }
                            }.frame(width: 250)
                            Spacer()
                        }.frame(width: 250)
                            .background(pref.theme.backDark)
                            .onStart()
                    }.frame(width: 250).clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 20,
                            topTrailingRadius: 20
                        )
                    )
                }
            }
        }.toastView(toast: $toast).onAppear {
            switchView(tab: state.currentTab)
        }
    }
}

struct HomeCoursesView : View {
    
    let courses: [CourseForData]
    let theme: Theme
    let nav: (CourseForData) -> Unit
    let edit: (String, String) -> Unit

    var body: some View {
        ListBodyEdit(list: courses) { course in
            MainItemEdit(
                title: course.title,
                imageUri: course.imageUri,
                colorEdit: course.isDraft == 1 ? theme.error : theme.primary,
                textColor: theme.textColor,
                textColorEdit: course.isDraft == 1 ? .white : theme.textForPrimaryColor
            ) {
                nav(course)
            } editClick: {
                edit(course.id, course.title)
            } content: {
                OwnCourseItem(
                   nextTimeLine: course.nextTimeLine,
                   students: course.studentsSize,
                   theme: theme
               )
            }
        }
    }
}


struct HomeArticlesView: View {
    let articles: [ArticleForData]
    let theme: Theme
    let nav: (ArticleForData) -> Unit
    let edit: (String, String) -> Unit

    var body: some View {
        ListBodyEdit(list: articles) { article in
            MainItemEdit(
                title: article.title,
                imageUri: article.imageUri,
                colorEdit: article.isDraft == 1 ? theme.error : theme.primary,
                textColor: theme.textColor,
                textColorEdit: article.isDraft == 1 ? .white : theme.textForPrimaryColor) {
                    nav(article)
                } editClick: {
                    edit(article.id, article.title)
                } content: {
                    OwnArticleItem(readers: article.readers, theme: theme)
                }
        }
    }
}

struct HomeTimeLineView : View {
    let sessions: [SessionForDisplay]
    let theme: Theme
    let nav: (SessionForDisplay) -> Unit
    let edit: (String, String) -> Unit

    var body: some View {
        ListBodyEdit(list: sessions) { session in
            MainItemEdit(
                title: session.title,
                imageUri: session.imageUri,
                colorEdit: session.isDraft == 1 ? theme.error : theme.primary,
                textColor: theme.textColor,
                textColorEdit: session.isDraft == 1 ? .white : theme.textForPrimaryColor) {
                    nav(session)
                } editClick: {
                    edit(session.courseId, session.courseName)
                } content: {
                     TimelineItem(
                        courseName: session.courseName,
                        date: session.dateStr, duration:
                        session.duration,
                        textGrayColor: theme.textGrayColor
                     )
                }
        }
    }
}
