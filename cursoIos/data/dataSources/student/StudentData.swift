
class StudentData {
    
    var repository: StudentRepo
    
    init(repository: StudentRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func getStudent(
        _ id: String,
        _ student: (ResultRealm<Student?>) -> Unit
    ) async {
        await repository.getStudent(id: id, student: student)
    }

    @BackgroundActor
    func getStudentEmail(
        _ email: String,
        _ student: (ResultRealm<Student?>) -> Unit
    ) async {
        await repository.getStudentEmail(email: email, student: student)
    }

    @BackgroundActor
    func insertStudent(_ student: Student) async -> ResultRealm<Student?> {
        return await repository.insertStudent(student: student)
    }

}
