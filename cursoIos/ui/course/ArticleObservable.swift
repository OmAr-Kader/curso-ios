import Foundation
import Combine

class ArticleObservable : ObservableObject {
    
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
    func changeChatText(it: String) -> Unit {
        state = state.copy(chatText: it)
    }

    @MainActor
    var articleRate: String {
        let it = state.article
        return it.rate == 0.0 ? "5" : String(it.rate)
    }
    
    @MainActor
    func getArticle(article: ArticleForData?, articleId: String, studentId: String, userName: String) {
        if (article != nil) {
            state = state.copy(
                article: article,
                userId: studentId,
                userName: userName,
                isLoading: false
            )
            self.addNewReader(article: article!, studentId: studentId)
            return
        }
        state = state.copy(
            userId: studentId,
            userName: userName,
            isLoading: true
        )
        scope.launchRealm { [self] in
            await self.app.project.article.getArticlesById(articleId) { r in
                if (r.value != nil) {
                    let articleForData = ArticleForData(update: r.value!)
                    scope.launchMain {
                        self.state = self.state.copy(
                            article: articleForData,
                            isLoading: false
                        )
                    }
                    self.addNewReader(article: articleForData, studentId: studentId)
                }
            }
        }
    }
    
    private func addNewReader(article: ArticleForData, studentId: String) {
        if (!article.readerIds.contains(studentId)) {
            var newList = article.readerIds
            newList.append(studentId)
            let newL = newList
            scope.launchRealm {
                await self.app.project.article.editArticle(Article(update: article), Article(update: Article(update: article), readerIds: newL))
            }
        }
    }

    func getMainArticleConversation(articleId: String) {
        prefsTask?.cancel()
        chatPrefs?.cancel()
        prefsTask = scope.launchRealm {
            self.chatPrefs = await self.app.project.chat.getMainChatFlow(courseId: articleId) { changes in
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
    func changeFocus(newFocus: Bool) {
        if state.textFieldFocus == newFocus {
            return
        }
        state = state.copy(textFieldFocus: newFocus)
    }
    
    @MainActor
    func send(
        mode: Int,
        id: String,
        name: String,
        failed: @escaping (String) -> Unit
    ) {
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
        failed: @escaping (String) -> Unit
    ) {
        let article = s.article
        scope.launchRealm {
            let it = await self.app.project.chat.createChat(
                conversation: Conversation(
                    courseId: article.id,
                    courseName: article.title,
                    type: -1,
                    messages: self.messageCreator(mes: [], mode: mode, id: id, name: name, message: s.chatText).toMessage()
                )
            )
            if (it.result == REALM_SUCCESS && it.value != nil) {
                self.pushNotification(
                    topicId: article.lecturerId,
                    msgTitle: "Article (\(article.title) Chat",
                    message: "$name new message",
                    argOne: article.id,
                    argTwo: article.title,
                    mode: mode
                )
                let conv = ConversationForData(update: it.value!)
                self.scope.launchMain {
                    self.state = self.state.copy(conversation: conv, chatText: "")
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
        let article = s.article
        scope.launchRealm {
            let it = await self.app.project.chat.editChat(
                conversation: Conversation(update: conv),
                edit: Conversation(
                    courseId: article.id,
                    courseName: article.title,
                    type: -1,
                    messages: self.messageCreator(mes: conv.messages, mode: mode, id: id, name: name, message: s.chatText).toMessage(),
                    id: conv.id
                )
            )
            if (it.result == REALM_SUCCESS && it.value != nil) {
                self.pushNotification(
                    topicId: article.lecturerId,
                    msgTitle: "Article (\(article.title)) Chat",
                    message: "$name new message",
                    argOne: article.id,
                    argTwo: article.title,
                    mode: mode
                )
                let conv = ConversationForData(update: it.value!)
                self.scope.launchMain {
                    self.state = self.state.copy(conversation: conv, chatText: "")
                }
            } else {
                self.scope.launchMain {
                    failed("Failed")
                }
            }
        }
    }
    
    private func messageCreator(
        mes: [MessageForData],
        mode: Int,
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
        var mesList = mes
        mesList.append(it)
        return mesList
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
                        routeKey: ARTICLE_SCREEN_ROUTE,
                        argOne: argOne,
                        argTwo: argTwo,
                        argThree: mode == COURSE_MODE_STUDENT ? COURSE_MODE_LECTURER : COURSE_MODE_STUDENT
                    )
                )
            )
        }
    }
    
    struct State {
        var article: ArticleForData = ArticleForData()
        var conversation: ConversationForData? = nil
        var userId: String = ""
        var userName: String = ""
        var chatText: String = ""
        var textFieldFocus: Bool = false
        var hideKeyboard: Bool = false
        var isLoading: Bool = false
        
        mutating func copy(
            article: ArticleForData? = nil,
            conversation: ConversationForData? = nil,
            userId: String? = nil,
            userName: String? = nil,
            chatText: String? = nil,
            textFieldFocus: Bool? = nil,
            hideKeyboard: Bool? = nil,
            isLoading: Bool? = nil
        ) -> Self {
            self.article = article ?? self.article
            self.conversation = conversation ?? self.conversation
            self.userId = userId ?? self.userId
            self.userName = userName ?? self.userName
            self.chatText = chatText ?? self.chatText
            self.textFieldFocus = textFieldFocus ?? self.textFieldFocus
            self.hideKeyboard = hideKeyboard ?? self.hideKeyboard
            self.isLoading = isLoading ?? self.isLoading
            return self
        }
    }
}
