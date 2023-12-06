
protocol StudentRepo {
    
    @BackgroundActor
    func getStudent(
        id: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async

    @BackgroundActor
    func getStudentEmail(
        email: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async

    @BackgroundActor
    func insertStudent(student: Student) async -> ResultRealm<Student?>
    
}
