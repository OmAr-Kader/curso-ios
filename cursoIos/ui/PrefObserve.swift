import Foundation
import SwiftUI
import RealmSwift
import Combine

class PrefObserve : ObservableObject {
    
    private var sinkPrefs: AnyCancellable? = nil
    private var tempPrefs: AnyCancellable? = nil

    let theme: Theme

    let app: AppModule
    
    init(_ app: AppModule,_ theme: Theme) {
        self.app = app
        self.theme = theme
        self.intiApp(app) {}
    }
    
    @Published var navigationPath = NavigationPath()
    
    @Published var state = State()
    
    private var scope: Scope = Scope()
            
    private var preferences: [Preference] = []
    private var prefsJob: Task<Unit, Error>?
    
    var navigateHome: (Screen) -> Unit {
        return { screen in
            withAnimation {
                self.state = self.state.copy(homeScreen: screen)
            }
            return ()
        }
    }
    
    var navigateTo: (Screen) -> Unit {
        return { screen in
            self.navigationPath.append(screen)
        }
    }
    
    var backPress: () -> Unit {
        return {
            self.navigationPath.removeLast()
        }
    }
    
    func intiApp(_ app: AppModule,_ invoke: @escaping () -> Unit) {
        downloadChanges(invoke)
    }
    
    private func inti(invoke: @escaping ([Preference]) -> Unit) {
        self.app.project.preference.prefs { list in
            self.preferences = list
            invoke(list)
        }
    }

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
    
    func downloadChanges(_ invoke: @escaping () -> Unit) {
        scope.launch {
            if (isNetworkAvailable()) {
                await self.downloadAllServerChanges(invoke)
            }
        }
    }

    
    private func downloadAllServerChanges(_ invoke: () -> Unit) async {
        do {
            try await app.project
                .realmSync.cloud()?.syncSession?.wait(for: .upload)
            invoke()
        } catch {
            invoke()
        }
    }
        
    func signOut(invoke: @escaping () -> Unit, failed: @escaping () -> Unit) {
        let delete = self.app.project.preference.deletePrefAll()
        if delete == REALM_SUCCESS {
            self.app.project.realmSync.realmApp.currentUser?.logOut { _ in
                getFcmLogout(invoke)
            }
        } else {
            failed()
        }
    }
    
    
    func checkIsUserValid(
        userBase: UserBase,
        isStudent: Bool,
        invoke: @escaping () -> Unit,
        failed: @escaping () -> Unit
    ) {
        scope.launchMain {
            let app = self.app.project.realmSync.realmApp
            let it = await self.fetchUser(userBase, app)
            if (it == nil || !it!.isLoggedIn) {
                failed()
                return
            }
            if (!isStudent) {
                await self.app.project.lecturer.getLecturer(userBase.id) { r in
                    if (r.value != nil) {
                        invoke()
                    } else {
                        failed()
                    }
                }
            } else {
                await self.app.project.student.getStudent(userBase.id) { r in
                    if (r.value != nil) {
                        invoke()
                    } else {
                        failed()
                    }
                }
            }
        }
    }
    
    private func fetchUser(_ userBase: UserBase,_ app: RealmSwift.App) async -> User? {
        let curr = app.currentUser
        if (curr != nil) {
            return curr
        } else {
            if (!isNetworkAvailable()) {
                return nil
            }
            do {
                return try await app.login(
                    credentials: Credentials.emailPassword(
                        email: userBase.email,
                        password: userBase.password
                    )
                )
            } catch {
                return nil
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
        self.updatePref(PREF_USER_ID, userBase.id) {
            self.updatePref(PREF_USER_NAME, userBase.name) {
                self.updatePref(PREF_USER_EMAIL, userBase.email) {
                    self.updatePref(PREF_USER_PASSWORD, userBase.password) {
                        invoke()
                    }
                }
            }
        }
    }

    private func updatePref(
        _ key: String,
        _ newValue: String,
        _ invoke: @escaping () -> Unit
    ) {
        let per = preferences.firstIndex(where: { it in
            it.ketString == key
        })
        if (per != nil) {
            app.project.preference.updatePref(
                preferences[per!],
                newValue
            ) { new in
                if (new != nil) {
                    self.preferences[per!] = new!
                }
                invoke()
            }
        } else {
            let new = Preference(
                ketString: key,
                value: newValue
            )
            app.project.preference.insertPref(new) { newPref in
                if (newPref != nil) {
                    self.preferences.append(newPref!)
                }
                invoke()
            }
        }
    }
    
    
    func updatePrefAsync(
        _ key: String,
        _ newValue: String,
        _ invoke: @escaping () -> Unit
    ) {
        let per = preferences.firstIndex(where: { it in
            it.ketString == key
        })
        if (per != nil) {
            app.project.preference.updatePref(
                preferences[per!],
                newValue
            ) { new in
                if (new != nil) {
                    self.preferences[per!] = new!
                }
                self.tempPrefs?.cancel()
                invoke()
            }
        } else {
            let new = Preference(
                ketString: key,
                value: newValue
            )
            app.project.preference.insertPref(new) { newPref in
                if (newPref != nil) {
                    self.preferences.append(newPref!)
                }
                invoke()
            }
        }
    }

    func updatePref(key: String, newValue: String) {
        self.updatePref(key, newValue) {
            
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
        var homeScreen: Screen = .SPLASH_SCREEN_ROUTE
        var argOne = [String : String]()
        var argTwo = [String : String]()
        var argThree = [String : Int]()
        var argJson = [String : Any]()
        var sessionForDisplay: SessionForDisplay? = nil
        
        mutating func copy(homeScreen: Screen) -> Self {
            self.homeScreen = homeScreen
            return self
        }
        
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
