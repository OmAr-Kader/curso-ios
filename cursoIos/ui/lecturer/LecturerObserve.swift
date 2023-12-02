import Foundation
import RealmSwift

class LecturerObserve : ObservableObject {
    
    private var scope = Scope()
    private var tokenFlow: NotificationToken? = nil
    
    let app: AppModule
    
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    
    var lecturerRate: String {
        let it = state.lecturer
        return it.rate == 0.0 ? "5" : String(it.rate)
    }

    func lecturerFollowers(mode: Int) -> String {
        let it = state.lecturer
        if (mode == 1) {
            return it.follower.isEmpty ? "Be First" : String(it.follower.count)
        } else {
            return String(it.follower.count)
        }
    }

    private func setStudentId(_ studentId: String) {
        state = state.copy(studentId: studentId)
    }
    
    func fetchLecturer(lecturerId: String, studentId: String) {
        setStudentId(studentId)
        scope.launch {
            self.tokenFlow = await self.app.project.lecturer.getLecturerFlow(lecturerId)
                .value?.observe(on: .global()) { changes in
                    switch changes {
                    case .change(let object, _):
                        let value = LecturerForData(update: object as! Lecturer)
                        self.state = self.state.copy(
                            lecturer: value,
                            alreadyFollowed: value.follower.alreadyFollowed(studentId)
                        )
                        self.getCoursesForLecturer(lecturerId)
                    default:
                        return
                    }
                }
        }
    }

    private func getCoursesForLecturer(_ lecturerId: String) {
        scope.launch {
            await self.app.project.course.getLecturerCourses(lecturerId) { r in
                if (r.result == REALM_SUCCESS) {
                    self.state = self.state.copy(courses: r.value.toCourseForData(currentTime))
                }
                self.getArticlesForLecturer(lecturerId)
            }
        }
    }
    
    private func getArticlesForLecturer(_ lecturerId: String) {
        scope.launch {
            await self.app.project.article.getLecturerArticles(lecturerId) { r in
                if (r.result == REALM_SUCCESS) {
                    self.state = self.state.copy(articles: r.value.toArticleForData())
                }
            }
        }
    }
    
    func followUnfollow(
        _ studentId: String,
        _ alreadyFollowed: Bool,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        if (alreadyFollowed) {
            unFollow(studentId, invoke, failed)
        } else {
            follow(studentId, invoke, failed)
        }
    }

    private func follow(
        _ studentId: String,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        scope.launch {
            await self.app.project.student.getStudent(studentId) { r in
                self.doFollow(r.value, invoke, failed)
            }
        }
    }
    
    private func doFollow(
        _ value: Student?,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        if (value == nil) {
            failed()
        } else {
            scope.launch {
                let l = self.state.lecturer
                var followers: [StudentLecturerData] = (l.follower)
                let new = StudentLecturerData(
                    studentId: value!._id.stringValue,
                    studentName: value!.studentName
                )
                followers.append(new)
                let lecturer = Lecturer(update: l)
                let it = await self.app.project.lecturer.editLecturer(
                    lecturer,
                    Lecturer(update: lecturer, hexString: lecturer._id.stringValue, followers: followers.toStudentLecturer())
                )
                if (it.result == REALM_SUCCESS && it.value != nil) {
                    subscribeToTopic(it.value!._id.stringValue) {

                    }
                    invoke()
                } else {
                    failed()
                }
            }
        }
    }

    private func unFollow(
        _ studentId: String,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        scope.launch {
            let l = self.state.lecturer
            let followers: [StudentLecturerData] = (l.follower)
            let list = followers.filter { it in it.studentId != studentId }
            let lecturer = Lecturer(update: l)
            let it = await self.app.project.lecturer.editLecturer(
                lecturer,
                Lecturer(update: lecturer, hexString: lecturer._id.stringValue, followers: list.toStudentLecturer())
            )
            if (it.result == REALM_SUCCESS && it.value != nil) {
                unsubscribeToTopic(it.value!._id.stringValue)
                invoke()
            } else {
                failed()
            }
        }
    }

    struct State {
        var lecturer: LecturerForData = LecturerForData()
        var studentId: String = ""
        var courses: [CourseForData] = []
        var articles: [ArticleForData] = []
        var alreadyFollowed: Bool = false
        
        mutating func copy(
            lecturer: LecturerForData? = nil,
            studentId: String? = nil,
            courses: [CourseForData]? = nil,
            articles: [ArticleForData]? = nil,
            alreadyFollowed: Bool? = nil
        ) -> Self {
            self.lecturer = lecturer ?? self.lecturer
            self.studentId = studentId ?? self.studentId
            self.courses = courses ?? self.courses
            self.articles = articles ?? self.articles
            self.alreadyFollowed = alreadyFollowed ?? self.alreadyFollowed
            return self
        }
    }
    
    deinit {
        tokenFlow?.invalidate()
        tokenFlow = nil
    }
    
}
