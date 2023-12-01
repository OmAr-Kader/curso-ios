import SwiftUI
import PhotosUI

struct LoginScreen: View {
    @State private var toast: Toast? = nil

    @ObservedObject var app: AppModule
    @ObservedObject var pref: PrefObserve
    @ObservedObject var loginObs: LogInObserve
    
    @State private var selectedItem: PhotosPickerItem?
    @FocusState private var isFocusedEmail: Bool
    
    init(_ app: AppModule,_ pref: PrefObserve) {
        self.app = app
        self.pref = pref
        self.loginObs = LogInObserve(app)
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
            VStack {
                HStack {
                    Image(
                        uiImage: UIImage(named: "AppIcon") ?? UIImage()
                    ).resizable()
                        .imageScale(.large)
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(
                            width: 40,
                            height: 40,
                            alignment: .topLeading
                        ).padding(20)
                    Spacer()
                }
                HStack {
                    Text(
                        "Hello There."
                    ).foregroundStyle(app.theme.textColor)
                        .font(.system(size: 35))
                        .padding(leading: 20, trailing: 20)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    Text(
                        "Login or sign up to continue."
                    ).foregroundStyle(app.theme.textColor)
                        .font(.system(size: 14))
                        .padding(leading: 20, trailing: 20)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    Spacer()
                }
            }.frame(
                height: 170,
                alignment: .topLeading
            )
            VStack {
                if (!state.isLogIn) {
                    VStack {
                        if (state.imageUri != nil) {
                            ImageView(
                                urlString: state.imageUri!.absoluteString
                            )
                        } else {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images
                            ) {
                                Image(
                                    uiImage: UIImage(
                                        named: "photo.circle"
                                    )?.withTintColor(
                                        UIColor(app.theme.textColor)
                                    ) ?? UIImage()
                                ).resizable()
                                    .imageScale(.large)
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .padding(20).frame(
                                        width: 120, height: 120, alignment: .topLeading
                                    )
                            }
                            .clipShape(Circle())
                            .onChange(of: selectedItem, {
                                logger(
                                    "imageUri",
                                    String(selectedItem == nil)
                                )
                                if (selectedItem != nil) {
                                    getURL(item: selectedItem!) { result in
                                        switch result {
                                        case .success(let url):
                                            loginObs.setImageUri(it: url)
                                            logger("imageUri", url.absoluteString)
                                        case .failure(let failure):
                                            logger(
                                                "imagUri",
                                                failure.localizedDescription
                                            )
                                        }
                                    }
                                }
                            }).frame(
                                width: 120, height: 120, alignment: .topLeading
                            )
                        }
                    }.background(Color.gray)
                    .clipShape(Circle())
                    .frame(
                        width: 120, height: 120, alignment: .topLeading
                    ).overlay(
                        Circle().stroke(
                            isImageError ? app.theme.error : app.theme.background.opacity(0.0),
                            lineWidth: isImageError ? 2 : 0
                        )
                    )
                }
            }.frame(
                height: 120,
                alignment: .topLeading
            )
            VStack {
                ScrollView {
                    VStack {
                        VStack {
                            OutlinedTextField(
                                text: state.email,
                                onChange: { email in
                                    loginObs.setEmail(it: email)
                                },
                                hint: "Enter email",
                                isError: isEmailError,
                                errorMsg: "Shouldn't be empty",
                                theme: app.theme,
                                lineLimit: 1,
                                keyboardType: UIKeyboardType.emailAddress
                            )
                            OutlinedSecureField(
                                text: state.password,
                                onChange: { password in
                                    loginObs.setPassword(it: password)
                                },
                                hint: "Enter password",
                                isError: isPasswordError,
                                errorMsg: "Shouldn't be empty",
                                theme: app.theme,
                                lineLimit: 1,
                                keyboardType: UIKeyboardType.default
                            ).padding(top: 16)
                        }
                        if !state.isLogIn {
                            VStack {
                                OutlinedTextField(
                                    text: state.lecturerName,
                                    onChange: { lecturerName in
                                        loginObs.setName(it: lecturerName)
                                    },
                                    hint: "Enter your name",
                                    isError: isNameError,
                                    errorMsg: "Shouldn't be empty",
                                    theme: app.theme,
                                    lineLimit: 1,
                                    keyboardType: UIKeyboardType.default
                                ).padding(top: 16)
                                OutlinedTextField(
                                    text: state.mobile,
                                    onChange: { it in
                                        loginObs.setMobile(it: it)
                                    },
                                    hint: "Enter Mobile",
                                    isError: isMobileError,
                                    errorMsg: "Shouldn't be empty",
                                    theme: app.theme,
                                    lineLimit: 1,
                                    keyboardType: UIKeyboardType.phonePad
                                ).padding(top: 16)
                                OutlinedTextField(
                                    text: state.specialty,
                                    onChange: { it in
                                        loginObs.setSpecialty(it: it)
                                    },
                                    hint: "Enter Specialty",
                                    isError: isSpecialtyError,
                                    errorMsg: "Shouldn't be empty",
                                    theme: app.theme,
                                    lineLimit: 1,
                                    keyboardType: UIKeyboardType.default
                                ).padding(top: 16)
                                OutlinedTextField(
                                    text: state.university,
                                    onChange: { it in
                                        loginObs.setUniversity(it: it)
                                    },
                                    hint: "Enter University",
                                    isError: isUniversityError,
                                    errorMsg: "Shouldn't be empty",
                                    theme: app.theme,
                                    lineLimit: 1,
                                    keyboardType: UIKeyboardType.default
                                ).padding(top: 16)
                                OutlinedTextField(
                                    text: state.brief,
                                    onChange: { it in
                                        loginObs.setBrief(it: it)
                                    },
                                    hint: "Enter Info About you",
                                    isError: isBriefError,
                                    errorMsg: "Shouldn't be empty",
                                    theme: app.theme,
                                    lineLimit: nil,
                                    keyboardType: UIKeyboardType.default
                                ).padding(top: 16)
                            }
                        }
                    }.padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(app.theme.backDark)
                        )
                }.onAppear {
                    UIScrollView.appearance().bounces = false
                }.onDisappear {
                    UIScrollView.appearance().bounces = true
                }
            }.padding(20)
            Spacer()
            HStack(alignment: .bottom) {
                Spacer()
                CardAnimationButton(
                    isChoose: state.isLogIn,
                    isProcess: state.isProcessing,
                    text: "Login",
                    color: app.theme.primary,
                    secondaryColor: app.theme.secondary,
                    textColor: app.theme.textForPrimaryColor,
                    onClick: {
                        if (!state.isLogIn) {
                            withAnimation {
                                self.loginObs.isLogin(it: true)
                            }
                        } else {
                            loginObs.login { it, i in
                                pref.updateUserBase(
                                    userBase: PrefObserve.UserBase(
                                        id: it._id.stringValue,
                                        name: it.lecturerName,
                                        email: it.email,
                                        password: state.password,
                                        courses: i
                                    )
                                ) {
                                    pref.writeArguments(
                                        route: HOME_LECTURER_SCREEN_ROUTE,
                                        one: it._id.stringValue,
                                        two: it.lecturerName
                                    )
                                    pref.navigateHome(Screen.HOME_LECTURER_SCREEN_ROUTE)
                                }
                            } failed: { it in
                                toast = Toast(style: .error, message: it)
                            }
                        }
                    }
                )
                Spacer()
                CardAnimationButton(
                    isChoose: !state.isLogIn,
                    isProcess: state.isProcessing,
                    text: "Sign up",
                    color: app.theme.primary,
                    secondaryColor: app.theme.secondary,
                    textColor: app.theme.textForPrimaryColor,
                    onClick: {
                        if (state.isLogIn) {
                            withAnimation {
                                self.loginObs.isLogin(it: false)
                            }
                        } else {
                            loginObs.signUp { value in
                                pref.updateUserBase(
                                    userBase: PrefObserve.UserBase(
                                        id: value._id.stringValue,
                                        name: value.lecturerName,
                                        email: value.email,
                                        password: state.password,
                                        courses: 0
                                    )
                                ) {
                                    pref.writeArguments(
                                        route: HOME_LECTURER_SCREEN_ROUTE,
                                        one: value._id.stringValue,
                                        two: value.lecturerName
                                    )
                                    pref.navigateHome(Screen.HOME_LECTURER_SCREEN_ROUTE)
                                }
                            } failed: { it in
                                toast = Toast(style: .error, message: it)
                            }
                        }
                    }
                )
                Spacer()
            }
        }.background(app.theme.background.darker)
            .toastView(toast: $toast)
    }
}
