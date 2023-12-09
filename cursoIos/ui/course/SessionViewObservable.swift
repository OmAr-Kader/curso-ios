import Foundation
import Combine

class SessionViewObservable : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()
    
    private var prefsTask: Task<Void, Error>? = nil
    private var chatPrefs: AnyCancellable? = nil
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    func getTimelineConversation(id: String, timelineIndex: Int) {
        prefsTask?.cancel()
        chatPrefs?.cancel()
        prefsTask = scope.launchRealm {
            self.chatPrefs = await self.app.project.chat.getTimelineChatFlow(
                courseId: id,
                type: timelineIndex
            ) { changes in
                guard let changes else {
                    return
                }
                self.scope.launchMain {
                    self.state = self.state.copy(
                        conversation: ConversationForData(update: changes)
                    )
                }
            }
        }
    }
    
    
    @MainActor
    func send(
        sessionForDisplay: SessionForDisplay,
        failed: @escaping (String) -> Unit
    ) {
        let available = isNetworkAvailable()
        if (!available) {
            failed("Failed: Internet is disconnected")
            return
        }
        let it = state.conversation
        if (it == nil) {
            doCreateConversation(sessionForDisplay: sessionForDisplay, failed: failed)
        } else {
            doEditConversation(
                conv: it!,
                sessionForDisplay: sessionForDisplay,
                failed: failed
            )
        }
    }
    
    private func doCreateConversation(
        sessionForDisplay: SessionForDisplay,
        failed: @escaping (String) -> Unit
    ) {
        scope.launchRealm {
            let it = await self.app.project.chat.createChat(
                conversation: Conversation(
                    courseId: sessionForDisplay.courseId,
                    courseName: sessionForDisplay.courseName,
                    type: sessionForDisplay.timelineIndex,
                    messages: self.messageCreator([], sessionForDisplay, self.state.chatText).toMessage()
                )
            )
            self.scope.launchMain {
                if (it.result == REALM_SUCCESS && it.value != nil) {
                    self.state = self.state.copy(
                        conversation: ConversationForData(update: it.value!),
                        chatText: ""
                    )
                } else {
                    failed("Failed")
                }
            }
        }
    }
    
    private func doEditConversation(
        conv: ConversationForData,
        sessionForDisplay: SessionForDisplay,
        failed: @escaping (String) -> Unit
    ) {
        scope.launchRealm {
            let it = await self.app.project.chat.editChat(
                conversation: Conversation(update: conv),
                edit: Conversation(
                    courseId: sessionForDisplay.courseId,
                    courseName: sessionForDisplay.courseName,
                    type: sessionForDisplay.timelineIndex,
                    messages: self.messageCreator(conv.messages, sessionForDisplay, self.state.chatText).toMessage(),
                    id: conv.id
                )
            )
            if (it.result == REALM_SUCCESS && it.value != nil) {
                self.scope.launchMain {
                    self.state = self.state.copy(
                        conversation: ConversationForData(update: it.value!),
                        chatText: ""
                    )
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
        _ sessionForDisplay: SessionForDisplay,
        _ message: String,
        _ timestamp: Int64 = 0
    ) -> [MessageForData] {
        var listMessage = listM
        let it = if sessionForDisplay.mode == 0 {
            MessageForData(
                message: message,
                data: currentTime,
                senderId: sessionForDisplay.studentId,
                senderName: sessionForDisplay.studentName,
                timestamp: timestamp,
                fromStudent: true
            )
        } else {
            MessageForData(
                message: message,
                data: currentTime,
                senderId: sessionForDisplay.lecturerId,
                senderName: sessionForDisplay.lecturerName,
                timestamp: 0,
                fromStudent: false
            )
        }
        listMessage.append(it)
        return listMessage
    }

    @MainActor
    func changeFocus(newFocus: Bool) {
        if (state.textFieldFocus == newFocus) {
            return
        }
        state = state.copy(
            textFieldFocus: newFocus
        )
    }
    
    struct State {
        var conversation: ConversationForData? = nil
        var chatText: String = ""
        var textFieldFocus: Bool = false
        
        mutating func copy(
            conversation: ConversationForData? = nil,
            chatText: String? = nil,
            textFieldFocus: Bool? = nil
        ) -> Self {
            self.conversation = conversation ?? self.conversation
            self.chatText = chatText ?? self.chatText
            self.textFieldFocus = textFieldFocus ?? self.textFieldFocus
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
