import SwiftUI
import _PhotosUI_SwiftUI


struct LogInStudentScreen : View {
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: LogInStudentObservable
    
    @State private var toast: Toast? = nil
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        
        let state = obs.state
        let isEmailError = state.isErrorPressed && state.email.isEmpty
        let isPasswordError = state.isErrorPressed && state.password.isEmpty
        let isNameError = state.isErrorPressed && state.studentName.isEmpty
        let isMobileError = state.isErrorPressed && state.mobile.isEmpty
        let isUniversityError = state.isErrorPressed && state.university.isEmpty
        let isSpecialtyError = state.isErrorPressed && state.specialty.isEmpty
        let isImageError = state.isErrorPressed && state.imageUri == nil
        VStack {
            ScrollView(Axis.Set.vertical, showsIndicators: false) {
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
                        ).foregroundStyle(pref.theme.textColor)
                            .font(.system(size: 35))
                            .padding(leading: 20, trailing: 20)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                        Spacer()
                    }
                    HStack {
                        Text(
                            "Login or sign up to continue."
                        ).foregroundStyle(pref.theme.textColor)
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
                                ImageCacheView(state.imageUri!.absoluteString).frame(
                                    width: 120, height: 120, alignment: .center
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
                                            UIColor(pref.theme.textColor)
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
                                .onChange(selectedItem) { newIt in
                                    logger(
                                        "imageUri",
                                        String(newIt == nil)
                                    )
                                    if (newIt != nil) {
                                        getURL(item: newIt!) { result in
                                            switch result {
                                            case .success(let url):
                                                obs.setImageUri(it: url)
                                                logger("imageUri", url.absoluteString)
                                            case .failure(let failure):
                                                logger(
                                                    "imagUri",
                                                    failure.localizedDescription
                                                )
                                            }
                                        }
                                    }
                                }.frame(
                                    width: 120, height: 120, alignment: .topLeading
                                )
                            }
                        }.background(Color.gray)
                            .clipShape(Circle())
                            .frame(
                                width: 120, height: 120, alignment: .topLeading
                            ).overlay(
                                Circle().stroke(
                                    isImageError ? pref.theme.error : pref.theme.background.opacity(0.0),
                                    lineWidth: isImageError ? 2 : 0
                                )
                            )
                    }
                }.frame(
                    height: 120,
                    alignment: .topLeading
                )
                VStack {
                    VStack {
                        VStack {
                            OutlinedTextField(
                                text: state.email,
                                onChange: { email in
                                    obs.setEmail(it: email)
                                },
                                hint: "Enter email",
                                isError: isEmailError,
                                errorMsg: "Shouldn't be empty",
                                theme: pref.theme,
                                lineLimit: 1,
                                keyboardType: UIKeyboardType.emailAddress
                            )
                            OutlinedSecureField(
                                text: state.password,
                                onChange: { password in
                                    obs.setPassword(it: password)
                                },
                                hint: "Enter password",
                                isError: isPasswordError,
                                errorMsg: "Shouldn't be empty",
                                theme: pref.theme,
                                lineLimit: 1,
                                keyboardType: UIKeyboardType.default
                            ).padding(top: 16)
                        }
                        if !state.isLogIn {
                            VStack {
                                OutlinedTextField(
                                    text: state.studentName,
                                    onChange: { studentName in
                                        obs.setName(it: studentName)
                                    },
                                    hint: "Enter your name",
                                    isError: isNameError,
                                    errorMsg: "Shouldn't be empty",
                                    theme: pref.theme,
                                    lineLimit: 1,
                                    keyboardType: UIKeyboardType.default
                                ).padding(top: 16)
                                OutlinedTextField(
                                    text: state.mobile,
                                    onChange: { it in
                                        obs.setMobile(it: it)
                                    },
                                    hint: "Enter Mobile",
                                    isError: isMobileError,
                                    errorMsg: "Shouldn't be empty",
                                    theme: pref.theme,
                                    lineLimit: 1,
                                    keyboardType: UIKeyboardType.phonePad
                                ).padding(top: 16)
                                OutlinedTextField(
                                    text: state.specialty,
                                    onChange: { it in
                                        obs.setSpecialty(it: it)
                                    },
                                    hint: "Enter Specialty",
                                    isError: isSpecialtyError,
                                    errorMsg: "Shouldn't be empty",
                                    theme: pref.theme,
                                    lineLimit: 1,
                                    keyboardType: UIKeyboardType.default
                                ).padding(top: 16)
                                OutlinedTextField(
                                    text: state.university,
                                    onChange: { it in
                                        obs.setUniversity(it: it)
                                    },
                                    hint: "Enter University",
                                    isError: isUniversityError,
                                    errorMsg: "Shouldn't be empty",
                                    theme: pref.theme,
                                    lineLimit: 1,
                                    keyboardType: UIKeyboardType.default
                                ).padding(top: 16)
                            }
                        }
                    }.padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(pref.theme.backDark)
                        )
                }.padding(20)
            }
            Spacer()
            HStack(alignment: .bottom) {
                Spacer()
                CardAnimationButton(
                    isChoose: state.isLogIn,
                    isProcess: state.isProcessing,
                    text: "Login",
                    color: pref.theme.primary,
                    secondaryColor: pref.theme.secondary,
                    textColor: pref.theme.textForPrimaryColor,
                    onClick: {
                        if (!state.isLogIn) {
                            withAnimation {
                                self.obs.isLogin(it: true)
                            }
                        } else {
                            obs.login { userBase in
                                pref.updateUserBase(
                                    userBase: userBase
                                ) {
                                    pref.writeArguments(
                                        route: HOME_LECTURER_SCREEN_ROUTE,
                                        one: userBase.id,
                                        two: userBase.name
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
                    color: pref.theme.primary,
                    secondaryColor: pref.theme.secondary,
                    textColor: pref.theme.textForPrimaryColor,
                    onClick: {
                        if (state.isLogIn) {
                            withAnimation {
                                self.obs.isLogin(it: false)
                            }
                        } else {
                            obs.signUp { userBase in
                                pref.updateUserBase(
                                    userBase: userBase
                                ) {
                                    pref.writeArguments(
                                        route: HOME_LECTURER_SCREEN_ROUTE,
                                        one: userBase.id,
                                        two: userBase.name
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
        }.background(pref.theme.background.margeWithPrimary).toastView(toast: $toast)
    }
}
