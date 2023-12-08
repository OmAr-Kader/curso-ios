import SwiftUI
import _PhotosUI_SwiftUI

struct CreateArticleScreen : View {
    
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: CreateArticleObservable
    var articleId: String {
        return pref.getArgumentOne(it: CREATE_ARTICLE_SCREEN_ROUTE) ?? ""
    }
    var articleTitle: String {
        return pref.getArgumentTwo(it: CREATE_ARTICLE_SCREEN_ROUTE) ?? ""
    }
    @State private var toast: Toast? = nil
    
    func saveOrEdit(isDraft: Bool, userBase: PrefObserve.UserBase) {
        let state = obs.state
        if (!isDraft && state.imageUri.isEmpty) {
            toast = Toast(style: .error, message: "Should Add Thumbnail Image")
            return
        }
        if (!isDraft && state.articleText.map { it in it.text.isEmpty }.isEmpty) {
            toast = Toast(style: .error, message: "Should Add Article Text")
            return
        }
        if (state.article != nil) {
            obs.edit(isDraft, userBase.id, userBase.name) { it in
                if (it != nil) {
                    pref.backPress()
                } else {
                    toast = Toast(style: .error, message: "Failed")
                }
            }
        } else {
            obs.save(isDraft: isDraft, lecturerId: userBase.id, lecturerName: userBase.name) { it in
                if (it != nil) {
                    pref.backPress()
                } else {
                    toast = Toast(style: .error, message: "Failed")
                }
            }
        }
    }
    
    var body: some View {
        let state = obs.state
        VStack {
            ImageArticleView(state: state) { url in
                obs.setImageUri(it: url.absoluteString)
            } nav: {
                pref.writeArguments(
                    route: IMAGE_SCREEN_ROUTE,
                    one: state.imageUri,
                    two: state.articleTitle
                )
                pref.navigateTo(.IMAGE_SCREEN_ROUTE)
            }
            VStack {
                BasicsViewArticle(obs: obs, articleTitle: articleTitle, theme: pref.theme)
            }.padding(20)
            BottomBarArticle(obs: obs, pref: pref) { isDraft, userBase in
                saveOrEdit(isDraft: isDraft, userBase: userBase)
            }
        }.confirmationDialog("", isPresented: Binding(get: {
            state.isConfirmDialogVisible
        }, set: { it, _ in
            obs.changeUploadDialogGone(it: false)
        })) {
            DialogForUploadArticle(theme: pref.theme) {
                obs.changeUploadDialogGone(it: false)
            } onClick: {
                obs.changeUploadDialogGone(it: false)
                obs.deleteArticle {
                    pref.backPress()
                }
            }
        } message: {
            Text("Date")
        }.toolbarButton(true) {
            obs.changeUploadDialogGone(it: true)
        }.background(pref.theme.background.margeWithPrimary).toastView(toast: $toast)
            .navigationDestination(for: Screen.self) { route in
                targetScreen(pref.state.homeScreen, app, pref)
            }.onAppear {
                if (!articleId.isEmpty) {
                    //obs.getArticle(id: articleId)
                }
            }
    }
}

struct BottomBarArticle : View {
    @StateObject var obs: CreateArticleObservable
    @StateObject var pref: PrefObserve
    let draftOnClick: (Bool, PrefObserve.UserBase) -> Unit

    var body: some View {
        let state = obs.state
        VStack {
            HStack(alignment: .bottom) {
                if (state.article?.isDraft != -1) {
                    Spacer()
                    CardAnimationButton(
                        isChoose: true,
                        isProcess: state.isDraftProcessing,
                        text: "Draft",
                        color: pref.theme.error,
                        secondaryColor: pref.theme.error,
                        textColor: Color.white,
                        onClick: {
                            pref.findUserBase { userBase in
                                guard let userBase else {
                                    return
                                }
                                draftOnClick(true, userBase)
                            }
                        }
                    )
                    Divider().frame(width: 1, height: 30).foregroundStyle(.gray)
                }
                Spacer()
                CardAnimationButton(
                    isChoose: true,
                    isProcess: state.isProcessing,
                    text: "Upload",
                    color: pref.theme.primary,
                    secondaryColor: pref.theme.primary,
                    textColor: pref.theme.textForPrimaryColor,
                    onClick: {
                        pref.findUserBase { userBase in
                            guard let userBase else {
                                return
                            }
                            draftOnClick(false, userBase)
                        }
                    }
                )
                Spacer()
            }
        }
    }
}


struct ImageArticleView : View {
    let state: CreateArticleObservable.State
    let imagePicker: (URL) -> Unit
    let nav: () -> Unit
    
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack {
            GeometryReader { geo in
                if state.imageUri.isEmpty {
                    FullZStack {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images
                        ) {
                            ImageAsset(icon: "upload", tint: .white)
                                .frame(width: 60, height: 60).padding(5)
                        }.onChange(selectedItem, forChangePhoto(imagePicker)).frame(
                            width: 60, height: 60, alignment: .center
                        )
                    }.frame(width: geo.size.width, height: 200).background(
                        UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.64).toC
                    )
                } else {
                    ZStack {
                        ImageView(urlString: state.imageUri)
                            .frame(width: geo.size.width, height: 200)
                        FullZStack {
                            HStack {
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images
                                ) {
                                    ImageAsset(icon: "upload", tint: .white)
                                        .frame(width: 45, height: 45).padding(5)
                                }.onChange(selectedItem, forChangePhoto(imagePicker)).frame(
                                    width: 45, height: 45, alignment: .center
                                )
                                Spacer().frame(width: 20)
                                ImageAsset(icon: "photo", tint: .white)
                                    .frame(width: 45, height: 45).padding(5).onTapGesture {
                                        nav()
                                    }
                            }
                        }.frame(width: geo.size.width, height: 200).background(
                            UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.64).toC
                        )
                    }
                }
            }
        }
    }
}

struct BasicsViewArticle : View {
    @StateObject var obs: CreateArticleObservable
    let articleTitle: String
    let theme: Theme
    @State var scrollTo: Int = 0
    
    var body: some View {
        let state = obs.state
        let isArticleTitleError = state.isErrorPressed && state.articleTitle.isEmpty
        ScrollViewReader { proxy in
            ScrollView(Axis.Set.vertical) {
                LazyVStack {
                    OutlinedTextField(text: state.articleTitle.ifEmpty { articleTitle }, onChange: { it in
                        obs.setArticleTitle(it: it)
                    }, hint: "Enter Article Title", isError: isArticleTitleError, errorMsg: "Shouldn't be empty", theme: theme, lineLimit: 1, keyboardType: .default
                    )
                    ForEach(0..<state.articleText.count, id: \.self) { index in
                        let it = state.articleText[index]
                        let isHeadline = it.font > 20
                        HStack(alignment: .top) {
                            OutlinedTextField(text: it.text, onChange: { text in
                                obs.changeAbout(it: text, index: index)
                            }, hint: isHeadline ? "Enter Article Headline" : "Enter Article", isError: false, errorMsg: "", theme: theme, lineLimit: nil, keyboardType: .default
                            )
                            Button(action: {
                                if (index == state.articleText.count - 1) {
                                    obs.makeFontDialogVisible()
                                    scrollTo = state.articleText.count + 4
                                } else {
                                    obs.removeAboutIndex(index: index)
                                }
                            }, label: {
                                VStack {
                                    VStack {
                                        ImageAsset(
                                            icon: index == (state.articleText.count - 1) ? "plus" : "delete",
                                            tint: theme.textColor
                                        ).frame(width: 50, height: 50).padding(5)
                                    }.background(theme.background.margeWithPrimary(0.3))
                                }.clipShape(Circle())
                            }).frame(width: 50, height: 50)
                            
                        }
                    }
                    if state.isFontDialogVisible {
                        AboutArticleCreator(obs: obs, theme: theme)
                    }
                }
            }.onChange(scrollTo) { value in
                proxy.scrollTo(value)
            }
        }
    }
}

struct DialogForUploadArticle : View {
    
    let theme: Theme
    let onDismiss: () -> Unit
    let onClick: () -> Unit
    
    var body: some View {
        VStack {
            VStack {
                Text(
                    "Are sure you want to delete this article?"
                ).padding(20).foregroundStyle(theme.textColor).font(.system(size: 16))
                Spacer().frame(height: 20)
            }.background(theme.backDark)
        }.padding(20).clipShape(RoundedRectangle(cornerRadius: 20))
        Button("Confirm", role: .destructive) {
            onClick()
        }
        Button("Cancel", role: .cancel) {
            onDismiss()
        }
    }
}

struct AboutArticleCreator : View {
    @StateObject var obs: CreateArticleObservable
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Button(action: {
                    obs.addAbout(type: 0)
                }, label: {
                    Text("Small Font").foregroundStyle(theme.textColor)
                }).padding(5)
                Divider().frame(width: 1, height: 30).foregroundStyle(Color.gray)
                Button(action: {
                    obs.addAbout(type: 1)
                }, label: {
                    Text("Big Font").foregroundStyle(theme.textColor)
                }).padding(5)
            }.padding(5).frame(maxHeight: 300).background(theme.backDarkThr)
        }.clipShape(RoundedRectangle(cornerRadius: 20)).shadow(radius: 2)
    }
}
