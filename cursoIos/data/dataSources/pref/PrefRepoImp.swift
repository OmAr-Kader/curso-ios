import Foundation
import  RealmSwift

class PrefRepoImp : PrefRepo {

    let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func prefs(invoke: ([Preference]) -> Unit) {
        let op: [Preference] = realm.objects(Preference.self).map { it in
            it
        }
        invoke(op)
    }
    
    func insertPref(pref: Preference) async -> Preference? {
        do {
            try await realm.asyncWrite {
                realm.add(pref)
            }
            return pref
        } catch {
            return nil
        }
    }
    
    func updatePref(pref: Preference, newValue: String) async -> Preference? {
        do {
            let op = realm.object(ofType: Preference.self, forPrimaryKey: pref._id)
            if (op == nil) {
                return await insertPref(pref: pref)
            }
            try await realm.asyncWrite {
                op!.value = newValue
            }
            return op
        } catch {
            return nil
        }
    }
    
    func deletePref(key: String) -> Int {
        do {
            let op = realm.objects(Preference.self).filter("ketString == $0", key).first
            if (op == nil) {
                return REALM_FAILED
            }
            try realm.write {
                realm.delete(op!)
            }
            return REALM_SUCCESS
        } catch {
            return REALM_FAILED
        }
    }
    
    func deletePrefAll() -> Int {
        realm.delete(realm.objects(Preference.self))
       return REALM_SUCCESS
    }

}
