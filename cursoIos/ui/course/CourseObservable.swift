import Foundation
import Combine

class CourseObservable : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    private var prefsTask: Task<Void, Error>? = nil
    private var chatPrefs: AnyCancellable? = nil
    
    @MainActor
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    @MainActor
    var courseRate: String {
        let it = state.course
        return it.rate == 0.0 ? "5" : String(it.rate)
    }

    @MainActor
    func getCourseLecturer(
        course: CourseForData?,
        courseId: String,
        userId: String,
        userName: String
    ) {
        if (course != nil) {
            state = state.copy(
                course: course,
                userId: userId,
                userName: userName,
                isLoading: false
            )
            return
        }
        state = state.copy(
            userId: userId,
            userName: userName,
            isLoading: true
        )
        scope.launchRealm {
            await self.app.project.course.getCoursesById(courseId) { r in
                if (r.value != nil) {
                    self.scope.launchMain {
                        self.state = self.state.copy(
                            course: CourseForData(
                                update: r.value!, currentTime: currentTime
                            ),
                            isLoading: false
                        )
                    }
                }
            }
        }
    }
    
    @MainActor
    func getCourse(
        course: CourseForData?,
        courseId: String,
        studentId: String,
        userName: String
    ) {
        if (course != nil) {
            state = state.copy(
                course: course!,
                userId: studentId,
                userName: userName,
                alreadyEnrolled: course!.students.alreadyEnrolled(studentId),
                isLoading: false
            )
            return
        }
        state = state.copy(
            userId: studentId,
            userName: userName,
            isLoading: true
        )
        scope.launchRealm {
            await self.app.project.course.getCoursesById(courseId) { r in
                if (r.value != nil) {
                    let courseForData = CourseForData(
                        update: r.value!, currentTime: currentTime
                    )
                    self.scope.launchMain { [courseForData] in
                        self.state = self.state.copy(
                            course: courseForData,
                            alreadyEnrolled: courseForData.students.alreadyEnrolled(studentId),
                            isLoading: false
                        )
                    }
                }
            }
        }
    }
    
    func getMainConversation(courseId: String) {
        prefsTask?.cancel()
        chatPrefs?.cancel()
        prefsTask = scope.launchRealm {
            self.chatPrefs = await self.app.project.chat.getMainChatFlow(courseId: courseId) { changes in
                guard let changes else {
                    return
                }
                let conv = ConversationForData(update: changes)
                self.scope.launchMain {
                    self.state = self.state.copy(
                        conversation: conv
                    )
                }
            }
        }
    }

    @MainActor
    func changeChatText(it: String) {
        state = state.copy(chatText: it)
    }
    
    @MainActor
    func changeFocus(newFocus: Bool) {
        if state.textFieldFocus == newFocus {
            return
        }
        state = state.copy(textFieldFocus: newFocus)
    }

    @MainActor
    func enroll(studentId: String, studentName: String, invoke: @escaping () -> Void, failed: @escaping () -> Void) {
        let s = self.state
        scope.launchRealm { [s] in
            let c = s.course
            var list = c.students
            list.append(
                StudentCoursesData(
                    studentId: studentId,
                    studentName: studentName,
                    type: COURSE_TYPE_ENROLLED
                )
            )
            let it = await self.app.project.course.editCourse(
                Course(update: s.course),
                Course(update: Course(update: c), hexString: c.id, student: list.toStudentCourses())
            )
            if let value = it.value, it.result == REALM_SUCCESS {
                subscribeToTopic(value._id.stringValue) {
                }
                let courseForData = CourseForData(update: value, currentTime: currentTime)
                self.scope.launchMain {
                    self.state = self.state.copy(course: courseForData, alreadyEnrolled: courseForData.students.alreadyEnrolled(studentId))
                    invoke()
                }
            } else {
                self.scope.launchMain {
                    failed()
                }
            }
        }
    }

    @MainActor
    func send(mode: Int, id: String, name: String, failed: @escaping (String) -> Void) {
        let available = isNetworkAvailable()
        if !available {
            failed("Failed: Internet is disconnected")
            return
        }
        let conversation = state.conversation
        if conversation == nil {
            doCreateConversation(s: state, mode: mode, id: id, name: name, failed: failed)
        } else {
            doEditConversation(s: state, conv: conversation!, mode: mode, id: id, name: name, failed: failed)
        }
    }

    private func doCreateConversation(
        s: State,
        mode: Int,
        id: String,
        name: String,
        failed: @escaping (String) -> Void
    ) {
        scope.launchRealm {
            let course = s.course
            let it = await self.app.project.chat.createChat(
                conversation: Conversation(
                    courseId: course.id,
                    courseName: course.title,
                    type: -1,
                    messages: self.messageCreator([], mode, id: id, name: name, message: s.chatText).toMessage()
                )
            )
            if it.result == REALM_SUCCESS && it.value != nil {
                self.pushNotification(
                    topicId: it.value!.courseId,
                    msgTitle: "Course (\(course.title)) Chat",
                    message: "\(name) new message",
                    argOne: it.value!.courseId,
                    argTwo: it.value!.courseName,
                    mode: mode
                )
                self.scope.launchMain {
                    self.state = self.state.copy(conversation: ConversationForData(update: it.value!), chatText: "")
                }
            } else {
                self.scope.launchMain {
                    failed("Failed")
                }
            }
        }
    }


    
    private func doEditConversation(
        s: State,
        conv: ConversationForData,
        mode: Int,
        id: String,
        name: String,
        failed: @escaping (String) -> Unit
    ) {
        scope.launchRealm {
            let course = s.course
            let it = await self.app.project.chat.editChat(
                conversation: Conversation(update: conv),
                edit: Conversation(
                    courseId: course.id,
                    courseName: course.title,
                    type: -1,
                    messages: self.messageCreator(conv.messages, mode, id: id, name: name, message: self.state.chatText).toMessage(),
                    id: conv.id
                )
            )
            if (it.result == REALM_SUCCESS && it.value != nil) {
                self.pushNotification(
                    topicId: it.value!.courseId,
                    msgTitle: "Course (\(course.title)) Chat",
                    message: "$name new message",
                    argOne: it.value!.courseId,
                    argTwo: it.value!.courseName,
                    mode: mode
                )
                self.scope.launchMain {
                    self.state = self.state.copy(conversation: ConversationForData(update: it.value!), chatText: "")
                }
            } else {
                self.scope.launchMain {
                    failed("Failed")
                }
            }
        }
    }
    
    
    private func messageCreator(
        _ listM: [MessageForData],
        _ mode: Int,
        id: String,
        name: String,
        message: String,
        timestamp: Int64 = 0
    ) -> [MessageForData] {
        let it = if mode == COURSE_MODE_STUDENT {
            MessageForData(
                message: message,
                data: currentTime,
                senderId: id,
                senderName: name,
                timestamp: timestamp,
                fromStudent: true
            )
        } else {
            MessageForData(
                message: message,
                data: currentTime,
                senderId: id,
                senderName: name,
                timestamp: 0,
                fromStudent: false
            )
        }
        var listMessage = listM
        listMessage.append(it)
        return listMessage
    }
    
    private func pushNotification(
        topicId: String,
        msgTitle: String,
        message: String,
        argOne: String,
        argTwo: String,
        mode: Int
    ) {
        scope.launchMed {
            subscribeToTopic(topicId) {
                
            }
            postNotification(
                PushNotification(
                    to: "/topics/\(topicId)",
                    topic: "/topics/\(topicId)",
                    data: NotificationData(
                        title: msgTitle,
                        message: message,
                        routeKey: COURSE_SCREEN_ROUTE,
                        argOne: argOne,
                        argTwo: argTwo,
                        argThree: mode == COURSE_MODE_STUDENT ? COURSE_MODE_LECTURER : COURSE_MODE_STUDENT
                    )
                )
            )
        }
    }
    
    struct State {
        var course: CourseForData = CourseForData()
        var conversation: ConversationForData? = nil
        var userId: String = ""
        var userName: String = ""
        var chatText: String = ""
        var textFieldFocus: Bool = false
        var hideKeyboard: Bool = false
        var alreadyEnrolled: Bool = false
        var isLoading: Bool = false
        
        mutating func copy(
            course: CourseForData? = nil,
            conversation: ConversationForData? = nil,
            userId: String? = nil,
            userName: String? = nil,
            chatText: String? = nil,
            textFieldFocus: Bool? = nil,
            hideKeyboard: Bool? = nil,
            alreadyEnrolled: Bool? = nil,
            isLoading: Bool? = nil
        ) -> Self {
            self.course = course ?? self.course
            self.conversation = conversation ?? self.conversation
            self.userId = userId ?? self.userId
            self.userName = userName ?? self.userName
            self.chatText = chatText ?? self.chatText
            self.textFieldFocus = textFieldFocus ?? self.textFieldFocus
            self.hideKeyboard = hideKeyboard ?? self.hideKeyboard
            self.alreadyEnrolled = alreadyEnrolled ?? self.alreadyEnrolled
            self.isLoading = isLoading ?? self.isLoading
            return self
        }
    }
    
    deinit {
        prefsTask?.cancel()
        chatPrefs?.cancel()
        chatPrefs = nil
        prefsTask = nil
        scope.deInit()
    }
    
}
