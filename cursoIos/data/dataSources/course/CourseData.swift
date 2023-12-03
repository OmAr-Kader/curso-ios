import Foundation

class CourseData {
    
    var repository: CourseRepo
    
    init(repository: CourseRepo) {
        self.repository = repository
    }
 
    func getAllCourses(
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getAllCourses(course: course)
    }

    func getStudentCourses(
        _ id: String,
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getStudentCourses(id: id, course: course)
    }
    
    func getCoursesById(
        _ id: String,
        _ course: (ResultRealm<Course?>) -> Unit
    ) async {
        await repository.getCoursesById(id: id, course: course)
    }

    func getLecturerCourses(
        _ id: String,
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getLecturerCourses(id: id, course: course)
    }

    func getAvailableLecturerTimeline(
        _ id: String,
        _ currentTime: Int64,
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getAvailableLecturerTimeline(
            id: id,
            currentTime: currentTime,
            course: course
        )
    }

    func getUpcomingLecturerTimeline(
        _ id: String,
        _ currentTime: Int64,
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getUpcomingLecturerTimeline(
            id: id,
            currentTime: currentTime,
            course: course
        )
    }

    func getAvailableStudentTimeline(
        _ id: String,
        _ currentTime: Int64,
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getAvailableStudentTimeline(
            id: id,
            currentTime: currentTime,
            course: course
        )
    }

    func getUpcomingStudentTimeline(
        _ id: String,
        _ currentTime: Int64,
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getUpcomingStudentTimeline(
            id: id,
            currentTime: currentTime,
            course: course
        )
    }

    func insertCourse(_ course: Course) async -> ResultRealm<Course?> {
        return await repository.insertCourse(course: course)
    }

    func editCourse(_ course: Course,_ edit: Course) async -> ResultRealm<Course?> {
        return await repository.editCourse(course: course, edit: edit)
    }

    func deleteCourse(_ course: Course) async -> Int {
        return await repository.deleteCourse(course: course)
    }

}
