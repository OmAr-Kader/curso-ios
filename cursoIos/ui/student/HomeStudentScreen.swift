import SwiftUI

struct HomeStudentScreen : View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: HomeStudentObservable
    
    @State var isOpen = false
    @State private var toast: Toast? = nil
    
    private let listImg = [
        "https://fellow.app/wp-content/uploads/2021/07/2-9.jpg",
        "https://www.regus.com/work-us/wp-content/uploads/sites/18/2019/11/shutterstock_633364835_How-to-open-meeting-with-impact_resize-to-1024px-x-400px-landscape.jpg",
        "https://d3njjcbhbojbot.cloudfront.net/api/utilities/v1/imageproxy/https://coursera-course-photos.s3.amazonaws.com/da/f86c90ae6211e5907fe98be3e612d3/2_meetings.jpg?auto=format%2Ccompress&dpr=1",
        "https://f.hubspotusercontent40.net/hubfs/4592742/shutterstock_1705576870%20%281%29.jpg",
    ]

    private let buttonsList = ["Courses", "Available Timelines", "Upcoming Timelines", "Following Articles",  "Following Courses", "All Courses", "All Articles"]
    
    private var userName: String {
        return (pref.getArgumentTwo(it: HOME_STUDENT_SCREEN_ROUTE) ?? "").firstSpace
    }
    
    private func switchView(tab: Int) {
        let userId = pref.getArgumentOne(it: HOME_STUDENT_SCREEN_ROUTE) ?? ""
        switch tab {
        case 0 : obs.getCoursesForStudent(id: userId)
        case 1 : obs.getAvailableStudentTimeline(studentId: userId, studentName: userName)
        case 2 : obs.getUpcomingStudentTimeline(studentId: userId, studentName: userName)
        case 3 : obs.allArticlesFollowers(studentId: userId)
        case 4 : obs.allCoursesFollowers(userId)
        case 5 : obs.allCourses()
        case 6 : obs.allArticles()
        default: return
        }
    }
    
    var body: some View {
        let state = obs.state
        
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
                        obs.updateCurrentTabIndex(it: tab)
                        switchView(tab: tab)
                    }
                    VStack {
                        switch state.currentTab {
                        case 1, 2: ListBody(list: state.sessionForDisplay, bodyClick: { course in
                            pref.writeArguments(
                                route: TIMELINE_SCREEN_ROUTE,
                                one: "",
                                two: "",
                                obj: course
                            )
                            pref.navigateTo(.TIMELINE_SCREEN_ROUTE)
                        }) { session in
                            MainItem(title: session.title, imageUri: session.imageUri, textColor: pref.theme.textColor) {
                                TimelineItem(courseName: session.courseName, date: session.dateStr, duration: session.duration, textGrayColor: pref.theme.textGrayColor
                                )
                            }
                        }
                        case 3: HomeAllArticlesView(
                            articles: state.followedArticles,
                            theme: pref.theme
                        ) { article in
                            pref.writeArguments(
                                route: ARTICLE_SCREEN_ROUTE,
                                one: article.id,
                                two: article.title,
                                three: COURSE_MODE_STUDENT,
                                obj: article
                            )
                            pref.navigateTo(.ARTICLE_SCREEN_ROUTE)
                        }
                        case 4: HomeAllCoursesView(
                            courses: state.followedCourses,
                            theme: pref.theme
                        ) { course in
                            pref.writeArguments(
                                route: COURSE_SCREEN_ROUTE,
                                one: course.id,
                                two: course.title,
                                three: COURSE_MODE_STUDENT,
                                obj: course
                            )
                            pref.navigateTo(.COURSE_SCREEN_ROUTE)
                        }
                        case 5: HomeAllCoursesAdditionalView(
                            courses: state.allCourses,
                            theme: pref.theme,
                            additionalView: {
                                PageView(list: listImg, theme: pref.theme)
                            }
                        ) { course in
                            pref.writeArguments(
                                route: COURSE_SCREEN_ROUTE,
                                one: course.id,
                                two: course.title,
                                three: COURSE_MODE_STUDENT,
                                obj: course
                            )
                            pref.navigateTo(.COURSE_SCREEN_ROUTE)
                        }
                        case 6: HomeAllArticlesView(
                            articles: state.allArticles,
                            theme: pref.theme
                        ) { article in
                            pref.writeArguments(
                                route: ARTICLE_SCREEN_ROUTE,
                                one: article.id,
                                two: article.title,
                                three: COURSE_MODE_STUDENT,
                                obj: article
                            )
                            pref.navigateTo(.ARTICLE_SCREEN_ROUTE)
                        }
                        default: HomeOwnCoursesView(
                            courses: state.courses,
                            theme: pref.theme
                        ) { course in
                            pref.writeArguments(
                                route: COURSE_SCREEN_ROUTE,
                                one: course.id,
                                two: course.title,
                                three: COURSE_MODE_STUDENT,
                                obj: course
                            )
                            pref.navigateTo(.COURSE_SCREEN_ROUTE)
                        }
                        }
                    }
                }.background(pref.theme.background)
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
                                pref.findUserBase { userBase in
                                    guard let userBase else {
                                        return
                                    }
                                    pref.writeArguments(
                                        route: STUDENT_SCREEN_ROUTE,
                                        one: userBase.id,
                                        two: userBase.name
                                    )
                                    pref.navigateTo(.STUDENT_SCREEN_ROUTE)
                                }
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

struct PageView : View {
    let list: [String]
    let theme: Theme
    @State var current: Int = 0
    var body: some View {
        TabView(selection: $current) {
            ForEach(0..<list.count, id: \.self) { idx in
                ImageCacheView(list[idx], contentMode: .fill)
                    .frame(width: 300, height: 200).tag(idx)
            }
        }.tabViewStyle(.page(indexDisplayMode: .automatic))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(width: 300, height: 200).onCenter().background(theme.background)
    }
}
/*
@OptIn(ExperimentalFoundationApi::class)
@Composable
fun PageView(
    list: List<String>
) {
    val pagerState = rememberPagerState(pageCount = { list.size })
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.background),
        //verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(13.dp))
        HorizontalPager(
            state = pagerState,
            modifier = Modifier
                .width(300.dp)
                .height(200.dp)
                .background(MaterialTheme.colorScheme.background)
                .clip(RoundedCornerShape(20.dp)),
        ) {
            SubcomposeAsyncImage(
                model = LocalContext.current.imageBuildr(list[it]),
                success = { (painter, _) ->
                    Image(
                        contentScale = ContentScale.Crop,
                        painter = painter,
                        contentDescription = "Image"
                    )
                },
                loading = {
                    Box(
                        Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center,
                    ) {
                        CircularProgressIndicator()
                    }
                },
                contentScale = ContentScale.Crop,
                filterQuality = FilterQuality.None,
                contentDescription = "Image"
            )
        }
        Spacer(modifier = Modifier.height(13.dp))
        DotsIndicator(
            totalDots = pagerState.pageCount,
            selectedIndex = pagerState.currentPage,
            selectedColor = MaterialTheme.colorScheme.secondary,
            unSelectedColor = Color(
                ColorUtils.setAlphaComponent(
                    MaterialTheme.colorScheme.secondary.toArgb(),
                    150
                )
            )
        )
    }
}*/
