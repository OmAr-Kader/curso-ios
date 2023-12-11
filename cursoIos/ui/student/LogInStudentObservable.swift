import Foundation
import RealmSwift

class LogInStudentObservable : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    @MainActor
    func login(
        invoke: @escaping @MainActor (Student, Int) -> Unit,
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
        _ invoke: @escaping @MainActor (Student, Int) -> Unit,
        _ failed: @escaping (String) -> Unit
    ) {
        self.loginRealm(s) { user in
            if user == nil {
                self.scope.launchMain {
                    self.state = self.state.copy(isProcessing: false)
                }
                return
            }
            self.scope.launchRealm {
                await self.app.project.student.getStudentEmail(
                    s.email
                ) { r in
                    self.saveUserState(r.value, invoke: invoke, failed: failed)
                }
            }
        }
    }
    
    private func saveUserState(
        _ student: Student?,
        invoke: @escaping @MainActor (Student, Int) -> Unit,
        failed: @escaping (String) -> Unit
    ) {
        guard let student else {
            scope.launchMain {
                self.state = self.state.copy(isProcessing: false)
                failed("Failed")
            }
            return
        }
        scope.launchRealm {
            await self.app.project.course.getStudentCourses(
                student._id.stringValue
            ) { r in
                self.scope.launchMain {
                    self.state = self.state.copy(isProcessing: false)
                    invoke(student, r.value.count)
                }
            }
        }
    }
    
    @MainActor
    func signUp(
        invoke: @escaping (Student) -> Unit,
        failed: @escaping (String) -> Unit
    ) {
        let s = state
        if (s.email.isEmpty || s.password.isEmpty || s.imageUri == nil || s.university.isEmpty || s.specialty.isEmpty || s.studentName.isEmpty || s.mobile.isEmpty) {
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
        _ invoke: @escaping (Student) -> Unit,
        _ failed: @escaping (String) -> Unit
    ) {
        self.realmSignIn(s: s,failed: failed) { user in
            let img = s.imageUri
            guard let user, let img else {
                self.scope.launchMain {
                    self.state = self.state.copy(isProcessing: false)
                    failed("Failed")
                }
                return
            }
            print(user)
            self.alreadyLogged()
            self.app.project.fireApp?.upload(
                img,
                "StudentImage/\(user.id)_" + String(currentTime) + s.imageUri!.pathExtension,
                { it in
                    self.doInsertNewStudent(
                        s: s,
                        it: it,
                        invoke: invoke,
                        failed: failed
                    )
            }, {
                self.scope.launchMain {
                    self.state = self.state.copy(isProcessing: false)
                    failed("Failed")
                }
            })
        }
    }
    
    private func doInsertNewStudent(
        s: State,
        it: String,
        invoke: @escaping (Student) -> Unit,
        failed: @escaping (String) -> Unit
    ) {
        scope.launchRealm {
            let it = await self.app.project.student.insertStudent(
                Student(
                    studentName: s.studentName,
                    email: s.email,
                    mobile: s.mobile,
                    imageUri: it,
                    specialty: s.specialty,
                    university: s.university
                )
            )
            if (it.result == REALM_SUCCESS && it.value != nil) {
                self.scope.launchMain {
                    self.state = self.state.copy(isProcessing: false)
                    invoke(it.value!)
                }
            } else {
                self.scope.launchMain {
                    self.state = self.state.copy(isProcessing: false)
                    failed("Failed")
                }
            }
        }
    }
    
    private func realmSignIn(
        s: State,
        failed: @escaping (String) -> Unit,
        invoke: @escaping (User?) -> Unit
    ) {
        if (s.alreadyLoggedIn) {
            let it = app.project.realmApi.realmApp.currentUser
            if (it == nil) {
                self.scope.launchMain {
                    self.state = self.state.copy(isProcessing: false)
                    failed("Failed")
                }
            } else {
                signUpRealm(s: s) { result in
                    if result == REALM_SUCCESS {
                        self.loginRealm(s) { user in
                            invoke(user)
                        }
                    } else {
                        invoke(nil)
                    }
                }
            }
        } else {
            app.project.realmApi.realmApp.emailPasswordAuth.registerUser(
                    email: s.email, password: s.password
            ) { (error) in
                if error != nil {
                    if (error!.localizedDescription.contains("existing")) {
                        self.scope.launchMain {
                            self.state = self.state.copy(isProcessing: false)
                            failed("Failed: Already Exists")
                        }
                    } else {
                        invoke(nil)
                    }
                } else {
                    self.loginRealm(s) { user in
                        invoke(user)
                    }
                }
            }
        }
    }
    
    private func alreadyLogged() {
        scope.launchMain {
            self.state = self.state.copy(alreadyLoggedIn: true)
        }
    }
    
    private func loginRealm(_ s: State, invoke: @escaping (User?) -> Unit) {
        app.project.realmApi.realmApp.login(
            credentials: Credentials.emailPassword(
                email: s.email,
                password: s.password
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
    
    private func signUpRealm(s: State, invoke: @escaping (Int) -> Unit) {
        app.project.realmApi.realmApp.emailPasswordAuth.registerUser(
                email: s.email, password: s.password
        ) { (error) in
            invoke(error == nil ? REALM_SUCCESS : REALM_FAILED)
        }
    }
    
    @MainActor
    func isLogin(it: Bool) {
        self.state = self.state.copy(isErrorPressed: false, isLogIn: it)
    }

    @MainActor
    func setEmail(it: String) {
        self.state = self.state.copy(email: it, isErrorPressed: false)
    }

    @MainActor
    func setPassword(it: String) {
        self.state = self.state.copy(password: it, isErrorPressed: false)
    }

    @MainActor
    func setName(it: String) {
        self.state = self.state.copy(studentName: it, isErrorPressed: false)
    }

    @MainActor
    func setMobile(it: String) {
        self.state = self.state.copy(mobile: it, isErrorPressed: false)
    }

    @MainActor
    func setSpecialty(it: String) {
        self.state = self.state.copy(specialty: it, isErrorPressed: false)
    }

    @MainActor
    func setUniversity(it: String) {
        self.state = self.state.copy(university: it, isErrorPressed: false)
    }

    func setImageUri(it: URL) {
        scope.launchMain {
            self.state = self.state.copy(imageUri: it, isErrorPressed: false)
            logger("imagUri", "Done")
        }
    }
    
    struct State {
        var email: String = ""
        var password: String = ""
        var studentName: String = ""
        var mobile: String = ""
        var specialty: String = ""
        var university: String = ""
        var imageUri: URL? = nil
        var isErrorPressed: Bool = false
        var isLogIn: Bool = true
        var isProcessing: Bool = false
        var alreadyLoggedIn: Bool = false
        
        mutating func copy(
            email: String? = nil,
            password: String? = nil,
            studentName: String? = nil,
            mobile: String? = nil,
            specialty: String? = nil,
            university: String? = nil,
            imageUri: URL? = nil,
            isErrorPressed: Bool? = nil,
            isLogIn: Bool? = nil,
            isProcessing: Bool? = nil,
            alreadyLoggedIn: Bool? = nil
        ) -> Self {
            self.email = email ?? self.email
            self.password = password ?? self.password
            self.studentName = studentName ?? self.studentName
            self.mobile = mobile ?? self.mobile
            self.specialty = specialty ?? self.specialty
            self.university = university ?? self.university
            self.imageUri = imageUri ?? self.imageUri
            self.isErrorPressed = isErrorPressed ?? self.isErrorPressed
            self.isLogIn = isLogIn ?? self.isLogIn
            self.isProcessing = isProcessing ?? self.isProcessing
            self.alreadyLoggedIn = alreadyLoggedIn ?? self.alreadyLoggedIn
            return self
        }
    }
    
}
