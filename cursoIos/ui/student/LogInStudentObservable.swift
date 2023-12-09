import Foundation

class LogInStudentObservable : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    struct State {
        var email: String = ""
        var password: String = ""
        var studentName: String = ""
        var mobile: String = ""
        var specialty: String = ""
        var university: String = ""
        var imageUri: String = ""
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
            imageUri: String? = nil,
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
