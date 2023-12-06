import Combine

protocol LecturerRepo {
    
    @BackgroundActor
    func getLecturerFollowed(
        studentId: String,
        lecturer: (ResultRealm<[Lecturer]>) -> Unit
    ) async

    @BackgroundActor
    func getLecturer(
        id: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async

    @BackgroundActor
    func getLecturerFlow(
        id: String,
        invoke: @escaping (Lecturer?) -> Unit
    ) async -> AnyCancellable?

    @BackgroundActor
    func getLecturerEmail(
        email: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async

    @BackgroundActor
    func insertLecturer(lecturer: Lecturer) async -> ResultRealm<Lecturer?>

    @BackgroundActor
    func editLecturer(lecturer: Lecturer, edit: Lecturer) async -> ResultRealm<Lecturer?>

}
