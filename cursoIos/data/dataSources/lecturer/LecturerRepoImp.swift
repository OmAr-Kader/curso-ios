import Foundation
import RealmSwift
import Combine

class LecturerRepoImp : BaseRepoImp, LecturerRepo {

    @BackgroundActor
    func getLecturerFollowed(
        studentId: String,
        lecturer: (ResultRealm<[Lecturer]>) -> Unit
    ) async {
        await query(
            lecturer,
            "getLecturerFollowed\(studentId)",
            "%K == %@ AND %K == %@",
            "partition", "public", 
            "follower.studentId", NSString(string: studentId)
        )
    }
    
    @BackgroundActor
    func getLecturer(
        id: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async {
        do {
            let realmId = try ObjectId.init(string: id)
            await querySingle(
                lecturer,
                "getLecturer$id",
                "%K == %@ AND %K == %@",
                "partition", "public", "_id", realmId
            )
        } catch {
            lecturer(ResultRealm(value: nil, result: REALM_FAILED))
        }
    }
    
    @BackgroundActor
    func getLecturerFlow(
        id: String,
        invoke: @escaping (Lecturer?) -> Unit
    ) async -> AnyCancellable? {
        do {
            let realmId = try ObjectId.init(string: id)
            return await querySingleFlow(
                invoke,
                "getLecturer\(id)",
                "%K == %@ AND %K == %@",
                "partition","public", "_id", realmId
            )
        } catch {
            return nil
        }
    }
    
    @BackgroundActor
    func getLecturerEmail(
        email: String,
        lecturer: (ResultRealm<Lecturer?>) -> Unit
    ) async {
        await querySingle(
            lecturer,
            "getLecturerEmail\(email)",
            "%K == %@ AND %K == %@", "partition", "public", "email", NSString(string: email)
        )
    }
    
    @BackgroundActor
    func insertLecturer(lecturer: Lecturer) async -> ResultRealm<Lecturer?> {
        await insert(lecturer)
    }
    
    @BackgroundActor
    func editLecturer(
        lecturer: Lecturer,
        edit: Lecturer
    ) async -> ResultRealm<Lecturer?> {
        await self.edit(lecturer._id) { it in it.copy(edit) }
    }
}
