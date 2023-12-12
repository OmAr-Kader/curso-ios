import SwiftUI

struct CourseScreen : View {
    
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: CourseObservable
    @State private var toast: Toast? = nil
    @State private var currentPage: Int = 1
    @State private var isKeyboard: Bool = false

    var courseId: String {
        return pref.getArgumentOne(it: COURSE_SCREEN_ROUTE) ?? ""
    }
    var courseTitle: String {
        return pref.getArgumentTwo(it: COURSE_SCREEN_ROUTE) ?? ""
    }
    var mode: Int {
        return pref.getArgumentThree(it: COURSE_SCREEN_ROUTE) ?? 0
    }
    var course: CourseForData? {
        return pref.getArgumentJson(it: COURSE_SCREEN_ROUTE) as? CourseForData
    }
    var list : [String] {
        return if (mode != COURSE_MODE_NONE) {
            [
                "Timeline",
                "About",
                "Chat"
            ]
        } else {
            [
                "Timeline",
                "About"
            ]
        }
    }
    var cardTitle: String {
        return if (mode == COURSE_MODE_LECTURER) {
            "Edit"
        } else if (!obs.state.alreadyEnrolled) {
            "Enroll Now"
        } else {
            "Enrolled"
        }
    }
    
    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                if !isKeyboard {
                    ZStack {
                        FullZStack {
                            ImageCacheView(state.course.briefVideo, isVideoPreview: true)
                                .frame(height: 200)
                        }.frame(height: 200)
                        FullZStack {
                            ImageAsset(icon: "play", tint: .white)
                                .frame(width: 45, height: 45).padding(5)
                        }.frame(height: 200).background(
                            UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.64).toC
                        )
                    }.frame(height: 200).onTapGesture {
                        pref.writeArguments(
                            route: VIDEO_SCREEN_ROUTE,
                            one: state.course.briefVideo,
                            two: state.course.title
                        )
                        pref.navigateTo(.VIDEO_SCREEN_ROUTE)
                    }
                } else {
                    Spacer().frame(height: 50)
                }
                Spacer().frame(height: 5)
                HStack {
                    Text(
                        state.course.title
                    ).foregroundStyle(pref.theme.textColor)
                        .font(.system(size: 18))
                        .padding(leading: 5, trailing: 5).onStart()
                    Spacer()
                    if mode != COURSE_MODE_NONE {
                        CardButton(onClick: {
                            if (mode == COURSE_MODE_LECTURER) {
                                pref.writeArguments(
                                    route: CREATE_COURSE_SCREEN_ROUTE,
                                    one: state.course.id,
                                    two: state.course.title
                                )
                                pref.navigateTo(.CREATE_COURSE_SCREEN_ROUTE)
                            } else if (mode == COURSE_MODE_STUDENT && !state.alreadyEnrolled) {
                                pref.findUserBase { it in
                                    guard let it else {
                                        toast = Toast(style: .error, message: "Failed")
                                        return
                                    }
                                    obs.enroll(studentId: it.id, studentName: it.name, invoke: {
                                        pref.updatePref(key: PREF_USER_COURSES, newValue: String(it.courses + 1))
                                        toast = Toast(style: .success, message: "Done")
                                    }) {
                                        toast = Toast(style: .error, message: "Failed")
                                    }
                                }
                            }
                        }, text: cardTitle, color: !state.alreadyEnrolled ? pref.theme.primary : Color.green, textColor: !state.alreadyEnrolled ? pref.theme.textForPrimaryColor : Color.black
                        )
                    }
                }
                Spacer().frame(height: 10)
                VStack {
                    Text(
                        state.course.lecturerName
                    ).foregroundStyle(pref.theme.textColor).padding(10).frame(minWidth: 60)
                        .font(.system(size: 12))
                }.background(RoundedRectangle(cornerRadius: 20).fill(pref.theme.backDarkThr))
                    .padding(top: 3, leading: 10, bottom: 3, trailing: 10).onStart().onTapGesture {
                        pref.writeArguments(
                            route: LECTURER_SCREEN_ROUTE,
                            one: state.course.lecturerId,
                            two: state.course.lecturerName
                        )
                        pref.navigateTo(.LECTURER_SCREEN_ROUTE)
                    }
                HStack {
                    HStack {
                        ImageAsset(icon: "profile", tint: Color.blue)
                            .padding(3)
                            .frame(width: 25, height: 25)
                        Text(String(state.course.students.count))
                            .padding(leading: -3)
                            .foregroundStyle(pref.theme.textColor)
                            .font(.system(size: 14))
                            .lineLimit(1)
                    }.frame(alignment: .center)
                    Spacer()
                    HStack {
                        ImageAsset(icon: "star", tint: Color.blue)
                            .padding(3)
                            .frame(width: 25, height: 25)
                        Text(String(obs.courseRate))
                            .padding(leading: -3)
                            .foregroundStyle(pref.theme.textColor)
                            .font(.system(size: 14))
                            .lineLimit(1)
                    }.frame(alignment: .center)
                    Spacer()
                }
                Spacer().frame(height: 15)
                PagerTab(currentPage: currentPage, onPageChange: { it in
                    withAnimation {
                        currentPage = it
                    }
                }, list: list, theme: pref.theme) {
                    TimeLineView(state: state, theme: pref.theme, mode: mode) { it in
                        pref.writeArguments(
                            route: TIMELINE_SCREEN_ROUTE,
                            one: "",
                            two: "",
                            obj: it
                        )
                        pref.navigateTo(.TIMELINE_SCREEN_ROUTE)
                    }.tag(0)
                    TextCourseFullPageScrollable(textList: state.course.about, textColor: pref.theme.textColor).tag(1)
                    if mode != COURSE_MODE_NONE {
                        ChatView(isEnabled: currentPage == 2, chatText: state.chatText, theme: pref.theme, onTextChanged: { it in
                            obs.changeChatText(it: it)
                        }, onKeyboardChanged: { it in
                            withAnimation {
                                isKeyboard = it
                            }
                        }, list: state.conversation?.messages ?? []) { it in
                            it.senderId == state.userId
                        } send: {
                            pref.findUserBase { userBase in
                                guard let userBase else {
                                    return
                                }
                                obs.send(mode: mode, id: userBase.id, name: userBase.name) { _ in
                                    //toast = Toast(style: .info, message: it)
                                }
                            }
                        }.tag(2)
                    }
                }
            }
            BackButton {
                pref.backPress()
            }.onTop().onStart()
        }.background(pref.theme.background).toastView(toast: $toast).onAppear {
            pref.findUserBase { userBase in
                guard let userBase else {
                    return
                }
                switch mode {
                case COURSE_MODE_STUDENT :
                    obs.getCourse(course: course, courseId: courseId, studentId: userBase.id, userName: userBase.name)
                    obs.getMainConversation(courseId: courseId)
                case COURSE_MODE_LECTURER :
                    obs.getCourseLecturer(course: course, courseId: courseId, userId: userBase.id, userName: userBase.name)
                    obs.getMainConversation(courseId: courseId)
                default:
                    obs.getCourseLecturer(course: course, courseId: courseId, userId: userBase.id, userName: userBase.name)
                }
            }
        }
    }
}

struct TimeLineView : View {
    let state: CourseObservable.State
    let theme: Theme
    let mode: Int
    let nav: (SessionForDisplay) -> Unit
    var body: some View {
        let list = state.course.timelines
        ScrollView {
            ForEach(0..<list.count, id: \.self) { idx in
                let timeline = list[idx]
                VStack {
                    Text(
                        timeline.title
                    ).foregroundStyle(theme.textColor)
                        .font(.system(size: 14))
                        .padding(top: 7, leading: 7, trailing: 7).onStart()
                    Text(
                        "Date: \(timeline.date.toStr)"
                    ).foregroundStyle(theme.textHintColor)
                        .font(.system(size: 12))
                        .padding(top: 5, leading: 14, trailing: 14).onStart()
                    if timeline.mode == 1 {
                        HStack {
                            Text(
                                "Duration: \(timeline.duration)"
                            ).foregroundStyle(theme.primary)
                                .font(.system(size: 10))
                                .padding(leading: 14, bottom: 5)
                            Spacer()
                            Text(
                                "Degree: \(timeline.degree)"
                            ).foregroundStyle(theme.primary)
                                .font(.system(size: 10))
                                .padding(leading: 14, bottom: 5)
                            Spacer()
                        }.onStart()
                    }
                    Divider().background(theme.background.margeWithPrimary(0.3)).padding(leading: 10, trailing: 10)
                }.onTapGesture {
                    nav(
                        SessionForDisplay(course: state.course, timeline: timeline, mode: mode, userId: state.userId, userName: state.userName, i: idx)
                    )
                }
            }
        }
    }
}


struct TextCourseFullPageScrollable : View {
    let textList: [AboutCourseData]
    let textColor: Color
    
    var body: some View {
        //GeometryReader { geometry in
        ScrollView(Axis.Set.vertical) {
            VStack(alignment: .leading) {
                ForEach(0..<textList.count, id:\.self) { idx in
                    let art = textList[idx]
                    Text(art.text)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(textColor)
                        .font(.system(size: CGFloat(art.font)))
                        .padding(leading: 20, trailing: 20)
                        .lineLimit(nil)
                }
            }
        }
        //}
    }
}

/*
 
 @Composable
 fun TimeLineView(
     state: CourseViewModel.State,
     mode: Int,
     nav: (SessionForDisplay) -> Unit,
 ) {
     val course = state.course
     LazyColumn(modifier = Modifier.fillMaxSize()) {
         itemsIndexed(course.timelines) { i, timeline ->
             Column(
                 Modifier.clickable {
                     SessionForDisplay(course, timeline, mode, state.userId, state.userName, i).let { one ->
                         nav.invoke(one)
                     }
                 }
             ) {
                 Text(
                     text = timeline.title,
                     color = isSystemInDarkTheme().textColor,
                     fontSize = 14.sp,
                     modifier = Modifier
                         .padding(start = 7.dp, end = 7.dp, top = 7.dp),
                     style = MaterialTheme.typography.bodyMedium,
                 )
                 Text(
                     text = "Date: ${timeline.date.toString}",
                     color = isSystemInDarkTheme().textHintColor,
                     fontSize = 14.sp,
                     modifier = Modifier
                         .padding(start = 14.dp, end = 14.dp, top = 5.dp),
                     style = MaterialTheme.typography.bodySmall,
                 )
                 if (timeline.mode == 1) {
                     Row {
                         Text(
                             text = "Duration: ${timeline.duration}",
                             color = MaterialTheme.colorScheme.primary,
                             fontSize = 10.sp,
                             modifier = Modifier
                                 .padding(start = 14.dp, bottom = 5.dp),
                             style = MaterialTheme.typography.bodySmall,
                         )
                         Text(
                             text = "Degree: ${timeline.degree}",
                             color = MaterialTheme.colorScheme.primary,
                             fontSize = 10.sp,
                             modifier = Modifier
                                 .padding(start = 20.dp, bottom = 5.dp),
                             style = MaterialTheme.typography.bodySmall,
                         )
                     }
                 }
                 Divider(color = MaterialTheme.colorScheme.background.darker(0.3F))
             }
         }
     }
 }*/
