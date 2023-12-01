import Foundation

class LecturerData {
    
    var repository: LecturerRepo
    
    init(repository: LecturerRepo) {
        self.repository = repository
    }
    
    func getLecturerFollowed(
        _ studentId: String,
        _ lecturer: (ResultRealm<[Lecturer]>) -> Unit
    ) async {
        await repository.getLecturerFollowed(studentId: studentId, lecturer: lecturer)
    }
    
    func getLecturer(
        _ id: String,
        _ lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async {
        await repository.getLecturer(id: id, lecturer: lecturer)
    }

    func getLecturerFlow(
        _ id: String
    ) async-> ResultRealm<Lecturer?> {
        return await repository.getLecturerFlow(id: id)
    }

    func getLecturerEmail(
        _ email: String,
        _ lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async {
        await repository.getLecturerEmail(email: email, lecturer: lecturer)
    }

    func insertLecturer(_ lecturer: Lecturer) async -> ResultRealm<Lecturer?> {
        return await repository.insertLecturer(lecturer: lecturer)
    }

    func editLecturer(
        _ lecturer: Lecturer,
        _ edit: Lecturer
    ) async -> ResultRealm<Lecturer?> {
        return await repository.editLecturer(lecturer: lecturer, edit: edit)
    }
     
}
