import Foundation

protocol LecturerRepo {
    
    func getLecturerFollowed(
        studentId: String,
        lecturer: (ResultRealm<[Lecturer]>) -> Unit
    ) async

    func getLecturer(
        id: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async

    func getLecturerFlow(
        id: String
    ) async-> ResultRealm<Lecturer?>

    func getLecturerEmail(
        email: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async

    func insertLecturer(lecturer: Lecturer) async -> ResultRealm<Lecturer?>

    func editLecturer(lecturer: Lecturer, edit: Lecturer) async -> ResultRealm<Lecturer?>

}
