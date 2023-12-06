import Foundation
import RealmSwift

class StudentRepoImp : BaseRepoImp, StudentRepo {
    
    @BackgroundActor
    func getStudent(
        id: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async {
        do {
            let realmId = try ObjectId.init(string: id)
            await querySingle(
                student,
                "getStudent\(id)",
                "%K == %@ AND %K == %@",
                "partition", "public",
                "_id", realmId
            )
        } catch {
            student(ResultRealm(value: nil, result: REALM_FAILED))
        }
    }

    @BackgroundActor
    func getStudentEmail(
        email: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async {
        await querySingle(
            student,
            "getStudentEmail\(email)",
            "%K == %@ AND %K == %@",
            "partition", "public",
            "email", NSString(string: email)
        )
    }

    @BackgroundActor
    func insertStudent(student: Student) async -> ResultRealm<Student?> {
        return await self.insert(student)
    }
}
