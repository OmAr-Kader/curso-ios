import Foundation
import RealmSwift
import os

var listOfOnlyLocalSchemaRealmClass: [ObjectBase.Type] {
    return [Preference.self]
}

var listOfSchemaRealmClass: [ObjectBase.Type] {
    return [
    Conversation.self,
    Lecturer.self,
    Course.self,
    Certificate.self,
    Student.self,
    Article.self,
    ]
}

var listOfSchemaEmbeddedRealmClass: [ObjectBase.Type] {
    return [
        Message.self,
        Timeline.self,
        AboutCourse.self,
        StudentCourses.self,
        StudentLecturer.self,
        ArticleText.self,
    ]
}

public func logger(_ tag: String,_ it: String) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    logger.log("==> \(tag) \(it)")
}

public func loggerError(_ tag: String,_ it: String) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    logger.log("==> \(tag) \(it)")
}
    

