import Foundation
import RealmSwift


class Lecturer : Object {

    @Persisted var lecturerName: String
    @Persisted(indexed: true) var email: String = ""
    @Persisted var mobile: String
    @Persisted var rate: Double
    @Persisted var raters: Int
    @Persisted var brief: String
    @Persisted var imageUri: String
    @Persisted var specialty: String
    @Persisted var university: String
    @Persisted(indexed: true) var approved: Bool = true
    @Persisted var follower: List<StudentLecturer>
    @Persisted var partition: String = "public"
    @Persisted(primaryKey: true) var _id: ObjectId
    
    convenience init(
        lecturerName: String,
        email: String,
        mobile: String, 
        rate: Double,
        raters: Int,
        brief: String,
        imageUri: String,
        specialty: String,
        university: String,
        approved: Bool
    ) {
        self.init()
        self.lecturerName = lecturerName
        self.email = email
        self.mobile = mobile
        self.rate = rate
        self.raters = raters
        self.brief = brief
        self.imageUri = imageUri
        self.specialty = specialty
        self.university = university
        self.approved = approved
        follower = List()
    }
    
    override init() {
        self.lecturerName = ""
        self.email = ""
        self.mobile = ""
        self.rate = 5.0
        self.raters = 0
        self.brief = ""
        self.imageUri = ""
        self.specialty = ""
        self.university = ""
        self.approved = false
        self.follower = List()
    }

    convenience init(update: LecturerForData) {
        self.init()
        self.lecturerName = update.lecturerName
        self.email = update.email
        self.mobile = update.mobile
        self.rate = update.rate
        self.raters = update.raters
        self.brief = update.brief
        self.imageUri = update.imageUri
        self.specialty = update.specialty
        self.university = update.university
        self.approved = update.approved
        follower = update.follower.toStudentLecturer()
        catchy {
            try self._id = ObjectId.init(string: update.id)
        }
    }

    convenience init(update: Lecturer, hexString: String, followers: List<StudentLecturer>) {
        self.init()
        self.lecturerName = update.lecturerName
        self.email = update.email
        self.mobile = update.mobile
        self.rate = update.rate
        self.raters = update.raters
        self.brief = update.brief
        self.imageUri = update.imageUri
        self.specialty = update.specialty
        self.university = update.university
        self.approved = update.approved
        self.follower = followers
        catchy {
            try self._id = ObjectId.init(string: hexString)
        }
    }

    convenience init(update: Lecturer, hexString: String) {
        self.init()
        self.lecturerName = update.lecturerName
        self.email = update.email
        self.mobile = update.mobile
        self.rate = update.rate
        self.raters = update.raters
        self.brief = update.brief
        self.imageUri = update.imageUri
        self.specialty = update.specialty
        self.university = update.university
        self.approved = update.approved
        self.follower = update.follower
        catchy {
            try self._id = ObjectId.init(string: hexString)
        }
    }

    @discardableResult func copy(_ update: Lecturer) -> Lecturer {
        lecturerName = update.lecturerName
        mobile = update.mobile
        email = update.email
        rate = update.rate
        raters = update.raters
        follower = update.follower
        brief = update.brief
        specialty = update.specialty
        university = update.university
        imageUri = update.imageUri
        approved = update.approved
        return self
    }

}


class StudentLecturer: EmbeddedObject {

    @Persisted(indexed: true) var studentId: String = ""

    @Persisted(indexed: true) var studentName: String = ""
        
    override init() {
        self.studentId = ""
        self.studentName = ""
   }
    
    convenience init(update: StudentLecturerData) {
        self.init()
        studentId = update.studentId
        studentName = update.studentName
    }
}

struct LecturerForData {
    var lecturerName: String
    var email: String
    var mobile: String
    var rate: Double
    var raters: Int
    var brief: String
    var imageUri: String
    var specialty: String
    var university: String
    var approved: Bool
    var follower: [StudentLecturerData]
    var id: String
    
    init(){
        self.lecturerName = ""
        self.email = ""
        self.mobile = ""
        self.rate = 5.0
        self.raters = 0
        self.brief = ""
        self.imageUri = ""
        self.specialty = ""
        self.university = ""
        self.approved = false
        self.follower = [StudentLecturerData]()
        self.id = ""
    }

    init(update: Lecturer) {
        self.init()
        lecturerName = update.lecturerName
        email = update.email
        mobile = update.mobile
        rate = update.rate
        raters = update.raters
        brief = update.brief
        imageUri = update.imageUri
        specialty = update.specialty
        university = update.university
        approved = update.approved
        follower = update.follower.toStudentLecturerData()
        id = update._id.stringValue
    }
}

struct StudentLecturerData {
    
    var studentId: String = ""
    var studentName: String = ""

    init() {
        self.studentId = ""
        self.studentName = ""
    }

    init(update: StudentLecturer) {
        self.init()
        self.studentId = update.studentId
        self.studentName = update.studentName
    }
    
    init(studentId: String, studentName: String) {
        self.studentName = studentName
        self.studentName = studentName
    }
    
}
