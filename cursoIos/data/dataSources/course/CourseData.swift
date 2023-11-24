import Foundation

class CourseData {
    
    var repository: CourseRepo
    
    init(repository: CourseRepo) {
        self.repository = repository
    }
 
    func getAllCourses(
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getAllCourses(course: course)
    }

    func getStudentCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getStudentCourses(id: id, course: course)
    }
    
    func getCoursesById(
        id: String,
        course: (ResultRealm<Course?>) -> Unit
    ) async {
        await repository.getCoursesById(id: id, course: course)
    }

    func getLecturerCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getLecturerCourses(id: id, course: course)
    }

    func getAvailableLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getAvailableLecturerTimeline(
            id: id,
            currentTime: currentTime,
            course: course
        )
    }

    func getUpcomingLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getUpcomingLecturerTimeline(
            id: id,
            currentTime: currentTime,
            course: course
        )
    }

    func getAvailableStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getAvailableStudentTimeline(
            id: id,
            currentTime: currentTime,
            course: course
        )
    }

    func getUpcomingStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getUpcomingStudentTimeline(
            id: id,
            currentTime: currentTime,
            course: course
        )
    }

    func insertCourse(course: Course) async -> ResultRealm<Course?> {
        return await repository.insertCourse(course: course)
    }

    func editCourse(course: Course, edit: Course) async -> ResultRealm<Course?> {
        return await repository.editCourse(course: course, edit: edit)
    }

    func deleteCourse(course: Course) async -> Int {
        return await repository.deleteCourse(course: course)
    }

}
