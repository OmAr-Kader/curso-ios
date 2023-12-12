import Foundation

class HomeStudentObservable : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    @MainActor
    func getCoursesForStudent(id: String) {
        state = state.copy(
            isLoading: true
        )
        scope.launchRealm {
            await self.app.project.course.getStudentCourses(id) { r in
                if (r.result == REALM_SUCCESS) {
                    let courses = r.value.toCourseForData(currentTime)
                    self.scope.launchMain {
                        self.state = self.state.copy(courses: courses, isLoading: false
                        )
                    }
                }
            }
        }
    }
    
    func getAvailableStudentTimeline(studentId: String, studentName: String) {
        scope.launchRealm {
            await self.app.project.course.getAvailableStudentTimeline(studentId, currentTime) { r in
                let it = r.value.sorted { c1, c2 in
                    return c1.lastEdit < c2.lastEdit
                }.toCourseForData(currentTime).splitCourses(studentId: studentId, studentName: studentName
                )
                self.scope.launchMain {
                    self.state = self.state.copy(sessionForDisplay: it)

                }
            }
        }
    }
    
    func getUpcomingStudentTimeline(studentId: String, studentName: String) {
        scope.launchRealm {
            await self.app.project.course.getUpcomingStudentTimeline(studentId, currentTime
            ) { r in
                let it = r.value.sorted { c1, c2 in
                    return c1.lastEdit < c2.lastEdit
                }.toCourseForData(currentTime).splitCourses(studentId: studentId, studentName: studentName)
                self.scope.launchMain {
                    self.state = self.state.copy(sessionForDisplay: it)
                }
            }
        }
    }
    
    @MainActor
    func updateCurrentTabIndex(it: Int) {
        state = state.copy(currentTab: it)
    }
    
    @MainActor
    func allCoursesFollowers(_ studentId: String) {
        state = state.copy(
            isLoading: true
        )
        scope.launchRealm {
            await self.app.project.lecturer.getLecturerFollowed(studentId) { r in
                if (r.value.isEmpty) {
                    self.scope.launchMain {
                        self.state = self.state.copy(followedCourses: [], isLoading: false)
                        
                    }
                    return
                }
                self.doAllCoursesFollowers(r.value)
            }
        }
    }
    
    private func doAllCoursesFollowers(_ list: [Lecturer]) {
        scope.launchRealm {
            await self.app.project.course.getAllCoursesFollowed(list.map { it in it._id.stringValue }
            ) { r in
                if (r.result == REALM_SUCCESS) {
                    let courses = r.value.toCourseForData(currentTime)
                    self.scope.launchMain {
                        self.state = self.state.copy(
                            followedCourses: courses,
                            isLoading: false
                        )
                    }
                }
            }
        }
    }
    
    @MainActor
    func allArticles() {
        state = state.copy(
            isLoading: true
        )
        scope.launchRealm {
            await self.app.project.article.getAllArticles { r in
                if (r.result == REALM_SUCCESS) {
                    let art = r.value.toArticleForData()
                    self.scope.launchMain {
                        self.state = self.state.copy(
                            allArticles: art, isLoading: false
                        )
                    }
                }
            }
        }
    }
    
    @MainActor
    func allArticlesFollowers(studentId: String) {
        state = state.copy(
            isLoading: true
        )
        scope.launchRealm {
            await self.app.project.lecturer.getLecturerFollowed(studentId) { r in
                if (r.value.isEmpty) {
                    self.scope.launchMain {
                        self.state = self.state.copy(followedArticles: [], isLoading: false)
                    }
                    return
                }
                self.doAllArticlesFollowers(list: r.value)
            }
        }
    }
    
    private func doAllArticlesFollowers(list: [Lecturer]) {
        scope.launchRealm {
            await self.app.project.article.getAllArticlesFollowed(list.map { it in it._id.stringValue }) { r in
                if (r.result == REALM_SUCCESS) {
                    let art = r.value.toArticleForData()
                    self.scope.launchMain {
                        self.state = self.state.copy(followedArticles: art, isLoading: false
                        )
                    }
                }
            }
        }
    }
    
    @MainActor
    func allCourses() {
        state = state.copy(
            isLoading: true
        )
        scope.launchRealm {
            await self.app.project.course.getAllCourses { r in
                if r.result == REALM_SUCCESS {
                    let courses = r.value.toCourseForData(currentTime)
                    self.scope.launchMain {
                        self.state = self.state.copy(allCourses: courses, isLoading: false)
                    }
                }
            }
        }
    }
    
    struct State {
        var courses: [CourseForData] = []
        var sessionForDisplay: [SessionForDisplay] = []
        var followedCourses: [CourseForData] = []
        var allCourses: [CourseForData] = []
        var followedArticles: [ArticleForData] = []
        var allArticles: [ArticleForData] = []
        var isOrderSectionVisible: Bool = false
        var currentTab: Int = 0
        var isLoading: Bool = false
        
        mutating func copy(
            courses: [CourseForData]? = nil,
            sessionForDisplay: [SessionForDisplay]? = nil,
            followedCourses: [CourseForData]? = nil,
            allCourses: [CourseForData]? = nil,
            followedArticles: [ArticleForData]? = nil,
            allArticles: [ArticleForData]? = nil,
            isOrderSectionVisible: Bool? = nil,
            currentTab: Int? = nil,
            isLoading: Bool? = nil
        ) -> Self {
            self.courses = courses ?? self.courses
            self.sessionForDisplay = sessionForDisplay ?? self.sessionForDisplay
            self.followedCourses = followedCourses ?? self.followedCourses
            self.allCourses = allCourses ?? self.allCourses
            self.followedArticles = followedArticles ?? self.followedArticles
            self.allArticles = allArticles ?? self.allArticles
            self.isOrderSectionVisible = isOrderSectionVisible ?? self.isOrderSectionVisible
            self.currentTab = currentTab ?? self.currentTab
            self.isLoading = isLoading ?? self.isLoading
            return self
        }
    }
    
}
