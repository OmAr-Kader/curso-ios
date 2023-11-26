import SwiftUI

struct LoginScreen: View {
    
    @EnvironmentObject var app: AppModule
    @StateObject var loginObs: LogInObserve = LogInObserve()

    init() {
        loginObs.intiApp(self.app)
    }
    
    var body: some View {
        
        let state = loginObs.state
        let isEmailError = state.isErrorPressed && state.email.isEmpty
        let isPasswordError = state.isErrorPressed && state.password.isEmpty
        let isNameError = state.isErrorPressed && state.lecturerName.isEmpty
        let isMobileError = state.isErrorPressed && state.mobile.isEmpty
        let isUniversityError = state.isErrorPressed && state.university.isEmpty
        let isSpecialtyError = state.isErrorPressed && state.specialty.isEmpty
        let isBriefError = state.isErrorPressed && state.brief.isEmpty
        let isImageError = state.isErrorPressed && state.imageUri == nil

        VStack {
            Grid {
                
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button(role: nil) {
                self.loginObs.login { Lecturer, Int in
                    
                } failed: { String in
                    
                }

            } label: {
                
            }

        }.onAppear {
            loginObs.intiApp(self.app)
        }
        .padding()
    }
}
