import Foundation
import  RealmSwift
import Combine

class PrefRepoImp : PrefRepo {
    
    let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func prefs(invoke: ([Preference]) -> Unit) {
        let list: [Preference] = realm.objects(Preference.self).map { it in
            it
        }
        invoke(list)
    }
    
    /*func prefsBack(invoke: @escaping ([Preference]) -> Unit) -> AnyCancellable {
        return realm.objects(Preference.self)
            .collectionPublisher
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.main)
            .assertNoFailure()
            .sink { response in
                invoke(response.map { it in
                    it
                })
            }
    }*/
    
    func insertPref(_ pref: Preference,_ invoke: @escaping ((Preference?) -> Unit)) {
          realm.writeAsync {
              self.realm.add(pref)
          } onComplete: { error in
              invoke(error == nil ? pref : nil)
          }
    }
    
    func updatePref(
        _ pref: Preference,
        _ newValue: String,
        _ invoke: @escaping (Preference?) -> Unit
    ) {
        let op = realm.object(ofType: Preference.self, forPrimaryKey: pref._id)
        if (op == nil) {
            insertPref(pref, invoke)
            return
        }
        self.realm.writeAsync {
            op!.value = newValue
        } onComplete: { error in
            invoke(error == nil ? op : nil)
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
