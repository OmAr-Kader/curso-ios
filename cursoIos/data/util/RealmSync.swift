import Foundation
import RealmSwift

class RealmSync {
    
    var realmApp: App
    var realmCloud: Realm? = nil
    
    init(app: App, realm: Realm?) {
        realmApp = app
        realmCloud = realm
    }
    
    func cloud() async -> Realm? {
        if (realmCloud != nil) {
            return realmCloud
        } else {
            let user = realmApp.currentUser
            if (user == nil) {
                return nil
            } else {
                do {
                    self.realmCloud = try await Realm(
                        configuration: user!.initialSubscriptionBlock,
                        downloadBeforeOpen: .always
                    )
                    return realmCloud
                } catch {
                    return nil
                }
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
