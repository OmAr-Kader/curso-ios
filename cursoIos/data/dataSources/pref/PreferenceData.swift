import Foundation
import Combine

class PreferenceData {
    
    var repository: PrefRepo
    
    init(repository: PrefRepo) {
        self.repository = repository
    }
    
    func prefs(invoke: ([Preference]) -> Unit) {
        repository.prefs(invoke: invoke)
    }
    
    func insertPref(
        _ pref: Preference,
        _ invoke: @escaping (Preference?) -> Unit
    ) {
        repository.insertPref(pref, invoke)
    }
    
    func updatePref(
        _ pref: Preference,
        _ newValue: String,
        _ invoke: @escaping (Preference?) -> Unit
    ) {
        repository.updatePref(pref, newValue, invoke)
    }
    
    func deletePref(key: String) -> Int {
        return repository.deletePref(key: key)
    }
    
    func deletePrefAll() -> Int {
        return repository.deletePrefAll()
    }
}
