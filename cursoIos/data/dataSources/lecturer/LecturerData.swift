import Foundation

class LecturerData {
    
    var repository: LecturerRepo
    
    init(repository: LecturerRepo) {
        self.repository = repository
    }
    
    func getLecturerFollowed(
        studentId: String,
        lecturer: (ResultRealm<[Lecturer]>) -> Unit
    ) async {
        await repository.getLecturerFollowed(studentId: studentId, lecturer: lecturer)
    }
    
    func getLecturer(
        id: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async {
        await repository.getLecturer(id: id, lecturer: lecturer)
    }

    func getLecturerFlow(
        id: String
    ) async-> ResultRealm<Lecturer?> {
        return await repository.getLecturerFlow(id: id)
    }

    func getLecturerEmail(
        email: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async {
        await repository.getLecturerEmail(email: email, lecturer: lecturer)
    }

    func insertLecturer(lecturer: Lecturer) async -> ResultRealm<Lecturer?> {
        return await repository.insertLecturer(lecturer: lecturer)
    }

    func editLecturer(
        lecturer: Lecturer,
        edit: Lecturer
    ) async -> ResultRealm<Lecturer?> {
        return await repository.editLecturer(lecturer: lecturer, edit: edit)
    }
     
}
