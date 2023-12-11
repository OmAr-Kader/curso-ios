import SwiftUI
import _PhotosUI_SwiftUI

struct CreateCourseScreen : View {
    
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: CreateCourseObserve
    
    @State private var toast: Toast? = nil
    @State private var currentPage: Int  = 0

    var courseId: String {
        return pref.getArgumentOne(it: CREATE_COURSE_SCREEN_ROUTE) ?? ""
    }
    
    var courseTitle: String {
        return pref.getArgumentTwo(it: CREATE_COURSE_SCREEN_ROUTE) ?? ""
    }
    
    func saveOrEdit(isDraft: Bool, userBase: PrefObserve.UserBase) {
        let state = obs.state
        if (!isDraft && state.timelines.isEmpty) {
            toast = Toast(style: .error, message: "Should Add Timeline")
            return
        }
        if (!isDraft && state.briefVideo.isEmpty) {
            toast = Toast(style: .error, message: "Should Add Brief Video")
            return
        }
        if (!isDraft && state.imageUri.isEmpty) {
            toast = Toast(style: .error, message: "Should Add Thumbnail Image")
            return
        }
        if (!isDraft && state.about.map { it in it.text }.joined().isEmpty) {
            toast = Toast(style: .error, message: "Should Add About Course")
            return
        }
        if (state.course != nil) {
            obs.edit(
                isDraft, userBase.id, userBase.name
            ) { it in
                if (it != nil) {
                    pref.backPress()
                } else {
                    toast = Toast(style: .error, message: "Failed")
                }
            }
        } else {
            obs.save(isDraft, userBase.id, userBase.name) { it in
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
        ZStack {
            VStack {
                BriefVideoView(state: state, videoPicker: { it in
                    obs.setBriefVideo(it: it.absoluteString)
                }) {
                    pref.writeArguments(
                        route: VIDEO_SCREEN_ROUTE,
                        one: state.briefVideo,
                        two: state.courseTitle
                    )
                    pref.navigateTo(.VIDEO_SCREEN_ROUTE)
                }
                MainBarInfoView(state: state, theme: pref.theme, image: { it in
                    obs.setImageUri(it: it.absoluteString)
                }) {
                    pref.writeArguments(
                        route: IMAGE_SCREEN_ROUTE,
                        one: state.imageUri,
                        two: state.courseTitle
                    )
                    pref.navigateTo(.IMAGE_SCREEN_ROUTE)
                }
                PagerTab(currentPage: currentPage, onPageChange: { it in
                    withAnimation {
                        currentPage = it
                    }
                },list: ["Basics", "Timelines"], theme: pref.theme) {
                    BasicsView(obs: obs, courseTitle: courseTitle, theme: pref.theme, scrollTo: currentPage).tag(0)
                    TimelinesView(timelines: state.timelines, isDraft: state.course?.isDraft != -1, theme: pref.theme) { i in
                        obs.deleteTimeLine(i: i)
                    } onClick: { it, i in
                        obs.makeDialogVisible(timeline: it, index: i)
                    }.tag(1)
                }.padding(10)
                BottomBar(obs: obs, pref: pref) { userBase in
                    saveOrEdit(isDraft: true, userBase: userBase)
                }
            }/*.alert("", isPresented: Binding(get: {
                state.dialogMode != 0
            }, set: { it, _ in
                print(String(it))
                obs.makeDialogGone()
            })) {
                DialogWithImage(
                    obs: obs,
                    theme: pref.theme
                ) {
                    pref.writeArguments(
                        route: VIDEO_SCREEN_ROUTE,
                        one: state.timelineData.video,
                        two: state.timelineData.title
                    )
                    pref.navigateTo(.VIDEO_SCREEN_ROUTE)
                }
            } message: {
                Text("Timeline")
            }.alert("", isPresented: Binding(get: {
                state.dateTimePickerMode != 0
            }, set: { it, _ in
                print(String(it))
                obs.closeDateTimePicker()
            })) {
                DialogDateTimePicker(dateTime: state.timelineData.date, mode: state.dateTimePickerMode, theme: pref.theme) {
                    obs.displayDateTimePicker()
                } snake: { it in
                    toast = Toast(style: .error, message: it)
                } close: {
                    obs.closeDateTimePicker()
                } invoke: { timeSelected in
                    obs.confirmTimelineDateTimePicker(timeSelected)
                }
            } message: {
                Text("Date")
            }*/.alert("", isPresented: Binding(get: {
                state.isConfirmDialogVisible
            }, set: { it, _ in
                print(String(it))
                obs.changeUploadDialogGone(it: false)
            })) {
                DialogForUpload(theme: pref.theme) {
                    obs.changeUploadDialogGone(it: false)
                } onClick: {
                    obs.changeUploadDialogGone(it: false)
                    pref.findUserBase { userBase in
                        guard let userBase else {
                            return
                        }
                        saveOrEdit(isDraft: false, userBase: userBase)
                    }
                }
            } message: {
                Text("Confirm")
            }.background(pref.theme.background.margeWithPrimary).toastView(toast: $toast)
            BackButton {
                pref.backPress()
            }.onStart().onTop()
        }.onAppear {
            if (!courseId.isEmpty) {
                obs.getCourse(id: courseId)
            }
            print("WWW " + String(state.course?.timelines.count ?? 0))
        }.navigationDestination(isPresented: Binding(get: {
            state.dialogMode != 0
        }, set: { it, _ in
            obs.makeDialogGone()
        })) {
            CreateCourseTimelineScreen(obs: obs, pref: pref).toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct BriefVideoView : View {
    let state: CreateCourseObserve.State
    let videoPicker: (URL) -> Unit
    let nav: () -> Unit
    
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack {
            if state.briefVideo.isEmpty {
                FullZStack {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .videos
                    ) {
                        ImageAsset(icon: "upload", tint: .white)
                            .frame(width: 45, height: 45).padding(5)
                    }.onChange(selectedItem, forChangePhoto(videoPicker)).frame(
                        width: 45, height: 45, alignment: .center
                    )
                }.frame(height: 200).background(
                    UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.64).toC
                )
            } else {
                ZStack {
                    FullZStack {
                        ImageCacheView(state.briefVideo, isVideoPreview: true)
                            .frame(height: 200)
                    }.frame(height: 200)
                    FullZStack {
                        HStack {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .videos
                            ) {
                                ImageAsset(icon: "upload", tint: .white)
                                    .frame(width: 45, height: 45).padding(5)
                            }.onChange(selectedItem, forChangePhoto(videoPicker)).frame(
                                width: 45, height: 45, alignment: .center
                            )
                            Spacer().frame(width: 20)
                            ImageAsset(icon: "play", tint: .white)
                                .frame(width: 45, height: 45).padding(5).onTapGesture {
                                    nav()
                                }
                        }
                    }.frame(height: 200).background(
                        UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.64).toC
                    )
                }
            }
        }
    }
}

struct MainBarInfoView : View {
    let state: CreateCourseObserve.State
    let theme: Theme
    let image: (URL) -> Unit
    let nav: () -> Unit
    
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        let ifNotEmpty = !state.imageUri.isEmpty
        VStack(alignment: .center) {
            HStack {
                Spacer()
                if ifNotEmpty {
                    CardButton(
                        onClick: nav, text: "Display Image",
                        color: theme.primary, textColor: theme.textForPrimaryColor,
                        width: 120, height: 45, fontSize: 11
                    )
                }
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images
                ) {
                    VStack {
                        Text(
                            ifNotEmpty ? "Re-upload" : "Upload Thumbnail"
                        ).lineLimit(1)
                            .foregroundColor(ifNotEmpty ? .black : theme.textForPrimaryColor)
                            .font(.system(size: 11))
                    }.frame(width: 120, height: 45, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 22.5).fill(
                                ifNotEmpty ? Color.green : theme.primary
                            )
                        )
                }
                .onChange(selectedItem, forChangePhoto(image)).frame(
                    width: 120, height: 45, alignment: .center
                )
                Spacer()
            }
        }.padding(top: 10).frame(height: 60)
    }
}

struct BottomBar : View {
    @StateObject var obs: CreateCourseObserve
    @StateObject var pref: PrefObserve
    let draftOnClick: (PrefObserve.UserBase) -> Unit

    var body: some View {
        let state = obs.state
        VStack {
            HStack(alignment: .bottom) {
                if (state.course?.isDraft != -1) {
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
                                draftOnClick(userBase)
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
                        obs.changeUploadDialogGone(it: true)
                    }
                )
                Spacer()
            }
        }
    }
}

struct BasicsView : View {
    @StateObject var obs: CreateCourseObserve
    let courseTitle: String
    let theme: Theme
    @State var scrollTo: Int
    
    var body: some View {
        let state = obs.state
        let isCourseTitleError = state.isErrorPressed && state.courseTitle.isEmpty
        let isPriceError = state.isErrorPressed && state.price.isEmpty
        VStack {
            ScrollViewReader { proxy in
                ScrollView(Axis.Set.vertical) {
                    LazyVStack {
                        OutlinedTextField(text: state.courseTitle.ifEmpty { courseTitle }, onChange: { it in
                            obs.setCourseTitle(it: it)
                        }, hint: "Enter Course Title", isError: isCourseTitleError, errorMsg: "Shouldn't be empty", theme: theme, lineLimit: 1, keyboardType: .default
                        ).padding(top: 5, leading: 20, bottom: 5, trailing: 20)
                        OutlinedTextField(text: state.price, onChange: { it in
                            obs.setPrice(it: it)
                        }, hint: "Enter Price", isError: isPriceError, errorMsg: "Shouldn't be empty", theme: theme, lineLimit: 1, keyboardType: .numberPad
                        ).padding(top: 5, leading: 20, bottom: 5, trailing: 20)
                        ForEach(0..<state.about.count, id: \.self) { index in
                            let it = state.about[index]
                            let isHeadline = it.font > 20
                            HStack(alignment: .center) {
                                OutlinedTextField(text: it.text, onChange: { text in
                                    obs.changeAbout(it: text, index: index)
                                }, hint: isHeadline ? "Enter About Headline" : "Enter About Details", isError: false, errorMsg: "", theme: theme, lineLimit: nil, keyboardType: .default
                                )
                                Button(action: {
                                    if (index == state.about.count - 1) {
                                        obs.makeFontDialogVisible()
                                        scrollTo = state.about.count + 4
                                    } else {
                                        obs.removeAboutIndex(index: index)
                                    }
                                }, label: {
                                    VStack {
                                        VStack {
                                            ImageAsset(
                                                icon: index == (state.about.count - 1) ? "plus" : "delete",
                                                tint: theme.textColor
                                            )
                                        }.padding(7).background(
                                            theme.background.margeWithPrimary(0.3)
                                        )
                                    }.clipShape(Circle())
                                }).frame(width: 40, height: 40)
                            }.padding(top: 5, leading: 20, bottom: 5, trailing: 20)
                        }
                        if state.isFontDialogVisible {
                            AboutCreator(obs: obs, theme: theme)
                        }
                    }
                }.onChange(scrollTo) { value in
                    proxy.scrollTo(value)
                }
            }
            Spacer()
        }
    }
}

struct TimelinesView : View {
    let timelines: [TimelineData]
    let isDraft: Bool
    let theme: Theme
    let delete: (Int) -> Unit
    let onClick: (TimelineData?, Int) -> Unit

    var body: some View {
        VStack {
            ScrollView(Axis.Set.vertical) {
                LazyVStack {
                    ForEach(0..<timelines.count, id: \.self) { index in
                        let timeline: TimelineData = timelines[index]
                        HStack {
                            VStack {
                                Text(
                                    timeline.title
                                ).foregroundStyle(theme.textColor)
                                    .font(.system(size: 14))
                                    .padding(top: 7, leading: 7, trailing: 7).onStart()
                                Text(
                                    "Date: \(timeline.date.toStr)"
                                ).foregroundStyle(theme.textHintColor)
                                    .font(.system(size: 12))
                                    .padding(top: 5, leading: 14, trailing: 14).onStart()
                                if timeline.mode == 1 {
                                    HStack {
                                        Text(
                                            "Duration: \(timeline.duration)"
                                        ).foregroundStyle(theme.primary)
                                            .font(.system(size: 10))
                                            .padding(leading: 14, bottom: 5)
                                        Spacer()
                                        Text(
                                            "Degree: \(timeline.degree)"
                                        ).foregroundStyle(theme.primary)
                                            .font(.system(size: 10))
                                            .padding(leading: 14, bottom: 5)
                                        Spacer()
                                    }
                                }
                                Divider().background(theme.background.margeWithPrimary(0.3)).padding(leading: 10, trailing: 10)
                            }.onTapGesture {
                                onClick(timeline, index)
                            }
                            if (isDraft) {
                                Button {
                                    delete(index)
                                } label: {
                                    ImageAsset(
                                        icon: "delete",
                                        tint: theme.textColor
                                    ).frame(width: 40, height: 40)
                                }.frame(width: 40, height: 40).padding(5)
                            }
                        }
                    }
                }
            }
            FloatingButton(icon: "plus", theme: theme) {
                onClick(nil, -1)
            }
        }.background(theme.background.margeWithPrimary)
        Spacer()
    }
}

struct DialogWithImage : View {
    @StateObject var obs: CreateCourseObserve
    let theme: Theme
    let nav: () -> Unit
    
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        let state = obs.state
        let isTitleError = state.isDialogPressed && state.timelineData.title.isEmpty
        let isDateTimeError = state.isDialogPressed && state.timelineData.date == -1
        let isDurationError = state.isDialogPressed && state.timelineData.duration == ""
        let isErrorVideo = state.isDialogPressed && state.timelineData.video.isEmpty

        VStack {
            VStack {
                if state.dialogMode == 1 {
                    UpperNavBar(
                        list: ["Session", "Exam"],
                        currentIndex: state.timelineData.isExam ? 1 : 0, theme: theme
                    ) { it in
                        withAnimation {
                            obs.setIsExam(isExam: it == 1)
                        }
                    }
                }
                if (!state.timelineData.isExam) {
                    if (state.timelineData.video.isEmpty) {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .videos
                        ) {
                            Image(
                                uiImage: UIImage(
                                    named: "video.circle"
                                )?.withTintColor(
                                    UIColor(theme.textColor)
                                ) ?? UIImage()
                            ).resizable()
                                .imageScale(.large)
                                .scaledToFit()
                                .clipShape(Circle())
                                .padding(20).frame(
                                    height: 100, alignment: .center
                                )
                        }.frame(height: 100).background(
                            RoundedRectangle(cornerRadius: 5).stroke(
                                isErrorVideo ? theme.error : theme.textColor, lineWidth: 1
                            )
                        ).onChange(selectedItem, forChangePhoto({ url in
                            obs.setVideoTimeLine(it: url.absoluteString)
                        }))
                    } else {
                        ImageCacheView(
                            state.timelineData.video
                        ).frame(height: 100).onTapGesture {
                            nav()
                        }
                    }
                }
                ScrollView(Axis.Set.vertical) {
                    VStack {
                        OutlinedTextField(text: state.timelineData.title, onChange: { it in
                            obs.setTitleTimeline(it: it)
                        }, hint: "Enter Timeline Title", isError: isTitleError, errorMsg: "Shouldn't be empty", theme: theme, lineLimit: 1, keyboardType: .default
                        )
                        OutlinedTextFieldButton(
                            text: state.timelineData.date == -1 ? "Enter date" : state.timelineData.date.toStr, onClick: {
                                obs.displayDateTimePicker()
                            }, isError: isDateTimeError, theme: theme
                        )
                        if state.timelineData.isExam {
                            OutlinedTextFieldButton(
                                text: state.timelineData.duration.isEmpty ? "Enter Exam Duration" : state.timelineData.duration, onClick: {
                                    obs.setDurationDialogVisible(it: true)
                                }, isError: isDurationError, theme: theme
                            ).alert("Change background", isPresented: Binding(get: {
                                state.isDurationDialogVisible
                            }, set: { it, _ in
                                obs.setDurationDialogVisible(it: it)
                            })) {
                                RadioDialog(current: state.timelineData.duration, list: durationList, onDismiss: {
                                    obs.setDurationDialogVisible(it: false)
                                }) { it in
                                    obs.setDurationTimeLine(it: it)
                                }
                                //Button("Cancel", role: .cancel) { }
                            } message: {
                                Text("Select a new color")
                            }
                            OutlinedTextField(text: String(state.timelineData.degree), onChange: { it in
                                let itInt = Int(it)
                                guard let itInt else {
                                    return
                                }
                                obs.setDegreeTimeline(it: itInt)
                            }, hint: "Enter Exam Degree", isError: false, errorMsg: "", theme: theme, lineLimit: 1, keyboardType: .numberPad)
                        }
                        OutlinedTextField(text: state.timelineData.note, onChange: { it in
                            obs.setTimelineNote(it: it)
                        }, hint: "Enter Note", isError: false, errorMsg: "", theme: theme, lineLimit: nil, keyboardType: .default
                        )
                    }
                }
            }.background(theme.backDark)
        }.padding(16).clipShape(RoundedRectangle(cornerRadius: 16))
        Button("Confirm", role: .destructive) {
            obs.addEditTimeline()
        }
        Button("Cancel", role: .cancel) {
            obs.makeDialogGone()
        }
    }
}

struct DialogForUpload : View {
    
    let theme: Theme
    let onDismiss: () -> Unit
    let onClick: () -> Unit

    var body: some View {
        VStack {
            VStack {
                Text(
                    "By confirm upload your course you haven't ability to delete your course or any timeline"
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

struct AboutCreator : View {
    @StateObject var obs: CreateCourseObserve
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
