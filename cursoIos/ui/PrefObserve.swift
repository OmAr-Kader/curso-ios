import Foundation
import SwiftUI
import RealmSwift
import Combine

class PrefObserve : ObservableObject {
    
    let theme: Theme

    let app: AppModule
    
    private var scope = Scope()

    @Published var navigationPath = NavigationPath()
    
    @Published var state = State()
            
    private var preferences: [Preference] = []
    private var prefsTask: Task<Void, Error>? = nil
    private var sinkPrefs: AnyCancellable? = nil

    init(_ app: AppModule,_ theme: Theme) {
        self.app = app
        self.theme = theme
        self.downloadChanges()
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        prefsTask = scope.launchRealm {
            self.sinkPrefs = await self.app.project.preference.prefsBack { list in
                print("=====>" + "Done" + String(list.count))
                self.preferences = list
            }
        }
    }
    
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
    
    private func inti(invoke: @escaping ([Preference]) -> Unit) {
        scope.launchRealm {
            await self.app.project.preference.prefs { list in
                self.preferences = list
                invoke(list)
            }
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
    
    func downloadChanges() {
        if (isNetworkAvailable() && self.app.project.realmApi.realmApp.currentUser != nil) {
            self.downloadAllServerChanges()
        }
    }

    private func downloadAllServerChanges() {
        scope.launchRealm {
            do {
                try await self.app.project.realmApi.cloud()?.syncSession?.wait(for: .download)
            } catch let error {
                print("==>" + error.localizedDescription)
            }
        }
    }
        
    func signOut(_ invoke: @escaping () -> Unit,_ failed: @escaping () -> Unit) {
        scope.launchRealm {
            let delete = await self.app.project.preference.deletePrefAll()
            await self.userLogOut(delete, invoke, failed)
        }
    }
    
    private func userLogOut(
        _ delete: Int,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) async {
        self.scope.launchMain {
            self.doSignOut(delete, invoke, failed)
        }
    }
    
    private func doSignOut(
        _ delete: Int,
        _ invoke: @escaping () -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        if delete == REALM_SUCCESS {
            self.app.project.realmApi.realmApp.currentUser?.logOut { _ in
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
        self.fetchUser(userBase) { it in
            if (it == nil || !it!.isLoggedIn) {
                failed()
                return
            }
            self.checkUserData(
                userBase: userBase,
                isStudent: isStudent,
                invoke: invoke,
                failed: failed
            )
        }
    }
    
    private func checkUserData(
        userBase: UserBase,
        isStudent: Bool,
        invoke: @escaping () -> Unit,
        failed: @escaping () -> Unit
    ) {
        scope.launchRealm {
            if (!isStudent) {
                await self.app.project.lecturer.getLecturer(userBase.id) { r in
                    self.scope.launchMain {
                        r.value != nil ? invoke() : failed()
                    }
                }
            } else {
                await self.app.project.student.getStudent(userBase.id) { r in
                    self.scope.launchMain {
                        r.value != nil ? invoke() : failed()
                    }
                }
            }
        }
    }
    
    private func fetchUser(_ userBase: UserBase,_ invoke: @escaping (User?) -> Unit) {
        let curr = self.app.project.realmApi.realmApp.currentUser
        if (curr != nil) {
            invoke(curr!)
        } else {
            if (!isNetworkAvailable()) {
                invoke(nil)
                return
            }
            app.project.realmApi.realmApp.login(
                credentials: Credentials.emailPassword(
                    email: userBase.email,
                    password: userBase.password
                )
            ) { (result) in
                switch result {
                case .failure(let error):
                    print("==>" + error.localizedDescription)
                    invoke(nil)
                case .success(let user):
                    invoke(user)
                }
            }
        }
    }
    
    func findPrefString(
        key: String,
        value: @escaping (String?) -> Unit
    ) {
        if (preferences.isEmpty) {
            inti { it in
                self.scope.launchMain {
                    value(it.first { it1 in it1.ketString == key }?.value)
                }
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
                let userBase = self.fetchUserBase(it)
                self.scope.launchMain {
                    value(userBase)
                }
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
        print("SSSSS==>>" + (id ?? ""))
        print("SSSSS==>>" + (String(self.preferences.count)))
        print("SSSSS==>>" + (String(self.preferences.first?.value ?? "")))
        if (id == nil || name == nil || email == nil || password == nil) {
            /*if app.project.realmApi.realmApp.currentUser != nil {
                let user = UserBase(id: "6541ef0672e1526fcb4fcbe8", name: "OmAr", email: "lecturerthree@gmail.com", password: "123123", courses: 2)
                updateUserBase(userBase: user) {
                    print("SSSSS==>>" + (String(self.preferences.count)))
                }
                return user
            } else {
                return nil
            }*/
            return nil
        }
        return UserBase(id: id!, name: name!, email: email!, password: password!, courses: Int(courses) ?? 0)
    }


    func updateUserBase(userBase: UserBase, invoke: @escaping () -> Unit) {
        scope.launchRealm {
            var list : [Preference] = []
            list.append(Preference(ketString: PREF_USER_ID, value: userBase.id))
            list.append(Preference(ketString: PREF_USER_NAME, value: userBase.name))
            list.append(Preference(ketString: PREF_USER_EMAIL, value: userBase.email))
            list.append(Preference(ketString: PREF_USER_PASSWORD, value: userBase.password))
            await self.app.project.preference.insertPref(list) { newPref in
                //self.preferences = list
                self.scope.launchMain {
                    invoke()
                }
            }
        }
    }

    @BackgroundActor
    private func updatePref(
        _ key: String,
        _ newValue: String,
        _ invoke: @escaping () async -> Unit
    ) async {
        await self.app.project.preference.insertPref(
            Preference(
                ketString: key,
                value: newValue
            )) { _ in
                await invoke()
            }
    }
    
    func updatePref(key: String, newValue: String) {
        scope.launchRealm {
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
    
    deinit {
        prefsTask?.cancel()
        sinkPrefs?.cancel()
        sinkPrefs = nil
        prefsTask = nil
        scope.deInit()
    }
    
}
