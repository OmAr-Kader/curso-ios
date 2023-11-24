import Foundation

class StudentData {
    
    var repository: StudentRepo
    
    init(repository: StudentRepo) {
        self.repository = repository
    }
    
    func getStudent(
        id: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async {
        await repository.getStudent(id: id, student: student)
    }

    func getStudentEmail(
        email: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async {
        await repository.getStudentEmail(email: email, student: student)
    }

    func insertStudent(student: Student) async -> ResultRealm<Student?> {
        return await repository.insertStudent(student: student)
    }

}
