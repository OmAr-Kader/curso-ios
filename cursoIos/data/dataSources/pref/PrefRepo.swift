import Foundation
import Combine

protocol PrefRepo {
    
    func prefs(invoke: ([Preference]) -> Unit)
        
    func insertPref(_ pref: Preference,_ invoke: @escaping ((Preference?) -> Unit))

    func updatePref(
        _ pref: Preference,
        _ newValue: String,
        _ invoke: @escaping (Preference?) -> Unit
    )

    func deletePref(key: String) -> Int
    
    func deletePrefAll() -> Int
    
}
