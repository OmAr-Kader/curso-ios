import Foundation

class PreferenceData {
    
    var repository: PrefRepo
    
    init(repository: PrefRepo) {
        self.repository = repository
    }
    
    func prefs(invoke: ([Preference]) -> Unit) {
        repository.prefs(invoke: invoke)
    }
    
    func insertPref(pref: Preference) async -> Preference? {
        return await repository.insertPref(pref: pref)
    }
    
    func updatePref(pref: Preference, newValue: String) async -> Preference? {
        return await repository.updatePref(pref: pref, newValue: newValue)
    }
    
    func deletePref(key: String) -> Int {
        return repository.deletePref(key: key)
    }
    
    func deletePrefAll() -> Int {
        return repository.deletePrefAll()
    }
}
