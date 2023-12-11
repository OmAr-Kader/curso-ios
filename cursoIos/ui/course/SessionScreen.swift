import SwiftUI

struct SessionScreen : View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: SessionViewObservable
    @State var toast: Toast? = nil
    @State private var currentPage: Int = 0

    var session: SessionForDisplay {
        return pref.getArgumentJson(it: TIMELINE_SCREEN_ROUTE) as! SessionForDisplay
    }
    
    var userId: String {
        return session.mode == 0 ? session.studentId : session.lecturerId
    }
    
    var body: some View {
        let state = obs.state
        ZStack {
            VStack {
                ZStack {
                    FullZStack {
                        ImageCacheView(session.video, isVideoPreview: true)
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
                        one: session.video,
                        two: session.title
                    )
                    pref.navigateTo(.VIDEO_SCREEN_ROUTE)
                }
                Spacer().frame(height: 5)
                Text(
                    session.title
                ).foregroundStyle(pref.theme.textColor)
                    .font(.system(size: 18))
                    .padding(leading: 5, trailing: 5).onStart()
                Spacer().frame(height: 10)
                Text(
                    session.courseName
                ).foregroundStyle(pref.theme.textGrayColor)
                    .font(.system(size: 12))
                    .padding(top: 3, leading: 10, bottom: 3, trailing: 10).onStart().onTapGesture {
                        pref.writeArguments(
                            route: COURSE_SCREEN_ROUTE,
                            one: session.courseId,
                            two: session.courseName,
                            three: session.mode == 0 ? COURSE_MODE_STUDENT : COURSE_MODE_LECTURER,
                            obj: ""
                        )
                        pref.navigateTo(.COURSE_SCREEN_ROUTE)
                    }
                /*Spacer().frame(height: 10)
                Text(
                    session.lecturerName
                ).foregroundStyle(pref.theme.textColor).background(RoundedRectangle(cornerRadius: 20).fill(shadowColor))
                    .font(.system(size: 12))
                    .padding(top: 3, leading: 10, bottom: 3, trailing: 10).onStart().onTapGesture {
                        pref.writeArguments(
                            route: LECTURER_SCREEN_ROUTE,
                            one: session.courseId,
                            two: session.courseName
                        )
                        pref.navigateTo(.LECTURER_SCREEN_ROUTE)
                    }*/
                Spacer().frame(height: 15)
                PagerTab(currentPage: currentPage, onPageChange: { it in
                    currentPage = it
                }, list: ["About", "Chat"], theme: pref.theme) {
                    TextFullPageScrollable(text: session.note, textColor: pref.theme.textColor).tag(0)
                    ChatView(isEnabled: state.textFieldFocus, chatText: state.chatText, theme: pref.theme, onTextChanged: { it in
                        obs.changeChatText(it: it)
                    }, list: state.conversation?.messages ?? []) { it in
                        it.senderId == userId
                    } send: {
                        obs.send(sessionForDisplay: session) {_ in 
                        }
                    }.tag(1)
                }
            }
            BackButton {
                pref.backPress()
            }.onStart().onTop()
        }.background(pref.theme.background).toastView(toast: $toast).onAppear {
            obs.getTimelineConversation(id: session.courseId, timelineIndex: session.timelineIndex)
        }
    }
}
