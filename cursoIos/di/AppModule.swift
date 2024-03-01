import Foundation
import RealmSwift
import FirebaseCore
import SwiftUI
//https://github.com/realm/realm-swift
//https://github.com/firebase/firebase-ios-sdk

class AppModule: ObservableObject {
    
    private let pro: Project
    var project: Project {
        return pro
    }

    init() {
        let realmApi = RealmApi(app: App(id: REALM_APP_ID))
        let articleRepo = ArticleRepoImp(realmApi: realmApi)
        let chatRepo = ChatRepoImp(realmApi: realmApi)
        let courseRepo = CourseRepoImp(realmApi: realmApi)
        let lecturerRepo = LecturerRepoImp(realmApi: realmApi)
        let studentRepo = StudentRepoImp(realmApi: realmApi)
        let preferenceRepo = PrefRepoImp(realmApi: realmApi)
        pro = Project(
            realmApi: realmApi,
            article: ArticleData(repository: articleRepo),
            course: CourseData(repository: courseRepo),
            lecturer: LecturerData(repository: lecturerRepo),
            chat: ChatData(repository: chatRepo),
            student: StudentData(repository: studentRepo),
            preference: PreferenceData(repository: preferenceRepo),
            fireApp: FirebaseApp.app()
        )
    }
}

