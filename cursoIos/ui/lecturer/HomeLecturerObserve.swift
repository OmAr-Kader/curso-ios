import Foundation

class HomeLecturerObserve: ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()

    init(_ app: AppModule) {
        self.app = app
    }
    
    func getCoursesForLecturer(id: String) {
        scope.launchRealm {
            await self.app.project.course.getLecturerCourses(id) { r in
                if (r.result == REALM_SUCCESS) {
                    let courseDate = r.value.toCourseForData(currentTime)
                    self.scope.launchMain { [courseDate] in
                        self.state = self.state.copy(
                            courses: courseDate,
                            isLoading: false
                        )
                    }
                }
            }
        }
    }
    
    func getArticlesForLecturer(id: String) {
        scope.launchRealm {
            await self.app.project.article.getLecturerArticles(id) { r in
                if (r.result == REALM_SUCCESS) {
                    let articleData = r.value.toArticleForData()
                    self.scope.launchMain { [articleData] in
                        self.state = self.state.copy(
                            articles: articleData,
                            isLoading: false
                        )
                    }
                }
            }
        }
    }
    
    @MainActor
    func getUpcomingLecturerTimeline() {
        let courses = self.state.courses
        scope.launchMed { [courses] in
            let splited = courses.sorted { c1, c2 in
                return c1.lastEdit < c2.lastEdit
            }.splitCourses()
            self.scope.launchMain { [splited] in
                self.state = self.state.copy(sessionForDisplay: splited, isLoading: false)
            }
        }
    }
    
    func allCourses() {
        scope.launchRealm {
            await self.app.project.course.getAllCourses { r in
                if (r.result == REALM_SUCCESS) {
                    let courseData = r.value.toCourseForData(currentTime)
                    self.scope.launchMain { [courseData] in
                        self.state = self.state.copy(
                            allCourses: courseData,
                            isLoading: false
                        )
                    }
                }
            }
        }
    }

    func allArticles() {
        scope.launchRealm {
            await self.app.project.article.getAllArticles { r in
                if (r.result == REALM_SUCCESS) {
                    let articleData = r.value.toArticleForData()
                    self.scope.launchMain { [articleData] in
                        self.state = self.state.copy(
                            allArticles: articleData,
                            isLoading: false
                        )
                    }
                }
            }
        }
    }
    
    @MainActor
    func updateCurrentTabIndex(it: Int) {
        state = state.copy(currentTab: it, isLoading: true)
    }
    
    struct State {
        var courses: [CourseForData] = []
        var articles: [ArticleForData] = []
        var sessionForDisplay: [SessionForDisplay] = []
        var allCourses: [CourseForData] = []
        var allArticles: [ArticleForData] = []
        var currentTab: Int = 0
        var isLoading: Bool = true
        var isFABExpend: Bool = false
        
        mutating func copy(
            courses: [CourseForData]? = nil,
            articles: [ArticleForData]? = nil,
            sessionForDisplay: [SessionForDisplay]? = nil,
            allCourses: [CourseForData]? = nil,
            allArticles: [ArticleForData]? = nil,
            currentTab: Int? = nil,
            isLoading: Bool? = nil,
            isFABExpend: Bool? = nil
        ) -> Self {
            self.courses = courses ?? self.courses
            self.articles = articles ?? self.articles
            self.sessionForDisplay = sessionForDisplay ?? self.sessionForDisplay
            self.allCourses = allCourses ?? self.allCourses
            self.allArticles = allArticles ?? self.allArticles
            self.currentTab = currentTab ?? self.currentTab
            self.isLoading = isLoading ?? self.isLoading
            self.isFABExpend = isFABExpend ?? self.isFABExpend
            return self
        }
    }
    
    deinit {
        scope.deInit()
    }
    
}
