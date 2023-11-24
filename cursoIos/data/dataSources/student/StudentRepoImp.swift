import Foundation
import RealmSwift

class StudentRepoImp : BaseRepoImp, StudentRepo {
    
    func getStudent(
        id: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async {
        do {
            let realmId = try ObjectId.init(string: id)
            await querySingle(
                student,
                "getStudent$id",
                "partition == $0 AND _id == $1",
                ["public", realmId])
        } catch {
            student(ResultRealm(value: nil, result: REALM_FAILED))
        }
    }

    func getStudentEmail(
        email: String,
        student: (ResultRealm<Student?>) -> Unit
    ) async {
        return await querySingle(
            student,
            "getStudentEmail$email",
            "partition == $0 AND email == $1",
            ["public", email])

    }

    func insertStudent(student: Student) async -> ResultRealm<Student?> {
        return await self.insert(student)
    }
}
