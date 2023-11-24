import Foundation

protocol PrefRepo {
    
    func prefs(invoke: ([Preference]) -> Unit)
    
    func insertPref(pref: Preference) async -> Preference?
    
    func updatePref(pref: Preference, newValue: String) async -> Preference?
    
    func deletePref(key: String) -> Int
    
    func deletePrefAll() -> Int
    
}
