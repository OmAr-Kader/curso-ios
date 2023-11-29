import Foundation
import SwiftUI
class PrefObserve : ObservableObject {
    
    @Published var navigationPath = NavigationPath()
    
    var navigateCon: (Screen) -> Unit {
        return { screen in
            self.navigationPath.append(screen)

        }
    }
    
    var remove: () -> Unit {
        return {
            self.navigationPath.removeLast()
        }
    }
    
    var scope: Scope = Scope()
            
    private var preferences: [Preference] = []
    private var prefsJob: Task<Unit, Error>?

    var app: AppModule?
    
    
    @Published private var state = State()

    func getArgumentOne(it: String) -> String? {
        return self.state.argOne[it]
    }

    func getArgumentTwo(it: String) -> String? {
        return state.argTwo[it]
    }

    func getArgumentThree(it: String) -> Int? {
        return state.argThree[it]
    }

    func getArgumentJson(it: String) -> Any? {
        return state.argJson[it]
    }

    func writeArguments(route: String, one: String, two: String) {
        state = state.copy(route: route, one: one, two: two)
    }

    func writeArguments<T>(
        route: String,
        one: String,
        two: String,
        three: Int? = nil,
        obj: T? = nil
    ) {
        state = state.copy(route: route, one: one, two: two, three: three, obj: obj)
    }
    
    func intiApp(_ app: AppModule) {
        if (self.app != nil) {
            return
        }
        self.app = app
    }
    
    private func inti(invoke: @escaping ([Preference]) -> Unit) {
        prefsJob?.cancel()
        prefsJob = Task(priority: .background) {
            await app?.project().preference.prefs { list in
                preferences = list
                invoke(list)
            }
        }
    }
    
    func downloadChanges(invoke: @escaping () -> Unit) {
        scope.launch {
            if (isNetworkAvailable()) {
                await self.downloadAllServerChanges(invoke)
            }
        }
    }

    
    private func downloadAllServerChanges(_ invoke: () -> Unit) async {
        do {
            try await app?.project()
                .realmSync.cloud()?.syncSession?.wait(for: .upload)
            invoke()
        } catch {
            invoke()
        }
    }
        
    func signOut(invoke: @escaping () -> Unit, failed: @escaping () -> Unit) {
        scope.launch {
            if (self.app == nil) {
                failed()
                return
            }
            let delete = await self.app?.project().preference.deletePrefAll()
            if delete == REALM_SUCCESS {
                do {
                    try await self.app?.project().realmSync.realmApp.currentUser?.logOut()
                    getFcmLogout(invoke)
                } catch let error {
                    logger("DELETE_PREF", error.localizedDescription)
                }
            } else {
                failed()
            }
        }
    }
    
    func findPrefString(
        key: String,
        value: @escaping (String?) -> Unit
    ) {
        if (preferences.isEmpty) {
            inti { it in
                value(it.first { it1 in it1.ketString == key }?.value)
            }
        } else {
            value(preferences.first { it1 in it1.ketString == key }?.value)
        }
    }
    
    func findUserBase(
        value: @escaping (UserBase?) -> Unit
    ) {
        if (preferences.isEmpty) {
            inti { it in
                value(self.fetchUserBase(it))
            }
        } else {
            value(fetchUserBase(preferences))
        }
    }

    private func fetchUserBase(_ list: [Preference]) -> UserBase? {
        let id = list.first { it in it.ketString == PREF_USER_ID }?.value
        let name = list.first { it in it.ketString == PREF_USER_NAME }?.value
        let email = list.first { it in it.ketString == PREF_USER_EMAIL }?.value
        let password = list.first { it in it.ketString == PREF_USER_PASSWORD }?.value
        let courses: String = list.first { it in it.ketString == PREF_USER_COURSES }?.value ?? "0"
        if (id == nil || name == nil || email == nil || password == nil) {
            return nil
        }
        return UserBase(id: id!, name: name!, email: email!, password: password!, courses: Int(courses) ?? 0)
    }


    func updateUserBase(userBase: UserBase, invoke: @escaping () -> Unit) {
        scope.launch {
            await self.updatePref(PREF_USER_ID, userBase.id) {
                await self.updatePref(PREF_USER_NAME, userBase.name) {
                    await self.updatePref(PREF_USER_EMAIL, userBase.email) {
                        await self.updatePref(PREF_USER_PASSWORD, userBase.password) {
                            invoke()
                        }
                    }
                }
            }
        }
    }

    private func updatePref(
        _ key: String,
        _ newValue: String,
        _ invoke: () async -> Unit
    ) async {
        let per = preferences.firstIndex(where: { it in
            it.ketString == key
        })
        if (per != nil) {
            let new = await app?.project().preference.updatePref(
                preferences[per!],
                newValue
            )
            if (new != nil) {
                preferences[per!] = new!
            }
            await invoke()
        } else {
            let new = Preference(
                ketString: key,
                value: newValue
            )
            let newPref = await app?.project().preference.insertPref(new)
            if (newPref != nil) {
                preferences.append(newPref!)
            }
            await invoke()
        }
    }

    func updatePref(key: String, newValue: String) {
        scope.launch {
            await self.updatePref(key, newValue) {
                
            }
        }
    }

    struct UserBase {
        let id: String
        let name: String
        let email: String
        let password: String
        let courses: Int
    }

    struct State {
        var argOne = [String : String]()
        var argTwo = [String : String]()
        var argThree = [String : Int]()
        var argJson = [String : Any]()
        var sessionForDisplay: SessionForDisplay? = nil
        
        mutating func copy(route: String, one: String, two: String) -> Self {
            self.argOne[route] = one
            self.argTwo[route] = two
            return self
        }
        
        mutating func copy(
            route: String,
            one: String,
            two: String,
            three: Int? = nil,
            obj: Any? = nil
        ) -> Self {
            argOne[route] = one
            argTwo[route] = two
            if three != nil {
                argThree[route] = three!
            }
            if obj != nil {
                argJson[route] = obj!
            }
            return self
        }
    }
}
