import SwiftUI
import _PhotosUI_SwiftUI

struct CreateCourseTimelineScreen : View {
    @ObservedObject var obs: CreateCourseObserve
    @ObservedObject var pref: PrefObserve

    @State var current: Int64 = currentTime
    @State private var date = Date.now
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.presentationMode) var presentation

    var body: some View {
        let state = obs.state
        let isTitleError = state.isDialogPressed && state.timelineData.title.isEmpty
        let isDateTimeError = state.isDialogPressed && state.timelineData.date == -1
        let isDurationError = state.isDialogPressed && state.timelineData.duration == ""
        let isErrorVideo = state.isDialogPressed && state.timelineData.video.isEmpty
        let isDegreeError = state.isDialogPressed && state.timelineData.degree == -1
        let degree = state.timelineData.degree < 0 ? "" : String(state.timelineData.degree)
        ZStack {
            VStack {
                Spacer().frame(height: 50)
                if state.dialogMode == 1 {
                    Text("Create a Timeline").font(.system(size: 14))
                        .padding(
                            20
                        ).foregroundStyle(pref.theme.textColor).onCenter()
                        .background(RoundedRectangle(cornerRadius: 7).fill(pref.theme.backDarkThr))
                    HStack {
                        Spacer()
                        OutlinedButton(action: { _ in
                            withAnimation {
                                obs.setIsExam(isExam: false)
                            }
                        }, text: "Session", index: 0, animate: !state.timelineData.isExam, theme: pref.theme)
                        Spacer()
                        OutlinedButton(action: { _ in
                            withAnimation {
                                obs.setIsExam(isExam: true)
                            }
                        }, text: "Exam", index: 0, animate: state.timelineData.isExam, theme: pref.theme)
                        Spacer()
                    }
                } else {
                    Text("Edit Timeline").font(.system(size: 14))
                        .padding(
                            20
                        ).foregroundStyle(pref.theme.textColor).onCenter()
                        .background(RoundedRectangle(cornerRadius: 7).fill(pref.theme.backDarkThr))
                }
                if (!state.timelineData.isExam) {
                    if (state.timelineData.video.isEmpty) {
                        FullZStack {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .videos
                            ) {
                                Image(
                                    uiImage: UIImage(
                                        named: "video.circle"
                                    )?.withTintColor(
                                        UIColor(pref.theme.textColor)
                                    ) ?? UIImage()
                                ).resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(pref.theme.textColor)
                                    .imageScale(.large)
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .padding(20).frame(
                                        height: 100, alignment: .center
                                    )
                            }.frame(height: 200).background(
                                RoundedRectangle(cornerRadius: 5).stroke(
                                    isErrorVideo ? pref.theme.error : pref.theme.textColor, lineWidth: 1
                                )
                            ).onChange(selectedItem, forChangePhoto({ url in
                                obs.setVideoTimeLine(it: url.absoluteString)
                            }))
                        }
                    } else {
                        ZStack {
                            FullZStack {
                                ImageCacheView(
                                    state.timelineData.video,
                                    isVideoPreview: true
                                ).frame(height: 200)/*.onTapGesture {
                                                     nav()
                                                     }*/
                            }
                            
                            FullZStack {
                                ImageAsset(icon: "play", tint: .white)
                                    .frame(width: 45, height: 45).padding(5)
                            }.frame(height: 200).background(
                                UIColor(_colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.64).toC
                            )
                        }
                    }
                }
                ScrollView(Axis.Set.vertical) {
                    VStack {
                        Spacer().frame(height: 10)
                        VStack {
                            DatePicker("Enter Timeline Date", selection: Binding(get: {
                                obs.dateTimeline
                            }, set: { it in
                                print("www")
                                obs.setTimelineNoteDate(Int64(it.timeIntervalSince1970) * 1000)
                            }), displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .frame(maxHeight: 400)
                                .foregroundColor(isDateTimeError ? pref.theme.error : pref.theme.textColor
                                )
                        }.frame(maxHeight: 400).padding(5).background(
                                RoundedRectangle(cornerRadius: 5).stroke(isDateTimeError ? pref.theme.error : Color.clear, lineWidth: 1)
                            )
                        Spacer().frame(height: 10)
                        OutlinedTextField(text: state.timelineData.title, onChange: { it in
                            obs.setTitleTimeline(it: it)
                        }, hint: "Enter Timeline Title", isError: isTitleError, errorMsg: "Shouldn't be empty", theme: pref.theme, lineLimit: 1, keyboardType: .default
                        ).padding(10)
                        if state.timelineData.isExam {
                            /*
                             
                         OutlinedTextFieldButton(
                             text: state.timelineData.duration.isEmpty ? "Enter Exam Duration" : state.timelineData.duration, onClick: {
                                 obs.setDurationDialogVisible(it: true)
                             }, isError: isDurationError, theme: pref.theme
                         )*/
                            TextField(
                                "",
                                text: Binding(get: {
                                    state.timelineData.duration
                                }, set: { it in
                                    //onChange(it)
                                    return ()
                                })
                            ).placeholder(when: state.timelineData.duration.isEmpty, alignment: .leading) {
                                Text("Enter Exam Duration")
                                    .foregroundColor(pref.theme.textHintColor)
                            }.foregroundStyle(pref.theme.textColor)
                                .font(.system(size: 14))
                                .disabled(true)
                                .padding(
                                    EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 15)
                                )
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(1)
                                .preferredColorScheme(pref.theme.isDarkMode ? .dark : .light)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(
                                            isDurationError ? pref.theme.error : pref.theme.primary,
                                            lineWidth: 1.5
                                        )
                                ).onTapGesture {
                                    obs.setDurationDialogVisible(it: true)
                                }.alert("", isPresented: Binding(get: {
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
                                    Text("Select a Exam Duration")
                                }.padding(10)
                            OutlinedTextField(text: degree, onChange: { it in
                                let itInt = Int(it)
                                guard let itInt else {
                                    return
                                }
                                if itInt < 0 {
                                    return
                                }
                                obs.setDegreeTimeline(it: itInt)
                            }, hint: "Enter Exam Degree", isError: isDegreeError, errorMsg: "Shouldn't be empty", theme: pref.theme, lineLimit: 1, keyboardType: .numberPad
                            ).padding(10)
                        }
                        OutlinedTextField(text: state.timelineData.note, onChange: { it in
                            obs.setTimelineNote(it: it)
                        }, hint: "Enter Note", isError: false, errorMsg: "", theme: pref.theme, lineLimit: nil, keyboardType: .default
                        ).padding(10)
                    }
                }
                VStack {
                    HStack(alignment: .bottom) {
                        Spacer()
                        CardAnimationButton(
                            isChoose: true,
                            isProcess: state.isProcessing,
                            text: "Confirm",
                            color: pref.theme.primary,
                            secondaryColor: pref.theme.primary,
                            textColor: pref.theme.textForPrimaryColor,
                            onClick: {
                                obs.addEditTimeline()
                                //obs.makeDialogGone()
                                //self.presentation.wrappedValue.dismiss()
                                //pref.backPress()
                            }
                        )
                        Spacer()
                    }
                }
            }.padding(16)
            BackButton {
                //obs.closeDateTimePicker()
                obs.makeDialogGone()
                //self.presentation.wrappedValue.dismiss()
                //pref.backPress()
            }.onStart().onTop()
        }.background(pref.theme.backDarkSec)
        /*Button("Confirm", role: .destructive) {
         obs.addEditTimeline()
         }
         Button("Cancel", role: .cancel) {
         obs.makeDialogGone()
         }*/
    }
}
