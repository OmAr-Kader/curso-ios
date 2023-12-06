import Combine

class LecturerData {
    
    var repository: LecturerRepo
    
    init(repository: LecturerRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func getLecturerFollowed(
        _ studentId: String,
        _ lecturer: (ResultRealm<[Lecturer]>) -> Unit
    ) async {
        await repository.getLecturerFollowed(studentId: studentId, lecturer: lecturer)
    }
    
    @BackgroundActor
    func getLecturer(
        _ id: String,
        _ lecturer: @escaping (ResultRealm<Lecturer?>) -> Unit
    ) async {
        await repository.getLecturer(id: id, lecturer: lecturer)
    }

    @BackgroundActor
    func getLecturerFlow(
        id: String,
        invoke: @escaping (Lecturer?) -> Unit
    ) async -> AnyCancellable? {
        return await repository.getLecturerFlow(id: id, invoke: invoke)
    }

    @BackgroundActor
    func getLecturerEmail(
        _ email: String,
        _ lecturer: @escaping (ResultRealm<Lecturer?>) -> Unit
    ) async {
        await repository.getLecturerEmail(email: email, lecturer: lecturer)
    }

    @BackgroundActor
    func insertLecturer(_ lecturer: Lecturer) async -> ResultRealm<Lecturer?> {
        return await repository.insertLecturer(lecturer: lecturer)
    }

    @BackgroundActor
    func editLecturer(
        _ lecturer: Lecturer,
        _ edit: Lecturer
    ) async -> ResultRealm<Lecturer?> {
        return await repository.editLecturer(lecturer: lecturer, edit: edit)
    }
     
}
