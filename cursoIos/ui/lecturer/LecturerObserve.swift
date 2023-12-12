import Foundation
import RealmSwift
import Combine

class LecturerObserve : ObservableObject {
    
    private var scope = Scope()
    private var sinkLecturer: AnyCancellable? = nil
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }

    @MainActor
    var lecturerRate: String {
        let it = state.lecturer
        return it.rate == 0.0 ? "5" : String(it.rate)
    }

    @MainActor
    func lecturerFollowers(mode: Int) -> String {
        let it = state.lecturer
        if (mode == 1) {
            return it.follower.isEmpty ? "Be First" : String(it.follower.count)
        } else {
            return String(it.follower.count)
        }
    }

    @MainActor
    private func setStudentId(_ studentId: String) {
        state = state.copy(studentId: studentId)
    }
    
    @MainActor
    func fetchLecturer(lecturerId: String, studentId: String) {
        setStudentId(studentId)
        scope.launchRealm {
            self.sinkLecturer = await self.app.project.lecturer.getLecturerFlow(id: lecturerId) { object in
                print("www" + (object?.lecturerName ?? ""))
                guard let object else {
                    return
                }
                let value = LecturerForData(update: object)
                let isAlready = value.follower.alreadyFollowed(studentId)
                self.scope.launchMain {
                    self.state = self.state.copy(
                        lecturer: value,
                        alreadyFollowed: isAlready
                    )
                }
            }
        }
        self.getCoursesForLecturer(lecturerId)
    }

    private func getCoursesForLecturer(_ lecturerId: String) {
        scope.launchRealm {
            await self.app.project.course.getLecturerCourses(lecturerId) { r in
                self.getArticlesForLecturer(lecturerId, r)
            }
        }
    }
    
    private func getArticlesForLecturer(_ lecturerId: String, _ coursesList: ResultRealm<[Course]>) {
        scope.launchRealm {
            await self.app.project.article.getLecturerArticles(lecturerId) { r in
                if (r.result == REALM_SUCCESS) {
                    let courses = coursesList.value.toCourseForData(currentTime)
                    let articles = r.value.toArticleForData()
                    self.scope.launchMain { [courses, articles] in
                        self.state = self.state.copy(
                            courses: courses,
                            articles: articles
                        )
                    }
                }
            }
        }
    }
    
    @MainActor
    func followUnfollow(
        _ studentId: String,
        _ alreadyFollowed: Bool,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        if (alreadyFollowed) {
            unFollow(self.state.lecturer, studentId, invoke, failed)
        } else {
            follow(self.state.lecturer, studentId, invoke, failed)
        }
    }

    private func follow(
        _ lec: LecturerForData,
        _ studentId: String,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        scope.launchRealm {
            await self.app.project.student.getStudent(studentId) { r in
                self.doFollow(lec, r.value, invoke, failed)
            }
        }
    }
    
    private func doFollow(
        _ lec: LecturerForData,
        _ value: Student?,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        if (value == nil) {
            failed()
        } else {
            scope.launchRealm {
                var followers: [StudentLecturerData] = (lec.follower)
                let new = StudentLecturerData(
                    studentId: value!._id.stringValue,
                    studentName: value!.studentName
                )
                followers.append(new)
                let lecturer = Lecturer(update: lec)
                let it = await self.app.project.lecturer.editLecturer(
                    lecturer,
                    Lecturer(update: lecturer, hexString: lecturer._id.stringValue, followers: followers.toStudentLecturer())
                )
                if (it.result == REALM_SUCCESS && it.value != nil) {
                    subscribeToTopic(it.value!._id.stringValue) {

                    }
                    self.scope.launchMain {
                        invoke()
                    }
                } else {
                    self.scope.launchMain {
                        failed()
                    }
                }
            }
        }
    }

    private func unFollow(
        _ lec: LecturerForData,
        _ studentId: String,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        scope.launchRealm {
            let followers: [StudentLecturerData] = (lec.follower)
            let list = followers.filter { it in it.studentId != studentId }
            let lecturer = Lecturer(update: lec)
            let it = await self.app.project.lecturer.editLecturer(
                lecturer,
                Lecturer(update: lecturer, hexString: lecturer._id.stringValue, followers: list.toStudentLecturer())
            )
            if (it.result == REALM_SUCCESS && it.value != nil) {
                unsubscribeToTopic(it.value!._id.stringValue)
                self.scope.launchMain {
                    invoke()
                }
            } else {
                self.scope.launchMain {
                    failed()
                }
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
        sinkLecturer?.cancel()
        sinkLecturer = nil
        scope.deInit()
    }
    
}
