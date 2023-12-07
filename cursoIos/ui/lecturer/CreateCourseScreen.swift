import SwiftUI
import _PhotosUI_SwiftUI

struct CreateCourseScreen : View {
    
    @StateObject var app: AppModule
    @StateObject var pref: PrefObserve
    @StateObject var obs: CreateCourseObserve
    
    var body: some View {
        VStack {
            
        }
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
        ScrollViewReader { proxy in
            ScrollView(Axis.Set.vertical) {
                LazyVStack {
                    OutlinedTextField(text: state.courseTitle.ifEmpty { courseTitle }, onChange: { it in
                        obs.setCourseTitle(it: it)
                    }, hint: "Enter Course Title", isError: isCourseTitleError, errorMsg: "Shouldn't be empty", theme: theme, lineLimit: 1, keyboardType: .default
                    )
                    OutlinedTextField(text: state.price, onChange: { it in
                        obs.setPrice(it: it)
                    }, hint: "Enter Price", isError: isPriceError, errorMsg: "Shouldn't be empty", theme: theme, lineLimit: 1, keyboardType: .numberPad
                    )
                    ForEach(0..<state.about.count, id: \.self) { index in
                        let it = state.about[index]
                        let isHeadline = it.font > 20
                        HStack(alignment: .top) {
                            OutlinedTextField(text: it.text, onChange: { text in
                                obs.changeAbout(it: text, index: index)
                            }, hint: "Enter About Details", isError: false, errorMsg: "", theme: theme, lineLimit: nil, keyboardType: .default
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
                                        ).frame(width: 50, height: 50).padding(5)
                                    }.background(theme.background.margeWithPrimary(0.3))
                                }.clipShape(Circle())
                            }).frame(width: 50, height: 50)
                            
                        }
                    }
                    if state.isFontDialogVisible {
                        AboutCreator(obs: obs, theme: theme)
                    }
                }
            }.onChange(scrollTo) { value in
                proxy.scrollTo(value)
            }
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
                                    .padding(top: 7, leading: 7, trailing: 7)
                                Text(
                                    "Date: \(timeline.date.toStr)"
                                ).foregroundStyle(theme.textHintColor)
                                    .font(.system(size: 12))
                                    .padding(top: 5, leading: 14, trailing: 14)
                                if timeline.mode == 1 {
                                    HStack {
                                        Text(
                                            "Duration: \(timeline.duration)"
                                        ).foregroundStyle(theme.primary)
                                            .font(.system(size: 10))
                                            .padding(leading: 14, bottom: 5)
                                        Text(
                                            "Degree: \(timeline.degree)"
                                        ).foregroundStyle(theme.primary)
                                            .font(.system(size: 10))
                                            .padding(leading: 14, bottom: 5)
                                    }
                                }
                                Spacer()
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
                                }
                            }
                        }
                    }
                }
            }
            FloatingButton(icon: "plus", theme: theme) {
                onClick(nil, -1)
            }
        }.background(theme.background.margeWithPrimary)
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
                            matching: .images
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
                                    width: 120, height: 120, alignment: .topLeading
                                )
                        }.frame(height: 100).background(
                            RoundedRectangle(cornerRadius: 5).stroke(
                                isErrorVideo ? theme.error : theme.textColor, lineWidth: 1
                            )
                        )
                    } else {
                        ImageView(
                            urlString: state.timelineData.video
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
                            ).confirmationDialog("Change background", isPresented: Binding(get: {
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
    let onClick: () -> Unit
    
    var body: some View {
        VStack {
            VStack {
                Text(
                    "By confirm upload your course you haven't ability to delete your course or any timeline"
                ).padding(20).foregroundStyle(theme.textColor).font(.system(size: 16))
                Spacer().frame(height: 20)
                Button(action: onClick, label: {
                    Text("Dismiss").foregroundStyle(theme.textColor)
                }).padding(5)
            }.background(theme.backDark)
        }.padding(20).clipShape(RoundedRectangle(cornerRadius: 20))
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
