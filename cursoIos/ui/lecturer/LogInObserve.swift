import Foundation
import RealmSwift
import Realm

class LogInObserve : ObservableObject {
    
    private var scope = Scope()

    var app: AppModule?

    @Published var state = State()

    func intiApp(_ app: AppModule) {
        if (self.app == nil) {
            return
        }
        self.app = app
    }
  
    func login(
        invoke: @escaping (Lecturer, Int) -> Unit,
        failed: @escaping (String) -> Unit
    ) {
        let s = state
        if (s.email.isEmpty || s.password.isEmpty) {
            self.state = self.state.copy(isErrorPressed: true)
            return
        }
        if (!isNetworkAvailable()) {
            failed("Failed: Internet is disconnected")
            return
        }
        self.state = self.state.copy(isProcessing: true)
        doLogIn(s, invoke, failed)
    }

    private func doLogIn(
        _ s: State,
        _ invoke: @escaping (Lecturer, Int) -> Unit,
        _ failed: @escaping (String) -> Unit
    ) {
        scope.launch {
            await self.loginRealm(s).letBackN { user in
                if (user != nil) {
                    await self.app?.project().lecturer.getLecturerEmail(
                        email: s.email
                    ) { r in
                        self.saveUserState(r.value, invoke: invoke, failed: failed)
                    }
                } else {
                    self.state = self.state.copy(isProcessing: false)
                    failed("Failed")
                }
            }
        }
    }
    
    private func saveUserState(
        _ lec: Lecturer?,
        invoke: @escaping (Lecturer, Int) -> Unit,
        failed: @escaping (String) -> Unit
    ) {
        if (lec != nil) {
            scope.launch {
                await self.app?.project().course.getLecturerCourses(
                    id: lec!._id.stringValue
                ) { r in
                    self.state = self.state.copy(isProcessing: false)
                    invoke(lec!, r.value.count)
                }
            }
        } else {
            self.state = self.state.copy(isProcessing: false)
            failed("Failed")
        }
    }

    func signUp(
        invoke: @escaping (Lecturer) -> Unit,
        failed: @escaping (String) -> Unit
    ) {
        let s = state
        if (s.email.isEmpty || s.password.isEmpty || s.brief.isEmpty || s.imageUri == nil || s.university.isEmpty || s.specialty.isEmpty || s.lecturerName.isEmpty || s.mobile.isEmpty) {
            self.state = self.state.copy(isErrorPressed: true)
            return
        }
        if (!isNetworkAvailable()) {
            failed("Failed: Internet is disconnected")
            return
        }
        self.state = self.state.copy(isProcessing: true)
        doSignUp(s, invoke, failed)
    }
    
    private func doSignUp(
        _ s: State,
        _ invoke: @escaping (Lecturer) -> Unit,
        _ failed: @escaping (String) -> Unit
    ) {
        scope.launch {
            await self.realmSignIn(s: s,failed: failed).letBackN { user in
                if (user != nil) {
                    self.state = self.state.copy(alreadyLoggedIn: true)
                    await self.app?.project().fireApp?.upload(
                        s.imageUri!,
                        "LecturerImage/${user.id} ${System.currentTimeMillis()}",
                        //+ getMimeType(uri)
                        { it in
                            self.doInsertLecturer(
                                s: s,
                                it: it,
                                invoke: invoke,
                                failed: failed
                            )
                    }, {
                        self.state = self.state.copy(isProcessing: false)
                        failed("Failed")
                    })
                } else {
                    self.state = self.state.copy(isProcessing: false)
                    failed("Failed")
                }
            }
        }
    }
    

    private func doInsertLecturer(
        s: State,
        it: String,
        invoke: @escaping (Lecturer) -> Unit,
        failed: @escaping (String) -> Unit
    ) {
        scope.launch {
            let it = await self.app?.project().lecturer.insertLecturer(
                lecturer: Lecturer(
                    lecturerName: s.lecturerName,
                    email: s.email,
                    mobile: s.mobile,
                    rate: 5.0,
                    raters: 0,
                    brief: s.brief,
                    imageUri: it,
                    specialty: s.specialty,
                    university: s.university,
                    approved: false
                )
            )
            if (it?.result == REALM_SUCCESS && it?.value != nil) {
                self.state = self.state.copy(isProcessing: false)
                invoke(it!.value!)
            } else {
                failed("Failed")
            }
        }
    }

    private func realmSignIn(
        s: State,
        failed: @escaping (String) -> Unit
    ) async -> User? {
        if (state.alreadyLoggedIn) {
            return await app?.project().realmSync.realmApp.currentUser.letBackN { it in
                if (it != nil) {
                    return nil
                } else {
                    do {
                        try await app?.project().realmSync
                            .realmApp.emailPasswordAuth.registerUser(
                                email: s.email, password: s.password
                            )
                        return await loginRealm(s)
                    } catch {
                        return nil
                    }
                }
            }
        } else {
            do {
                try await app?.project().realmSync
                    .realmApp.emailPasswordAuth.registerUser(
                        email: s.email, password: s.password
                    )
                return await loginRealm(s)
            } catch let error {
                if (error.localizedDescription.contains("existing")) {
                    self.state = self.state.copy(isProcessing: false)
                    failed("Failed: Already Exists")
                    return nil
                } else {
                    return nil
                }
            }
        }
    }


    private func loginRealm(_ s: State) async -> User? {
        let it = try? await app?.project().realmSync.realmApp.login(
            credentials: Credentials.emailPassword(
                email: s.email,
                password: s.password
            )
        )
        return  it?.isLoggedIn == true ? it : nil
    }
    
    func isLogin(it: Bool) {
        self.state = self.state.copy(isErrorPressed: false, isLogIn: it)
    }

    func setEmail(it: String) {
        self.state = self.state.copy(email: it, isErrorPressed: false)
    }

    func setPassword(it: String) {
        self.state = self.state.copy(password: it, isErrorPressed: false)
    }

    func setName(it: String) {
        self.state = self.state.copy(lecturerName: it, isErrorPressed: false)
    }

    func setMobile(it: String) {
        self.state = self.state.copy(mobile: it, isErrorPressed: false)
    }

    func setBrief(it: String) {
        self.state = self.state.copy(brief: it, isErrorPressed: false)
    }

    func setSpecialty(it: String) {
        self.state = self.state.copy(specialty: it, isErrorPressed: false)
    }

    func setUniversity(it: String) {
        self.state = self.state.copy(university: it, isErrorPressed: false)
    }

    func setImageUri(it: URL) {
        scope.launchMain {
            self.state = self.state.copy(imageUri: it, isErrorPressed: false)
            logger("imagUri", "Done")
        }
    }
    
    func setNadasdame() {
        self.state = self.state.copy(isErrorPressed: true)
    }

    
    struct State {
        var email: String = ""
        var password: String = ""
        var lecturerName: String = ""
        var mobile: String = ""
        var specialty: String = ""
        var university: String = ""
        var brief: String = ""
        var imageUri: URL? = nil
        var isErrorPressed: Bool = false
        var isLogIn: Bool = true
        var isProcessing: Bool = false
        var alreadyLoggedIn: Bool = false
        
        mutating func copy(
            email: String? = nil,
            password: String? = nil,
            lecturerName: String? = nil,
            mobile: String? = nil,
            specialty: String? = nil,
            university: String? = nil,
            brief: String? = nil,
            imageUri: URL? = nil,
            isErrorPressed: Bool? = nil,
            isLogIn: Bool? = nil,
            isProcessing: Bool? = nil,
            alreadyLoggedIn: Bool? = nil
        ) -> State {
            self.email = email ?? self.email
            self.password = password ?? self.password
            self.lecturerName = lecturerName ?? self.lecturerName
            self.mobile = mobile ?? self.mobile
            self.specialty = specialty ?? self.specialty
            self.university = university ?? self.university
            self.brief = brief ?? self.brief
            self.imageUri = imageUri ?? self.imageUri
            self.isErrorPressed = isErrorPressed ?? self.isErrorPressed
            self.isLogIn = isLogIn ?? self.isLogIn
            self.isProcessing = isProcessing ?? self.isProcessing
            self.alreadyLoggedIn  = alreadyLoggedIn ?? self.alreadyLoggedIn
            return self
        }
    }

}

