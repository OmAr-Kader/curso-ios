import Foundation
import RealmSwift

class LecturerRepoImp : BaseRepoImp, LecturerRepo {

    func getLecturerFollowed(
        studentId: String,
        lecturer: (ResultRealm<[Lecturer]>) -> Unit
    ) async {
        await query(
            lecturer,
            "getLecturerFollowed$studentId",
            "partition == $0 AND follower.studentId == $1",
            ["public", studentId]
        )
    }
    
    func getLecturer(
        id: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async {
        do {
            let realmId = try ObjectId.init(string: id)
            await querySingle(
                lecturer,
                "getLecturer$id",
                "partition == $0 AND _id == $1",
                ["public", realmId]
            )
        } catch {
            lecturer(ResultRealm(value: nil, result: REALM_FAILED))
        }
    }
    
    func getLecturerFlow(
        id: String
    ) async -> ResultRealm<Lecturer?> {
        do {
            let realmId = try ObjectId.init(string: id)
            return await querySingleFlow(
                "getLecturer$id",
                "partition == $0 AND _id == $1",
                ["public", realmId]
            )
        } catch {
            return ResultRealm(value: nil, result: REALM_FAILED)
        }
    }
    
    func getLecturerEmail(
        email: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async {
        await querySingle(lecturer, "getLecturerEmail$email", "partition == $0 AND email == $1", ["public", email])
    }
    
    func insertLecturer(lecturer: Lecturer) async -> ResultRealm<Lecturer?> {
        await insert(lecturer)
    }
    
    func editLecturer(
        lecturer: Lecturer,
        edit: Lecturer
    ) async -> ResultRealm<Lecturer?> {
        await self.edit(lecturer._id) { it in it.copy(edit) }
    }
}
