import Foundation
import RealmSwift

class CreateCourseObserve : ObservableObject {
    
    private var scope = Scope()
    
    let app: AppModule
    
    @Published var state = State()
    
    init(_ app: AppModule) {
        self.app = app
    }
    
    func getCourse(id: String) {
        scope.launch {
            await self.app.project.course.getCoursesById(id) { r in
                if r.value == nil {
                    return
                }
                if (r.result == REALM_SUCCESS) {
                    var aboutList = r.value!.about.toAboutCourseData()
                    if aboutList.isEmpty {
                        aboutList.append(AboutCourseData(font: 22, text: ""))
                    }
                    self.state = self.state.copy(
                        course: CourseForData(update: r.value!, currentTime: currentTime),
                        about: aboutList,
                        timelines: r.value!.timelines.toTimelineData(),
                        courseTitle: r.value!.title,
                        price: r.value!.price,
                        briefVideo: r.value!.briefVideo,
                        imageUri: r.value!.imageUri
                    )
                }
            }
        }
    }
    
    func deleteCourse(invoke: @escaping () -> Unit) {
        scope.launch {
            if self.state.course == nil {
                return
            }
            let it = await self.app.project.course.deleteCourse(
                Course(update: self.state.course!)
            )
            if (it == REALM_SUCCESS) {
                invoke()
            }
        }
    }
    
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
        self.uploadImage(lecturerId, { imageUri in
            self.uploadBriefVideo(lecturerId, { briefVideo in
                self.uploadTimelineVideoSave(lecturerId, { timelines in
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
                        _id: ObjectId.init()
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
        scope.launch {
            self.courseForSave(isDraft, lecturerId, lecturerName, s, { course in
                self.scope.launch {
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
                    self.state = self.state.copy(isProcessing: false, isDraftProcessing: false)
                    invoke(it.value)
                }
            }, {
                invoke(nil)
            })
        }
    }
    
    func edit(
        _ isDraft: Bool,
        _ lecturerId: String,
        _ lecturerName: String,
        _ invoke: @escaping (Course?) -> Unit
    ) {
        scope.launch { [self] in
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
        self.uploadImage(lecturerId, { imageUri in
            self.uploadBriefVideo(lecturerId, { briefVideo in
                self.uploadTimelineVideoEdit(lecturerId, c!, { timelines in
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
                        _id: try! ObjectId.init(string: c!.id)
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
        scope.launch {
            self.courseForEdit(isDraft, lecturerId, lecturerName, s, { course in
                self.doEditCourse(s, course, invoke)
            }, {
                invoke(nil)
            })
        }
    }
    
    private func doEditCourse(
        _ s: State,
        _ course: Course,
        _ invoke: @escaping (Course?) -> Unit
    ) {
        scope.launch {
            if s.course == nil {
                return
            }
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
            self.state = self.state.copy(isProcessing: false, isDraftProcessing: false)
            invoke(it.value)
        }
    }
    
    func setCourseTitle(it: String) {
        state = state.copy(courseTitle: it, isErrorPressed: false)
    }

    func setPrice(it: String) {
        state = state.copy(price: it, isErrorPressed: false)
    }

    func makeFontDialogVisible() {
        state = state.copy(isFontDialogVisible: true)
    }

    func addAbout(type: Int) {
        var list = (state.about)
        list.append(AboutCourseData(font: type == 0 ? 14 : 22, text: ""))
        state = state.copy(about: list, isErrorPressed: false, isFontDialogVisible: false)
    }

    func removeAboutIndex(index: Int) {
        var list = (state.about)
        list.remove(at: index)
        state = state.copy(about: list, dummy: state.dummy + 1)
    }
    
    func changeAbout(it: String, index: Int) {
        var list = (state.about)
        list[index] = list[index].copy(text: it)
        state = state.copy(about: list, dummy: state.dummy + 1)
    }

    func setBriefVideo(it: String) {
        state = state.copy(briefVideo: it, isErrorPressed: false)
    }

    func setImageUri(it: String) {
        state = state.copy(imageUri: it, isErrorPressed: false)
    }

    func setTitleTimeline(it: String) {
        state = state.copy(
            timelineData: state.timelineData.copy(title: it),
            isDialogPressed: false
        )
    }

    func setDegreeTimeline(it: Int) {
        state = state.copy(
            timelineData: state.timelineData.copy(degree: it),
            isDialogPressed: false
        )
    }
    
    func setDurationTimeLine(it: String) {
        state = state.copy(
            timelineData: state.timelineData.copy(duration: it),
            isDialogPressed: false,
            isDurationDialogVisible: false
        )
    }

    func setVideoTimeLine(it: String) {
        state = state.copy(
            timelineData: state.timelineData.copy(video: it),
            isDialogPressed: false
        )
    }

    func setDurationDialogVisible(it: Bool) {
        state = state.copy(isDialogPressed: false, isDurationDialogVisible: it)
    }

    func displayDateTimePicker() {
        state = state.copy(dateTimePickerMode: 1, isDialogPressed: false)
    }

    func displayTimePicker() {
        state = state.copy(dateTimePickerMode: 2, isDialogPressed: false)
    }
    
    func closeDateTimePicker() {
        state = state.copy(dateTimePickerMode: 0, isDialogPressed: false)
    }

    func confirmTimelineDateTimePicker(_ selectedDateMillis: Int64) {
        state = state.copy(
            timelineData: state.timelineData.copy(date: selectedDateMillis),
            dateTimePickerMode: 0,
            isDialogPressed: false
        )
    }

    func setTimelineNote(it: String) {
        state = state.copy(
            timelineData: state.timelineData.copy(note: it),
            isErrorPressed: false
        )
    }

    func setIsExam(isExam: Bool) {
        state = state.copy(
            timelineData: TimelineData("", -1, "", "", "", isExam ? 1 : 0, 0),
            timelineIndex: -1,
            isDialogPressed: false
        )
    }

    func changeUploadDialogGone(it: Bool) {
        state = state.copy(isConfirmDialogVisible: it)
    }

    func makeDialogGone() {
        state = state.copy(
            timelineData: TimelineData("", -1, "", "", "", 0, 0), timelineIndex: -1, isErrorPressed: false, dialogMode: 0,
            isDialogPressed: false
        )
    }

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
    
    func deleteTimeLine(i: Int) {
        var timelines = [TimelineData](state.timelines)
        timelines.remove(at: i)
        self.state = self.state.copy(timelines: timelines)
    }

    private func addTimeline(s: State) {
        var timelines = [TimelineData](s.timelines)
        timelines.append(
            s.timelineData
        )
        timelines.sort { c1, c2 in
            return c1.date < c2.date
        }
        self.state = self.state.copy(
            timelines: timelines,
            timelineData: TimelineData("", -1, "", "", "", 0, 0),
            timelineIndex: -1,
            isErrorPressed: false,
            dialogMode: 0,
            isDialogPressed: false
        )
    }
    
    private func editTimeline(s: State) {
        var timelines = [TimelineData](s.timelines)
        timelines[s.timelineIndex] = s.timelineData
        timelines.sort { c1, c2 in
            return c1.date < c2.date
        }
        state = state.copy(
            timelines: timelines,
            timelineData: TimelineData("", -1, "", "", "", 0, 0),
            timelineIndex: -1,
            isErrorPressed: false,
            dialogMode: 0,
            isDialogPressed: false
        )
    }
    
    private func uploadTimelineVideoEdit(
        _ lecturerId: String,
        _ course: CourseForData,
        _ invoke: @escaping ([TimelineData]) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        let s = state
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
            doUploadTmeLineVideo(lecturerId, URL(string: it.video)!, { str in
                times[i] = times[i].copy(video: str)
                if (i == new.count - 1) {
                    invoke(s.timelines)
                    self.state = self.state.copy(timelines: times)
                }
            }, failed)
        }
    }
    
    private func uploadTimelineVideoSave(
        _ lecturerId: String,
        _ invoke: @escaping ([TimelineData]) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        let s = state
        var empty = [TimelineData](s.timelines)
        let list = empty.enumerated()
        for (i, it) in list {
            doUploadTmeLineVideo(lecturerId, URL(string: it.video)!, { it in
                empty[i] = empty[i].copy(video: it)
                if (i == empty.count - 1) {
                    invoke(s.timelines)
                    self.state = self.state.copy(timelines: empty)
                }
            }, failed)
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
        _ lecturerId: String,
        _ invoke: @escaping (String) -> Unit,
        _ failed: @escaping () -> Unit) {
        let courseUri = state.course?.imageUri
        if (state.imageUri != courseUri && !state.imageUri.isEmpty) {
            let uri = URL(string: state.imageUri)!
            if (courseUri?.contains("https") == true) {
                self.app.project.fireApp?.deleteFile(courseUri!)
            }
            self.app.project.fireApp?.upload(uri, lecturerId + "/" + "IMG_" + String(currentTime) + uri.pathExtension, { it in
                invoke(it)
                self.state = self.state.copy(imageUri: it, isErrorPressed: false)
            }, {
                failed()
            }) ?? failed()
        } else {
            invoke(state.imageUri)
        }
    }
    
    private func uploadBriefVideo(
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
                invoke(it)
                self.state = self.state.copy(briefVideo: it, isErrorPressed: false)
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
                    to: "/topics/$topicId",
                    topic: "/topics/$topicId",
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
        var timelineData: TimelineData = TimelineData("", -1, "", "", "", 0, 0)
        var courseTitle: String = ""
        var price: String = ""
        var briefVideo: String = ""
        var imageUri: String = ""
        var timelineIndex: Int = -1
        var isErrorPressed: Bool = false
        var isProcessing: Bool = false
        var isDraftProcessing: Bool = false
        var dialogMode: Int = 0
        var dateTimePickerMode: Int = 0
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
            dateTimePickerMode: Int? = nil,
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
            self.dateTimePickerMode = dateTimePickerMode ?? self.dateTimePickerMode
            self.courseTimePickerMode = courseTimePickerMode ?? self.courseTimePickerMode
            self.isDialogPressed = isDialogPressed ?? self.isDialogPressed
            self.isDurationDialogVisible = isDurationDialogVisible ?? self.isDurationDialogVisible
            self.isConfirmDialogVisible = isConfirmDialogVisible ?? self.isConfirmDialogVisible
            self.isFontDialogVisible = isFontDialogVisible ?? self.isFontDialogVisible
            self.dummy = dummy ?? self.dummy
            return self
        }
    }

    
}
