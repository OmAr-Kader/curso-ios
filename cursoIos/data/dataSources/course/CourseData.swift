
class CourseData {
    
    var repository: CourseRepo
    
    init(repository: CourseRepo) {
        self.repository = repository
    }
 
    @BackgroundActor
    func getAllCourses(
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getAllCourses(course: course)
    }

    @BackgroundActor
    func getStudentCourses(
        _ id: String,
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getStudentCourses(id: id, course: course)
    }
    
    @BackgroundActor
    func getAllCoursesFollowed(
        _ lecturerIds: Array<String>,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getAllCourses { r in
            let it = r.value.filter { it in
                lecturerIds.contains(it.lecturerId)
            }
            course(ResultRealm(value: it, result: r.result))
        }
    }

    
    @BackgroundActor
    func getCoursesById(
        _ id: String,
        _ course: (ResultRealm<Course?>) -> Unit
    ) async {
        await repository.getCoursesById(id: id, course: course)
    }

    @BackgroundActor
    func getLecturerCourses(
        _ id: String,
        _ course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await repository.getLecturerCourses(id: id, course: course)
    }

    @BackgroundActor
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

    @BackgroundActor
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

    @BackgroundActor
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

    @BackgroundActor
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

    @BackgroundActor
    func insertCourse(_ course: Course) async -> ResultRealm<Course?> {
        return await repository.insertCourse(course: course)
    }

    @BackgroundActor
    func editCourse(_ course: Course,_ edit: Course) async -> ResultRealm<Course?> {
        return await repository.editCourse(course: course, edit: edit)
    }

    @BackgroundActor
    func deleteCourse(_ course: Course) async -> Int {
        return await repository.deleteCourse(course: course)
    }

}
