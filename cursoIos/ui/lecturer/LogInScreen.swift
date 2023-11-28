import SwiftUI
import PhotosUI

struct LoginScreen: View {
    
    @EnvironmentObject var app: AppModule
    @ObservedObject var loginObs: LogInObserve = LogInObserve()
    @State private var selectedItem: PhotosPickerItem?
    @FocusState private var isFocusedEmail: Bool
    
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
                        .padding(
                            EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                        ).fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    Spacer()
                }
                HStack {
                    Text(
                        "Login or sign up to continue."
                    ).foregroundStyle(app.theme.textColor)
                        .font(.system(size: 14))
                        .padding(
                            EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                        ).fixedSize(horizontal: false, vertical: true)
                        .lineLimit(1)
                    Spacer()
                }
            }.frame(
                height: 170,
                alignment: .topLeading
            )
            VStack {
                if (state.isLogIn) {
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
            ScrollView {
                VStack {
                    OutlinedTextField(
                        text: state.email,
                        onChange: { email in
                            loginObs.setEmail(it: email)
                        },
                        hint: "Enter your email",
                        isError: isEmailError,
                        errorMsg: "Shouldn't be empty",
                        theme: app.theme,
                        lineLimit: 1
                    )
                }.padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(app.theme.backDark)
                    )
            }.padding(20)
            Spacer()
        }.onAppear {
            loginObs.intiApp(self.app)
        }.background(app.theme.background.darker)
    }
}
/*
 Box(
     modifier = Modifier
         .padding(20.dp)
         .fillMaxWidth()
         .fillMaxHeight()
         .weight(1F),
 ) {
     Card(
         modifier = Modifier
             .fillMaxWidth()
             .wrapContentHeight(),
         shape = MaterialTheme.shapes.medium,
         colors = CardDefaults.cardColors(
             containerColor = isSystemInDarkTheme().backDark,
         ),
     ) {
         Column(
             modifier = Modifier
                 .wrapContentHeight()
                 .verticalScroll(verticalScroll)
                 .padding(16.dp)
         ) {
             OutlinedTextField(
                 modifier = Modifier.fillMaxWidth(),
                 value = state.email,
                 onValueChange = {
                     viewModel.setEmail(it)
                 },
                 placeholder = { Text(text = "Enter Email") },
                 label = { Text(text = "Email") },
                 supportingText = {
                     if (isEmailError) {
                         Text(text = "Shouldn't be empty", color = isSystemInDarkTheme().error, fontSize = 10.sp)
                     }
                 },
                 isError = isEmailError,
                 maxLines = 1,
                 colors = isSystemInDarkTheme().outlinedTextFieldStyle(),
                 keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
             )
             OutlinedTextField(
                 value = state.password,
                 onValueChange = {
                     viewModel.setPassword(it)
                 },
                 modifier = Modifier
                     .padding(top = 16.dp)
                     .fillMaxWidth(),
                 placeholder = { Text(text = "Enter Password") },
                 label = { Text(text = "Password") },
                 supportingText = {
                     if (isPasswordError) {
                         Text(text = "Shouldn't be empty", color = isSystemInDarkTheme().error, fontSize = 10.sp)
                     }
                 },
                 isError = isPasswordError,
                 maxLines = 1,
                 colors = isSystemInDarkTheme().outlinedTextFieldStyle(),
                 keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
             )
             AnimatedVisibility(
                 visible = !state.isLogIn,
                 enter = slideInVertically(),
                 exit = slideOutVertically()
             ) {
                 Column(
                     modifier = Modifier.background(color = isSystemInDarkTheme().backDark)
                 ) {
                     OutlinedTextField(
                         value = state.lecturerName,
                         onValueChange = {
                             viewModel.setName(it)
                         },
                         modifier = Modifier
                             .padding(top = 16.dp)
                             .fillMaxWidth(),
                         placeholder = { Text(text = "Enter Name") },
                         label = { Text(text = "Name") },
                         supportingText = {
                             if (isNameError) {
                                 Text(text = "Shouldn't be empty", color = isSystemInDarkTheme().error, fontSize = 10.sp)
                             }
                         },
                         isError = isNameError,
                         maxLines = 1,
                         colors = isSystemInDarkTheme().outlinedTextFieldStyle(),
                         keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
                     )
                     OutlinedTextField(
                         value = state.mobile,
                         onValueChange = {
                             viewModel.setMobile(it)
                         },
                         modifier = Modifier
                             .padding(top = 16.dp)
                             .fillMaxWidth(),
                         placeholder = { Text(text = "Enter Mobile") },
                         label = { Text(text = "Mobile") },
                         supportingText = {
                             if (isMobileError) {
                                 Text(text = "Shouldn't be empty", color = isSystemInDarkTheme().error, fontSize = 10.sp)
                             }
                         },
                         isError = isMobileError,
                         maxLines = 1,
                         colors = isSystemInDarkTheme().outlinedTextFieldStyle(),
                         keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                     )
                     OutlinedTextField(
                         value = state.specialty,
                         onValueChange = {
                             viewModel.setSpecialty(it)
                         },
                         modifier = Modifier
                             .padding(top = 16.dp)
                             .fillMaxWidth(),
                         placeholder = { Text(text = "Enter Specialty") },
                         label = { Text(text = "Specialty") },
                         supportingText = {
                             if (isSpecialtyError) {
                                 Text(text = "Shouldn't be empty", color = isSystemInDarkTheme().error, fontSize = 10.sp)
                             }
                         },
                         isError = isSpecialtyError,
                         maxLines = 1,
                         colors = isSystemInDarkTheme().outlinedTextFieldStyle(),
                         keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
                     )
                     OutlinedTextField(
                         value = state.university,
                         onValueChange = {
                             viewModel.setUniversity(it)
                         },
                         modifier = Modifier
                             .padding(top = 16.dp)
                             .fillMaxWidth(),
                         placeholder = { Text(text = "Enter University") },
                         label = { Text(text = "University") },
                         supportingText = {
                             if (isUniversityError) {
                                 Text(text = "Shouldn't be empty", color = isSystemInDarkTheme().error, fontSize = 10.sp)
                             }
                         },
                         isError = isUniversityError,
                         maxLines = 1,
                         colors = isSystemInDarkTheme().outlinedTextFieldStyle(),
                         keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
                     )
                     OutlinedTextField(
                         value = state.brief,
                         onValueChange = {
                             viewModel.setBrief(it)
                         },
                         modifier = Modifier
                             .padding(top = 16.dp)
                             .fillMaxWidth(),
                         placeholder = { Text(text = "Enter Info About you") },
                         label = { Text(text = "About") },
                         supportingText = {
                             if (isBriefError) {
                                 Text(text = "Shouldn't be empty", color = isSystemInDarkTheme().error, fontSize = 10.sp)
                             }
                         },
                         isError = isBriefError,
                         colors = isSystemInDarkTheme().outlinedTextFieldStyle(),
                         keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
                     )
                 }
             }
         }
     }
 }
 */
