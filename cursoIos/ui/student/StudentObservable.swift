import Foundation

class StudentObservable : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    @MainActor
    var certificatesRate: Double {
        return state.certificates.ifNotEmpty { it in
            var sum: Double = 0
            it.forEach { it in
                sum += it.rate
            }
            return sum / Double(state.certificates.count)
        } ?? 0.0
    }

    func fetchStudent(studentId: String) {
        scope.launchRealm {
            await self.app.project.student.getStudent(studentId) { r in
                if r.value != nil {
                    self.scope.launchMain {
                        self.state = self.state.copy(student: StudentForData(update: r.value!))
                    }
                    self.doFetchStudentCourses(studentId: studentId, studentName: r.value!.studentName)
                }
            }
        }
    }
    
    private func doFetchStudentCourses(studentId: String, studentName: String) {
        scope.launchMain {
            self.state = self.state.copy(courses: [])
        }
        scope.launchRealm {
            await self.app.project.course.getStudentCourses(studentId) { r in
                if (r.result == REALM_SUCCESS) {
                    self.scope.launchMain {
                        self.state = self.state.copy(courses: r.value.toCourseForData(currentTime))
                    }
                }
                self.doFetchStudentTimeline(studentId: studentId, studentName: studentName)
            }
        }
    }

    
    private func doFetchStudentTimeline(studentId: String, studentName: String) {
        scope.launchRealm {
            await self.app.project.course.getUpcomingStudentTimeline(studentId, currentTime
            ) { it in
                self.scope.launchMain {
                    let it = self.state.courses.sorted { c1, c2 in
                        return c1.lastEdit < c2.lastEdit
                    }.splitCourses(studentId: studentId, studentName: studentName)
                    self.state = self.state.copy(sessionForDisplay: it)
                }
            }
        }
    }
    
    struct State {
        var student: StudentForData = StudentForData()
        var sessionForDisplay: [SessionForDisplay] = []
        var courses: [CourseForData] = []
        var certificates: [Certificate] = []
        
        mutating func copy(
            student: StudentForData? = nil,
            sessionForDisplay: [SessionForDisplay]? = nil,
            courses: [CourseForData]? = nil,
            certificates: [Certificate]? = nil
        ) -> Self {
            self.student = student ?? self.student
            self.sessionForDisplay = sessionForDisplay ?? self.sessionForDisplay
            self.courses = courses ?? self.courses
            self.certificates = certificates ?? self.certificates
            return self
        }
    }
    
    deinit {
        scope.deInit()	
    }
    
}
