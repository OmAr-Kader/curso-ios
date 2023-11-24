import Foundation

protocol StudentRepo {
    
    func getStudent(
        id: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async

    func getStudentEmail(
        email: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async

    func insertStudent(student: Student) async -> ResultRealm<Student?>
    
}
