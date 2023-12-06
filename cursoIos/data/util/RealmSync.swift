import Foundation
import RealmSwift

class RealmApi {
    
    var realmApp: App
    var realmCloud: Realm? = nil
    var realmLocal: Realm? = nil

    init(app: App) {
        realmApp = app
    }
    
    @BackgroundActor
    func local() async -> Realm? {
        if (realmLocal != nil) {
            return realmLocal
        } else {
            do {
                var config = Realm.Configuration.defaultConfiguration
                config.objectTypes = listOfOnlyLocalSchemaRealmClass
                config.schemaVersion = SCHEMA_VERSION
                config.deleteRealmIfMigrationNeeded = false
                config.shouldCompactOnLaunch = { _,_ in
                    true
                }
                let realm = try await Realm(
                    configuration: config,
                    actor: BackgroundActor.shared
                )
                realmLocal = realm
                return realm
            } catch {
                return nil
            }
        }
    }

    @BackgroundActor
    func cloud() async -> Realm? {
        if (realmCloud != nil) {
            return realmCloud!
        } else {
            do {
                let user = realmApp.currentUser
                if user != nil {
                    realmCloud = try await Realm(
                        configuration: realmApp.currentUser!.initialSubscriptionBlock,
                        actor: BackgroundActor.shared,
                        downloadBeforeOpen: .always
                    )
                    return realmCloud
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
    }


}

extension User {
    
    var initialSubscriptionBlock: Realm.Configuration {
        var config = self.flexibleSyncConfiguration(initialSubscriptions: { subs in
            subs.append(QuerySubscription<Conversation>())
            subs.append(QuerySubscription<Lecturer>())
            subs.append(QuerySubscription<Course>())
            subs.append(QuerySubscription<Certificate>())
            subs.append(QuerySubscription<Student>())
            subs.append(QuerySubscription<Article>())
       })
        config.objectTypes = listOfSchemaRealmClass + listOfSchemaEmbeddedRealmClass
        config.schemaVersion = SCHEMA_VERSION
        config.eventConfiguration?.errorHandler = { error in
            
        }
        return config
    }
}

@globalActor actor BackgroundActor: GlobalActor {
    static var shared = BackgroundActor()
}
