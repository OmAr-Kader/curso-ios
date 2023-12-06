import Foundation
import RealmSwift
import FirebaseCore

struct Project {
    let realmApi: RealmApi
    let article: ArticleData
    let course: CourseData
    let lecturer: LecturerData
    let chat: ChatData
    let student: StudentData
    let preference: PreferenceData
    let fireApp: FirebaseApp?
}
