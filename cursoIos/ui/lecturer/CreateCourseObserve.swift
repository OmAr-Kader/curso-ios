import Foundation
import RealmSwift

class CreateCourseObserve : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @MainActor
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    func getCourse(id: String) {
        scope.launchRealm {
            await self.app.project.course.getCoursesById(id) { r in
                if r.value == nil {
                    return
                }
                if (r.result == REALM_SUCCESS) {
                    var aboutList = r.value!.about.toAboutCourseData()
                    if aboutList.isEmpty {
                        aboutList.append(AboutCourseData(font: 22, text: ""))
                    }
                    let about = aboutList
                    let courseForData = CourseForData(update: r.value!, currentTime: currentTime)
                    let timelines = r.value!.timelines.toTimelineData()
                    let title = r.value!.title
                    let price = r.value!.price
                    let video = r.value!.briefVideo
                    let imageUri = r.value!.imageUri
                    self.scope.launchMain { [about] in
                        self.state = self.state.copy(
                            course: courseForData,
                            about: about,
                            timelines: timelines,
                            courseTitle: title,
                            price: price,
                            briefVideo: video,
                            imageUri: imageUri
                        )
                    }
                }
            }
        }
    }
    
    @MainActor
    func deleteCourse(invoke: @escaping () -> Unit) {
        if self.state.course == nil {
            return
        }
        scope.launchRealm {
            let it = await self.app.project.course.deleteCourse(
                Course(update: self.state.course!)
            )
            if (it == REALM_SUCCESS) {
                self.scope.launchMain {
                    invoke()
                }
            }
        }
    }
    
    @MainActor
    func save(
        _ isDraft: Bool,
        _ lecturerId: String,
        _ lecturerName: String,
        _ invoke: @escaping (Course?) -> Unit
    ) {
        let s = state
        if (
            (isDraft && (s.courseTitle.isEmpty || s.price.isEmpty)) ||
            (!isDraft && (
                    s.courseTitle.isEmpty ||
                            s.about.map { it in it.text }.isEmpty ||
                            s.briefVideo.isEmpty ||
                            s.imageUri.isEmpty ||
                            s.timelines.isEmpty)
                    )
        ) {
            state = state.copy(isErrorPressed: true)
            return
        }
        state = state.copy(isProcessing: !isDraft, isDraftProcessing: isDraft)
        doSave(isDraft, lecturerId, lecturerName, s, invoke)
    }
    
    private func courseForSave(
        _ isDraft: Bool,
        _ lecturerId: String,
        _ lecturerName: String,
        _ s: State,
        _ invoke: @escaping (Course) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        self.uploadImage(s, lecturerId, { imageUri in
            self.uploadBriefVideo(s, lecturerId, { briefVideo in
                self.uploadTimelineVideoSave(s, lecturerId, { timelines in
                    let it = Course(
                        title: s.courseTitle,
                        lecturerName: lecturerName,
                        lecturerId: lecturerId,
                        price: s.price,
                        imageUri: imageUri,
                        about: s.about.toAboutCourse(),
                        briefVideo: briefVideo,
                        timelines: timelines.toTimeline(),
                        lastEdit: currentTime,
                        isDraft: isDraft ? 1 : -1
                    )
                    invoke(it)
                }, failed)
            }, failed)
        }, failed)
    }
    
    private func doSave(
        _ isDraft: Bool,
        _ lecturerId: String,
        _ lecturerName: String,
        _ s: State,
        _ invoke: @escaping (Course?) -> Unit
    ) {
        self.courseForSave(isDraft, lecturerId, lecturerName, s, { course in
            self.scope.launchRealm {
                let it = await self.app.project.course.insertCourse(
                    course
                )
                if (it.value != nil) {
                    let courseId = it.value!._id.stringValue
                    subscribeToTopic(courseId) {
                        self.pushNotification(
                            topicId: it.value!.lecturerId,
                            msgTitle: "New Course",
                            message: "${course.lecturerName} start new Course",
                            argOne: it.value!._id.stringValue,
                            argTwo: it.value!.title
                        )
                    }
                }
                self.scope.launchMain {
                    self.state = self.state.copy(isProcessing: false, isDraftProcessing: false)
                    invoke(it.value)
                }
            }
        }, {
            invoke(nil)
        })
    }
    
    @MainActor
    func edit(
        _ isDraft: Bool,
        _ lecturerId: String,
        _ lecturerName: String,
        _ invoke: @escaping (Course?) -> Unit
    ) {
        let s = state
        if (
            (isDraft && (s.courseTitle.isEmpty || s.price.isEmpty)) ||
            (!isDraft && (
                s.courseTitle.isEmpty ||
                s.about.map { it in it.text }.isEmpty ||
                s.briefVideo.isEmpty ||
                s.imageUri.isEmpty ||
                s.timelines.isEmpty)
            )
        ) {
            state = state.copy(isErrorPressed: true)
            return
        }
        state = state.copy(isProcessing: !isDraft, isDraftProcessing: isDraft)
        doEdit(isDraft: isDraft, lecturerId: lecturerId, lecturerName: lecturerName, s: s, invoke: invoke)
    }
    
    private func courseForEdit(
        _ isDraft: Bool,
        _ lecturerId: String,
        _ lecturerName: String,
        _ s: State,
        _ invoke: @escaping (Course) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        if s.course == nil {
           failed()
           return
        }
        let c = s.course
        self.uploadImage(s, lecturerId, { imageUri in
            self.uploadBriefVideo(s, lecturerId, { briefVideo in
                self.uploadTimelineVideoEdit(s, lecturerId, c!, { timelines in
                    let it = Course(
                        title: s.courseTitle,
                        lecturerName: lecturerName,
                        lecturerId: lecturerId,
                        price: s.price,
                        imageUri: imageUri,
                        about: s.about.toAboutCourse(),
                        briefVideo: briefVideo,
                        timelines: timelines.toTimeline(),
                        lastEdit: currentTime,
                        isDraft: isDraft ? 1 : -1,
                        id: c!.id
                    )
                    invoke(it)
                }, failed)
            }, failed)
        }, failed)
    }

    
    private func doEdit(
        isDraft: Bool,
        lecturerId: String,
        lecturerName: String,
        s: State,
        invoke: @escaping (Course?) -> Unit
    ) {
        self.courseForEdit(isDraft, lecturerId, lecturerName, s, { course in
            self.doEditCourse(s, course, invoke)
        }, {
            invoke(nil)
        })
    }
    
    private func doEditCourse(
        _ s: State,
        _ course: Course,
        _ invoke: @escaping (Course?) -> Unit
    ) {
        if s.course == nil {
            return
        }
        scope.launchRealm {
            let it = await self.app.project.course.editCourse(
                Course(update: s.course!),
                course
            )
            if (it.value != nil) {
                self.pushNotification(
                    topicId: it.value!.lecturerId,
                    msgTitle: "Check what's new in the article",
                    message: "${it.value.lecturerName} edit ${it.value.title}",
                    argOne: it.value!._id.stringValue,
                    argTwo: it.value!.title
                )
            }
            self.scope.launchMain {
                self.state = self.state.copy(isProcessing: false, isDraftProcessing: false)
                invoke(it.value)
            }
        }
    }
    
    @MainActor
    func setCourseTitle(it: String) {
        state = state.copy(courseTitle: it, isErrorPressed: false)
    }

    @MainActor
    func setPrice(it: String) {
        state = state.copy(price: it, isErrorPressed: false)
    }

    @MainActor
    func makeFontDialogVisible() {
        state = state.copy(isFontDialogVisible: true)
    }

    @MainActor
    func addAbout(type: Int) {
        var list = (state.about)
        list.append(AboutCourseData(font: type == 0 ? 14 : 22, text: ""))
        state = state.copy(about: list, isErrorPressed: false, isFontDialogVisible: false)
    }

    @MainActor
    func removeAboutIndex(index: Int) {
        var list = (state.about)
        list.remove(at: index)
        state = state.copy(about: list, dummy: state.dummy + 1)
    }
    
    @MainActor
    func changeAbout(it: String, index: Int) {
        var list = (state.about)
        list[index] = list[index].copy(text: it)
        state = state.copy(about: list, dummy: state.dummy + 1)
    }

    @MainActor
    func setBriefVideo(it: String) {
        state = state.copy(briefVideo: it, isErrorPressed: false)
    }

    @MainActor
    func setImageUri(it: String) {
        state = state.copy(imageUri: it, isErrorPressed: false)
    }

    @MainActor
    func setTitleTimeline(it: String) {
        state = state.copy(
            timelineData: state.timelineData.copy(title: it),
            isDialogPressed: false
        )
    }

    @MainActor
    func setDegreeTimeline(it: Int) {
        state = state.copy(
            timelineData: state.timelineData.copy(degree: it),
            isDialogPressed: false
        )
    }
    
    @MainActor
    func setDurationTimeLine(it: String) {
        state = state.copy(
            timelineData: state.timelineData.copy(duration: it),
            isDialogPressed: false,
            isDurationDialogVisible: false
        )
    }

    @MainActor
    func setVideoTimeLine(it: String) {
        scope.launchMain {
            self.state = self.state.copy(
                timelineData: self.state.timelineData.copy(video: it),
                isDialogPressed: false
            )
        }
    }

    @MainActor
    func setDurationDialogVisible(it: Bool) {
        state = state.copy(isDialogPressed: false, isDurationDialogVisible: it)
    }
    
    @MainActor
    var dateTimeline: Date {
        let it = state.timelineData.date
        return it != -1 ? Date(timeIntervalSince1970: Double(it) / 1000) : Date.now
    }
    
    @MainActor
    func setTimelineNoteDate(_ selectedDateMillis: Int64) {
        state = state.copy(
            timelineData: state.timelineData.copy(date: selectedDateMillis),
            isDialogPressed: false
        )
    }

    @MainActor
    func setTimelineNote(it: String) {
        state = state.copy(
            timelineData: state.timelineData.copy(note: it),
            isErrorPressed: false
        )
    }

    @MainActor
    func setIsExam(isExam: Bool) {
        state = state.copy(
            timelineData: TimelineData("", -1, "", "", "", isExam ? 1 : 0, -1),
            timelineIndex: -1,
            isDialogPressed: false
        )
    }

    @MainActor
    func changeUploadDialogGone(it: Bool) {
        state = state.copy(isConfirmDialogVisible: it)
    }

    @MainActor
    func makeDialogGone() {
        state = state.copy(
            timelineData: TimelineData("", -1, "", "", "", 0, -1), timelineIndex: -1, isErrorPressed: false, dialogMode: 0,
            isDialogPressed: false
        )
    }

    @MainActor
    func makeDialogVisible(timeline: TimelineData?, index: Int = -1) {
        if timeline != nil {
            state = state.copy(
                timelineData: timeline, timelineIndex: index, isErrorPressed: false, dialogMode: 2,
                isDialogPressed: false
            )
        } else {
            state = state.copy(
                isErrorPressed: false, dialogMode: 1,
                isDialogPressed: false
            )
        }
    }

    @MainActor
    func addEditTimeline() {
        let s = state
        if (s.timelineData.date == -1 || s.timelineData.title.isEmpty ||
            (s.timelineData.isExam && (s.timelineData.duration.isEmpty)) ||
            (!s.timelineData.isExam && (s.timelineData.video.isEmpty))
        ) {
            state = state.copy(isDialogPressed: true)
            return
        }
        if (s.dialogMode == 1) {
            addTimeline(s: s)
        } else {
            editTimeline(s: s)
        }
    }
    
    @MainActor
    func deleteTimeLine(i: Int) {
        var timelines = [TimelineData](state.timelines)
        timelines.remove(at: i)
        self.state = self.state.copy(timelines: timelines)
    }

    private func addTimeline(s: State) {
        scope.launchMed {

            var timelines = [TimelineData](s.timelines)
            timelines.append(
                s.timelineData
            )
            timelines.sort { c1, c2 in
                return c1.date < c2.date
            }
            self.scope.launchMain { [timelines] in
                self.state = self.state.copy(
                    timelines: timelines,
                    timelineData: TimelineData("", -1, "", "", "", 0, -1),
                    timelineIndex: -1,
                    isErrorPressed: false,
                    dialogMode: 0,
                    isDialogPressed: false
                )
            }
        }
    }
    
    @MainActor
    func displayDateTimePicker() {
        state = state.copy(dialogMode: 1, isDialogPressed: false)
    }
    
    private func editTimeline(s: State) {
        scope.launchMed {
            var timelines = [TimelineData](s.timelines)
            timelines[s.timelineIndex] = s.timelineData
            timelines.sort { c1, c2 in
                return c1.date < c2.date
            }
            self.scope.launchMain { [timelines] in
                self.state = self.state.copy(
                    timelines: timelines,
                    timelineData: TimelineData("", -1, "", "", "", 0, -1),
                    timelineIndex: -1,
                    isErrorPressed: false,
                    dialogMode: 0,
                    isDialogPressed: false
                )
            }
        }
    }
    
    private func uploadTimelineVideoEdit(
        _ s: State,
        _ lecturerId: String,
        _ course: CourseForData,
        _ invoke: @escaping ([TimelineData]) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        scope.launchMed {
            var times = [TimelineData](s.timelines)
            let currentVideos = course.timelines.map { it in it.video }
            let new = [TimelineData](s.timelines).filter { it in
                !currentVideos.contains(it.video)
            }
            if (new.isEmpty) {
                invoke(s.timelines)
                return
            }
            for (i, it) in new.enumerated() {
                self.doUploadTmeLineVideo(lecturerId, URL(string: it.video)!, { str in
                    times[i] = times[i].copy(video: str)
                    if (i == new.count - 1) {
                        self.scope.launchMain { [times] in
                            invoke(s.timelines)
                            self.state = self.state.copy(timelines: times)
                        }
                    }
                }, failed)
            }
        }
    }
    
    private func uploadTimelineVideoSave(
        _ s: State,
        _ lecturerId: String,
        _ invoke: @escaping ([TimelineData]) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        scope.launchMed {
            var empty = [TimelineData](s.timelines)
            let list = empty.enumerated()
            for (i, it) in list {
                self.doUploadTmeLineVideo(lecturerId, URL(string: it.video)!, { it in
                    empty[i] = empty[i].copy(video: it)
                    if (i == empty.count - 1) {
                        self.scope.launchMain { [empty] in
                            invoke(s.timelines)
                            self.state = self.state.copy(timelines: empty)
                        }
                    }
                }, failed)
            }
        }
    }
    
    private func doUploadTmeLineVideo(
        _ lecturerId: String,
        _ uri: URL,
        _ invoke: @escaping (String) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        scope.launch {
            self.app.project.fireApp?.upload(uri, lecturerId + "/" + "VT_" + String(currentTime) + uri.pathExtension, { it in
                invoke(it)
            }, {
                failed()
            }) ?? failed()
        }
    }
    
    private func uploadImage(
        _ state: State,
        _ lecturerId: String,
        _ invoke: @escaping (String) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        let courseUri = state.course?.imageUri
        if (state.imageUri != courseUri && !state.imageUri.isEmpty) {
            let uri = URL(string: state.imageUri)!
            if (courseUri?.contains("https") == true) {
                self.app.project.fireApp?.deleteFile(courseUri!)
            }
            self.app.project.fireApp?.upload(uri, lecturerId + "/" + "IMG_" + String(currentTime) + uri.pathExtension, { it in
                self.scope.launchMain {
                    invoke(it)
                    self.state = self.state.copy(imageUri: it, isErrorPressed: false)
                }
            }, {
                failed()
            }) ?? failed()
        } else {
            invoke(state.imageUri)
        }
    }
    
    private func uploadBriefVideo(
        _ state: State,
        _ lecturerId: String,
        _ invoke: @escaping (String) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        let briefUri = state.course?.briefVideo
        if (state.briefVideo != briefUri && !state.briefVideo.isEmpty) {
            let uri = URL(string: state.briefVideo)!
            if (briefUri?.contains("https") == true) {
                self.app.project.fireApp?.deleteFile(briefUri!)
            }
            self.app.project.fireApp?.upload(uri, lecturerId + "/" + "V" + String(currentTime) + uri.pathExtension, { it in
                self.scope.launchMain {
                    invoke(it)
                    self.state = self.state.copy(briefVideo: it, isErrorPressed: false)
                }
            }, {
                failed()
            }) ?? failed()
        } else {
            invoke(state.briefVideo)
        }
    }
    
    private func pushNotification(
        topicId: String,
        msgTitle: String,
        message: String,
        argOne: String,
        argTwo: String
    ) {
        scope.launch {
            subscribeToTopic(topicId) {

            }
            postNotification(
                PushNotification(
                    to: "/topics/\(topicId)",
                    topic: "/topics/\(topicId)",
                    data: NotificationData(
                        title: msgTitle,
                        message: message,
                        routeKey: COURSE_SCREEN_ROUTE,
                        argOne: argOne,
                        argTwo: argTwo,
                        argThree: COURSE_MODE_STUDENT
                    )
                )
            )
        }
    }

    struct State {
        var course: CourseForData? = nil
        var about: [AboutCourseData] = []
        var timelines: [TimelineData] = []
        var timelineData: TimelineData = TimelineData("", -1, "", "", "", 0, -1)
        var courseTitle: String = ""
        var price: String = ""
        var briefVideo: String = ""
        var imageUri: String = ""
        var timelineIndex: Int = -1
        var isErrorPressed: Bool = false
        var isProcessing: Bool = false
        var isDraftProcessing: Bool = false
        var dialogMode: Int = 0
        var courseTimePickerMode: Int = 0
        var isDialogPressed: Bool = false
        var isDurationDialogVisible: Bool = false
        var isConfirmDialogVisible: Bool = false
        var isFontDialogVisible: Bool = false
        var dummy: Int = 0
        
        init() {
            about.append(AboutCourseData(font: 22, text: ""))
        }

        mutating func copy(
            course: CourseForData? = nil,
            about: [AboutCourseData]? = nil,
            timelines: [TimelineData]? = nil,
            timelineData: TimelineData? = nil,
            courseTitle: String? = nil,
            price: String? = nil,
            briefVideo: String? = nil,
            imageUri: String? = nil,
            timelineIndex: Int? = nil,
            isErrorPressed: Bool? = nil,
            isProcessing: Bool? = nil,
            isDraftProcessing: Bool? = nil,
            dialogMode: Int? = nil,
            courseTimePickerMode: Int? = nil,
            isDialogPressed: Bool? = nil,
            isDurationDialogVisible: Bool? = nil,
            isConfirmDialogVisible: Bool? = nil,
            isFontDialogVisible: Bool? = nil,
            dummy: Int? = nil
        ) -> Self {
            self.course = course ?? self.course
            self.about = about ?? self.about
            self.timelines = timelines ?? self.timelines
            self.timelineData = timelineData ?? self.timelineData
            self.courseTitle = courseTitle ?? self.courseTitle
            self.price = price ?? self.price
            self.briefVideo = briefVideo ?? self.briefVideo
            self.imageUri = imageUri ?? self.imageUri
            self.timelineIndex = timelineIndex ?? self.timelineIndex
            self.isErrorPressed = isErrorPressed ?? self.isErrorPressed
            self.isProcessing = isProcessing ?? self.isProcessing
            self.isDraftProcessing = isDraftProcessing ?? self.isDraftProcessing
            self.dialogMode = dialogMode ?? self.dialogMode
            self.courseTimePickerMode = courseTimePickerMode ?? self.courseTimePickerMode
            self.isDialogPressed = isDialogPressed ?? self.isDialogPressed
            self.isDurationDialogVisible = isDurationDialogVisible ?? self.isDurationDialogVisible
            self.isConfirmDialogVisible = isConfirmDialogVisible ?? self.isConfirmDialogVisible
            self.isFontDialogVisible = isFontDialogVisible ?? self.isFontDialogVisible
            self.dummy = dummy ?? self.dummy
            return self
        }
    }
    
    deinit {
        scope.deInit()
    }

}
