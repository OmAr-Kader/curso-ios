import Foundation

class StudentData {
    
    var repository: StudentRepo
    
    init(repository: StudentRepo) {
        self.repository = repository
    }
    
    func getStudent(
        _ id: String,
        _ student: (ResultRealm<Student?>) -> Unit
    ) async {
        await repository.getStudent(id: id, student: student)
    }

    func getStudentEmail(
        _ email: String,
        _ student: (ResultRealm<Student?>) -> Unit
    ) async {
        await repository.getStudentEmail(email: email, student: student)
    }

    func insertStudent(_ student: Student) async -> ResultRealm<Student?> {
        return await repository.insertStudent(student: student)
    }

}
