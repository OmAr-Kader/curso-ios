import Foundation

class HomeStudentObservable : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
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
            sessionForDisplay: [SessionForDisplay]? = nil,
            followedCourses: [CourseForData]? = nil,
            isOrderSectionVisible: Bool? = nil,
            currentTab: Int? = nil,
            isLoading: Bool? = nil
        ) -> Self {
            self.sessionForDisplay = sessionForDisplay ?? self.sessionForDisplay
            self.followedCourses = followedCourses ?? self.followedCourses
            self.isOrderSectionVisible = isOrderSectionVisible ?? self.isOrderSectionVisible
            self.currentTab = currentTab ?? self.currentTab
            self.isLoading = isLoading ?? self.isLoading
            return self
        }
    }
    
}
