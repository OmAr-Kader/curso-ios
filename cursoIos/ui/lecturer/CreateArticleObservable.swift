import Foundation

class CreateArticleObservable : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    func getArticle(id: String) {
        scope.launchRealm {
            await self.app.project.article.getArticlesById(id) { r in
                let v = r.value
                guard let v else {
                    return
                }
                if (r.result == REALM_SUCCESS) {
                    var listText = v.text.toArticleTextData()
                    if listText.isEmpty {
                        listText.append(ArticleTextData(font: 22, text: ""))
                    }
                    let l = listText
                    let atr = ArticleForData(update: v)
                    let title = v.title
                    let image = v.imageUri
                    self.scope.launchMain {
                        self.state = self.state.copy(
                            article: atr,
                            articleText: l,
                            articleTitle: title,
                            imageUri: image
                        )
                    }
                }
            }
        }
    }

    @MainActor
    func deleteArticle(invoke: @escaping () -> Unit) {
        let art = state.article
        guard let art else {
            return
        }
        scope.launchRealm {
            let it = await self.app.project.article.deleteArticle(Article(update: art))
            if (it == REALM_SUCCESS) {
                self.scope.launchMain {
                    invoke()
                }
            }
        }
    }
    
    @MainActor
    func save(
        isDraft: Bool,
        lecturerId: String,
        lecturerName: String,
        invoke: @escaping (Article?) -> Unit
    ) {
        let s = state
        if (
            (isDraft && s.articleTitle.isEmpty) ||
            (!isDraft && (
                    s.articleTitle.isEmpty ||
                    s.articleText.map { it in it.text }.isEmpty ||
                    s.imageUri.isEmpty)
            )
        ) {
            state = state.copy(isErrorPressed: true)
            return
        }
        state = state.copy(isProcessing: !isDraft, isDraftProcessing: isDraft)
        doSave(isDraft: isDraft, lecturerId: lecturerId, lecturerName: lecturerName, s: s, invoke: invoke)
    }
    
    private func articleForSave(
        isDraft: Bool,
        lecturerId: String,
        lecturerName: String,
        s: State,
        invoke: @escaping (Article) -> Unit,
        failed: @escaping () -> Unit
    ) {
        uploadImage(s: s, lecturerId: lecturerId, invoke: { imageUri in
            self.scope.launchRealm {
                let it = Article(
                    title: s.articleTitle,
                    lecturerName: lecturerName,
                    lecturerId: lecturerId,
                    imageUri: imageUri,
                    text: s.articleText.toArticleText(),
                    lastEdit: currentTime,
                    isDraft: isDraft ? 1: -1
                )
                invoke(it)
            }
        }, failed: failed)
    }
    
    
    private func doSave(
        isDraft: Bool,
        lecturerId: String,
        lecturerName: String,
        s: State,
        invoke: @escaping (Article?) -> Unit
    ) {
        articleForSave(isDraft: isDraft, lecturerId: lecturerId, lecturerName: lecturerName, s: s, invoke: { course in
            self.scope.launchRealm {
                let it = await self.app.project.article.insertArticle(
                    course
                )
                if (it.value != nil) {
                    self.pushNotification(
                        topicId: it.value!.lecturerId,
                        msgTitle: "New Article",
                        message: "\(lecturerName) add A new Article",
                        argOne: it.value!._id.stringValue,
                        argTwo: it.value!.title
                    )
                }
                self.scope.launchMain {
                    self.state = self.state.copy(isProcessing: false, isDraftProcessing: false)
                    invoke(it.value)
                }
            }
        }, failed: {
            self.scope.launchMain {
                invoke(nil)
            }
        })
    }
    
    @MainActor
    func edit(
        _ isDraft: Bool,
        _ lecturerId: String,
        _ lecturerName: String,
        _ invoke: @escaping (Article?) -> Unit
    ) {
        let s = state
        if (
            (isDraft && s.articleTitle.isEmpty) ||
            (!isDraft && (
                    s.articleTitle.isEmpty ||
                    s.articleText.map { it in it.text }.isEmpty ||
                    s.imageUri.isEmpty)
            )
        ) {
            state = state.copy(isErrorPressed: true)
            return
        }
        state = state.copy(isProcessing: !isDraft, isDraftProcessing: isDraft)
        doEdit(isDraft: isDraft, lecturerId: lecturerId, lecturerName: lecturerName, s: s, invoke: invoke)
    }
    
    
    private func articleForEdit(
        _ isDraft: Bool,
        _ lecturerId: String,
        _ lecturerName: String,
        _ s: State,
        _ invoke: @escaping (Article) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        let c = s.article
        guard let c else {
            failed()
            return
        }
        uploadImage(s: s, lecturerId: lecturerId, invoke: { imageUri in
            self.scope.launchRealm {
                let it: Article = Article(
                    title: s.articleTitle,
                    lecturerName: lecturerName,
                    lecturerId: lecturerId,
                    imageUri: imageUri,
                    text: s.articleText.toArticleText(),
                    lastEdit: currentTime,
                    isDraft: isDraft ? 1: -1,
                    readerIds: c.readerIds.toRealmList(),
                    rate: c.rate,
                    raters: c.raters
                )
                invoke(it)
            }
        }, failed: failed)
    }

    
    private func doEdit(
        isDraft: Bool,
        lecturerId: String,
        lecturerName: String,
        s: State,
        invoke: @escaping (Article?) -> Unit
    ) {
        articleForEdit(isDraft, lecturerId, lecturerName, s, { article in
            self.doEditArticle(s: s, article: article, invoke: invoke)
        }, {
            self.scope.launchMain {
                invoke(nil)
            }
        })
    }
    
    private func doEditArticle(
        s: State,
        article: Article,
        invoke: @escaping (Article?) -> Unit
    ) {
        scope.launchRealm {
            if s.article == nil {
                return
            }
            let it = await self.app.project.article.editArticle(
                Article(update: s.article!),
                article
            )
            if (it.value != nil) {
                self.pushNotification(
                    topicId: article.lecturerId,
                    msgTitle: "Check what's new in the article",
                    message: "\(it.value!.lecturerName) edit \(it.value!.title)",
                    argOne: it.value!._id.stringValue,
                    argTwo: it.value!.title
                )
            }
            self.scope.launchMain {
                self.state = self.state.copy(isProcessing: false, isDraftProcessing: false)
                invoke(it.value)
            }
        }
    }
    
    @MainActor
    func setArticleTitle(it: String) {
        state = state.copy(articleTitle: it, isErrorPressed: false)
    }

    @MainActor
    func makeFontDialogVisible() {
        state = state.copy(isFontDialogVisible: true)
    }

    @MainActor
    func addAbout(type: Int) {
        var listT: [ArticleTextData] = (state.articleText)
        listT.append(ArticleTextData(font: type == 0 ? 14 : 22, text: ""))
        let l = listT
        state = state.copy(articleText: l, isErrorPressed: false, isFontDialogVisible: false)
    }

    @MainActor
    func removeAboutIndex(index: Int) {
        var listT: [ArticleTextData] = (state.articleText)
        listT.remove(at: index)
        let l = listT
        state = state.copy(articleText: l, dummy: state.dummy + 1)
    }

    @MainActor
    func changeAbout(it: String, index: Int) {
        var listT: [ArticleTextData] = (state.articleText)
        listT[index] = listT[index].copy(text: it)
        let l = listT
        state = state.copy(articleText: l, dummy: state.dummy + 1)
    }

    @MainActor
    func setImageUri(it: String) {
        state = state.copy(imageUri: it, isErrorPressed: false)
    }

    @MainActor
    func changeUploadDialogGone(it: Bool) {
        state = state.copy(isConfirmDialogVisible: it)
    }
    
    private func uploadImage(
        s: State,
        lecturerId: String,
        invoke: @escaping (String) -> Unit,
        failed: @escaping () -> Unit
    ) {
        let courseUri = s.article?.imageUri
        if (s.imageUri != courseUri && !s.imageUri.isEmpty) {
            let uri = URL(string: s.imageUri)
            guard let uri else {
                failed()
                return
            }
            if courseUri?.contains("https") == true {
                self.app.project.fireApp?.deleteFile(courseUri!)
            } else {
                failed()
                return
            }
            self.app.project.fireApp?.upload(
                uri, lecturerId + "/" + "IMG_" + String(currentTime) + uri.pathExtension,
                { it in
                    self.scope.launchMain {
                        invoke(it)
                        self.state = self.state.copy(imageUri: it, isErrorPressed: false)
                    }
                }, {
                    self.scope.launchMain {
                        failed()
                    }
                })
        } else {
            invoke(s.imageUri)
        }
    }
    
    
    private func pushNotification(
        topicId: String,
        msgTitle: String,
        message: String,
        argOne: String,
        argTwo: String
    ) {
        scope.launch {
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
                        argThree: COURSE_MODE_STUDENT
                    )
                )
            )
        }
    }
    
    struct State {
        var article: ArticleForData? = nil
        var articleText: [ArticleTextData] = [ArticleTextData(font: 22, text: "")]
        var articleTitle: String = ""
        var imageUri: String = ""
        var isErrorPressed: Bool = false
        var isProcessing: Bool = false
        var isDraftProcessing: Bool = false
        var dialogMode: Int = 0
        var isConfirmDialogVisible: Bool = false
        var isFontDialogVisible: Bool = false
        var dummy: Int = 0
        
        mutating func copy(
            article: ArticleForData? = nil,
            articleText: [ArticleTextData]? = nil,
            articleTitle: String? = nil,
            imageUri: String? = nil,
            isErrorPressed: Bool? = nil,
            isProcessing: Bool? = nil,
            isDraftProcessing: Bool? = nil,
            dialogMode: Int? = nil,
            isConfirmDialogVisible: Bool? = nil,
            isFontDialogVisible: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.article = article ?? self.article
            self.articleText = articleText ?? self.articleText
            self.articleTitle = articleTitle ?? self.articleTitle
            self.imageUri = imageUri ?? self.imageUri
            self.isErrorPressed = isErrorPressed ?? self.isErrorPressed
            self.isProcessing = isProcessing ?? self.isProcessing
            self.isDraftProcessing = isDraftProcessing ?? self.isDraftProcessing
            self.dialogMode = dialogMode ?? self.dialogMode
            self.isConfirmDialogVisible = isConfirmDialogVisible ?? self.isConfirmDialogVisible
            self.isFontDialogVisible = isFontDialogVisible ?? self.isFontDialogVisible
            self.dummy = dummy ?? self.dummy
            return self
        }
    }
    
    deinit {
        scope.deInit()
    }
}
