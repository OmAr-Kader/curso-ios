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


/*
 func provideFirebaseApp() -> FirebaseApp? {
     return FirebaseApp.app()
 }
 
 func provideRealmApp() -> RealmSwift.App {
     return App(id: REALM_APP_ID)
 }
 
 func provideRealmSync(app: RealmSwift.App) -> Realm? {
     /*if(!isNetworkAvailable()) {
         return nil
     }*/
     let user = app.currentUser
     if (user == nil) {
         return nil
     }
     do {
         let serialQueue = DispatchQueue(label: "serial-queue")
         return try Realm(
             configuration: user!.initialSubscriptionBlock,
             queue: serialQueue
         )
     } catch {
         return nil
     }
 }
 
 func provideRealmCloud() -> RealmSync {
     let app = provideRealmApp()
     return RealmSync(app: app, realm: provideRealmSync(app: app))
 }
 
 func provideRealm() -> Realm {
     var config =  Realm.Configuration(
         inMemoryIdentifier: "CursoIos"
     )
     config.objectTypes = listOfOnlyLocalSchemaRealmClass
     config.schemaVersion = SCHEMA_VERSION
     config.eventConfiguration?.errorHandler = { error in
         
     }
     let serialQueue = DispatchQueue(label: "serial-queue-local")
     return try! Realm(configuration: config, queue: serialQueue)
 }
 
 func provideArticleRepo(realmSync: RealmSync) -> ArticleRepo {
     return ArticleRepoImp(realmSync: realmSync)
 }
 
 func provideChatRepo(realmSync: RealmSync) -> ChatRepoImp {
     return ChatRepoImp(realmSync: realmSync)
 }
 
 func provideCourseRepo(realmSync: RealmSync) -> CourseRepoImp {
     return CourseRepoImp(realmSync: realmSync)
 }
 
 func provideLecturerRepo(realmSync: RealmSync) -> LecturerRepoImp {
     return LecturerRepoImp(realmSync: realmSync)
 }

 func provideStudentRepo(realmSync: RealmSync) -> StudentRepoImp {
     return StudentRepoImp(realmSync: realmSync)
 }
 
 func providePreferenceRepo(realm: Realm) -> PrefRepoImp {
     return PrefRepoImp(realm: realm)
 }
 
 func provideProjcet() -> Project {
     let realmCloud = provideRealmCloud()
     let realm = provideRealm()
     let articleRepo = provideArticleRepo(realmSync: realmCloud)
     let chatRepo = provideChatRepo(realmSync: realmCloud)
     let courseRepo = provideCourseRepo(realmSync: realmCloud)
     let lecturerRepo = provideLecturerRepo(realmSync: realmCloud)
     let studentRepo = provideStudentRepo(realmSync: realmCloud)
     let preferenceRepo = providePreferenceRepo(realm: realm)
     return Project(
         realmSync: realmCloud,
         article: ArticleData(repository: articleRepo),
         course: CourseData(repository: courseRepo),
         lecturer: LecturerData(repository: lecturerRepo),
         chat: ChatData(repository: chatRepo),
         student: StudentData(repository: studentRepo),
         preference: PreferenceData(repository: preferenceRepo),
         fireApp: provideFirebaseApp()
     )
 }
 */
