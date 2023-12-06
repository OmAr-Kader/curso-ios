
protocol CourseRepo {
    
    @BackgroundActor
    func getAllCourses(
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    @BackgroundActor
    func getStudentCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async
    
    @BackgroundActor
    func getCoursesById(
        id: String,
        course: (ResultRealm<Course?>) -> Unit
    ) async

    @BackgroundActor
    func getLecturerCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    @BackgroundActor
    func getAvailableLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    @BackgroundActor
    func getUpcomingLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    @BackgroundActor
    func getAvailableStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    @BackgroundActor
    func getUpcomingStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async

    @BackgroundActor
    func insertCourse(course: Course) async -> ResultRealm<Course?>

    @BackgroundActor
    func editCourse(course: Course, edit: Course) async -> ResultRealm<Course?>

    @BackgroundActor
    func deleteCourse(course: Course) async -> Int

}
