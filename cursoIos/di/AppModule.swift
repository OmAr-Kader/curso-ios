import Foundation
import RealmSwift
import FirebaseCore
import SwiftUI
//https://github.com/realm/realm-swift
//https://github.com/firebase/firebase-ios-sdk

class AppModule: ObservableObject {
    
    var theme: Theme = Theme(isDarkMode: true)
    
    var pro: Project? = nil

    @MainActor
    init() {
        Task(priority: .high) {
            pro = await provideProjcet()
        }
    }

    func initTheme(isDarkMode: Bool) -> Self {
        self.theme = Theme(
            isDarkMode: isDarkMode
        )
        return self
    }
    
    func project() async -> Project {
        if(pro != nil) {
            return pro!
        } else {
            pro = await provideProjcet()
            return pro!
        }
    }
    
    @MainActor
    func provideFirebaseApp() -> FirebaseApp? {
        return FirebaseApp.app()
    }
    
    @MainActor
    func provideRealmApp() -> RealmSwift.App {
        return App(id: REALM_APP_ID)
    }
    
    @MainActor
    func provideRealmSync(app: RealmSwift.App) async -> Realm? {
        /*if(!isNetworkAvailable()) {
            return nil
        }*/
        let user = app.currentUser
        if (user == nil) {
            return nil
        }
        do {
            return nil
            /*
            return try await Realm(
                configuration: user!.initialSubscriptionBlock,
                downloadBeforeOpen: .always
            )*/
        } catch {
            return nil
        }
    }
    
    @MainActor
    func provideRealmCloud() async -> RealmSync {
        let app = provideRealmApp()
        return RealmSync(app: app, realm: await provideRealmSync(app: app))
    }
    
    @MainActor
    func provideRealm() async -> Realm {
        var config =  Realm.Configuration(
            inMemoryIdentifier: "CursoIos"
        )
        config.objectTypes = listOfOnlyLocalSchemaRealmClass
        config.schemaVersion = SCHEMA_VERSION
        config.eventConfiguration?.errorHandler = { error in
            
        }
        return try! await Realm(configuration: config)
    }
    
    @MainActor
    func provideArticleRepo(realmSync: RealmSync) -> ArticleRepo {
        return ArticleRepoImp(realmSync: realmSync)
    }
    
    @MainActor
    func provideChatRepo(realmSync: RealmSync) -> ChatRepoImp {
        return ChatRepoImp(realmSync: realmSync)
    }
    
    @MainActor
    func provideCourseRepo(realmSync: RealmSync) -> CourseRepoImp {
        return CourseRepoImp(realmSync: realmSync)
    }
    
    @MainActor
    func provideLecturerRepo(realmSync: RealmSync) -> LecturerRepoImp {
        return LecturerRepoImp(realmSync: realmSync)
    }

    @MainActor
    func provideStudentRepo(realmSync: RealmSync) -> StudentRepoImp {
        return StudentRepoImp(realmSync: realmSync)
    }
    
    @MainActor
    func providePreferenceRepo(realm: Realm) -> PrefRepoImp {
        return PrefRepoImp(realm: realm)
    }
    
    @MainActor
    func provideProjcet() async -> Project {
        let realmCloud = await provideRealmCloud()
        let realm = await provideRealm()
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
}
