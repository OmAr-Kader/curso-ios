import Foundation

protocol CourseRepo {
    
    func getAllCourses(
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    func getStudentCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async
    
    func getCoursesById(
        id: String,
        course: (ResultRealm<Course?>) -> Unit
    ) async

    func getLecturerCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    func getAvailableLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    func getUpcomingLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    func getAvailableStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    func getUpcomingStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    func insertCourse(course: Course) async -> ResultRealm<Course?>

    func editCourse(course: Course, edit: Course) async -> ResultRealm<Course?>

    func deleteCourse(course: Course) async -> Int

}
