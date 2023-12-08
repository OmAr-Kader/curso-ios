
import Foundation
import RealmSwift

class Student : Object {

    @Persisted var studentName: String
    @Persisted var email: String
    @Persisted var mobile: String
    @Persisted var imageUri: String
    @Persisted var specialty: String
    @Persisted var university: String
    @Persisted var partition: String = "public"
    @Persisted(primaryKey: true) var _id: ObjectId
        
    override init() {
        studentName = ""
        email = ""
        mobile = ""
        imageUri = ""
        specialty = ""
        university = ""
    }

    convenience init(update: StudentForData) {
        self.init()
        studentName = update.studentName
        email = update.email
        mobile = update.mobile
        imageUri = update.imageUri
        specialty = update.specialty
        university = update.university
        catchy {
            try _id = ObjectId.init(string: update.id)
        }
    }

    func copy(update: Student) -> Student {
        studentName = update.studentName
        email = update.email
        mobile = update.mobile
        specialty = update.specialty
        university = update.university
        imageUri = update.imageUri
        return self
    }
}


struct StudentForData {
    
    var studentName: String
    var email: String
    var mobile: String
    var imageUri: String
    var specialty: String
    var university: String
    var id: String

    init() {
        studentName = ""
        email = ""
        mobile = ""
        imageUri = ""
        specialty = ""
        university = ""
        id = ""
    }

    init(update: Student) {
        studentName = update.studentName
        email = update.email
        mobile = update.mobile
        imageUri = update.imageUri
        specialty = update.specialty
        university = update.university
        id = update._id.stringValue
    }
}
