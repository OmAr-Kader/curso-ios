
import Foundation
import RealmSwift

class Course: Object {

    @Persisted var title: String
    @Persisted var lecturerName: String
    @Persisted(indexed: true) var lecturerId: String = ""
    @Persisted(indexed: true) var price: String = ""
    @Persisted var imageUri: String
    @Persisted var about: List<AboutCourse>
    @Persisted var briefVideo: String
    @Persisted var timelines: List<Timeline>
    @Persisted var students: List<StudentCourses> = List()
    @Persisted var rate: Double = 5.0
    @Persisted var raters: Int = 0
    @Persisted var lastEdit: Int64
    @Persisted var isDraft: Int = 0
    @Persisted var partition: String = "public"
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.init()
    
    override init() {
        title = ""
        lecturerName = ""
        lecturerId = ""
        price = ""
        imageUri = ""
        about = List()
        briefVideo = ""
        timelines = List()
        students = List()
        rate = 5.0
        raters = 0
        lastEdit = 0
        isDraft = 0
        _id = ObjectId.init()
    }

    convenience init(update: CourseForData) {
        self.init()
        title = update.title
        lecturerName = update.lecturerName
        lecturerId = update.lecturerId
        price = update.price
        imageUri = update.imageUri
        about = update.about.toAboutCourse()
        briefVideo = update.briefVideo
        timelines = update.timelines.toTimeline()
        students = update.students.toStudentCourses()
        rate = update.rate
        raters = update.raters
        lastEdit = update.lastEdit
        isDraft = update.isDraft
        catchy {
            try _id = ObjectId.init(string: update.id)
        }
    }

    convenience init(update: Course, hexString: String, student: [StudentCourses]) {
        self.init()
        title = update.title
        lecturerName = update.lecturerName
        lecturerId = update.lecturerId
        price = update.price
        imageUri = update.imageUri
        about = update.about
        briefVideo = update.briefVideo
        timelines = update.timelines
        students = student.toRealmList()
        rate = update.rate
        raters = update.raters
        lastEdit = update.lastEdit
        isDraft = update.isDraft
        catchy {
            try _id = ObjectId.init(string: hexString)
        }
    }

    func copy(_ update: Course) -> Course {
        title = update.title
        lecturerName = update.lecturerName
        lecturerId = update.lecturerId
        price = update.price
        imageUri = update.imageUri
        about = update.about
        briefVideo = update.briefVideo
        timelines = update.timelines
        students = update.students
        rate = update.rate
        raters = update.raters
        lastEdit = update.lastEdit
        isDraft = update.isDraft
        return self
    }
    
    func nextSession(current: Int64) -> String? {
        return timelines.first { it in
            it.date > current
        }?.title
    }

}

class Timeline : EmbeddedObject {

    @Persisted var title: String
    @Persisted var date: Int64
    @Persisted var note: String
    @Persisted var duration: String = ""
    @Persisted var video: String = ""
    @Persisted var mode: Int = 0 // EXAM = 1
    @Persisted var degree: Int = 0

    override init() {
        title = ""
        date = -1
        note = ""
        duration = ""
        degree = 0
    }

    convenience init(it: TimelineData) {
        self.init()
        title = it.title
        date = it.date
        note = it.note
        duration = it.duration
        video = it.video
        mode = it.mode
        degree = it.degree
    }

}

class AboutCourse: EmbeddedObject {
    
    @Persisted var font: Int = 14
    @Persisted var text: String = ""
    
    override init() {
        text = ""
        font = 0
    }
    
    convenience init(font: Int, text: String) {
        self.init()
        self.font = font
        self.text = text
    }
}

class StudentCourses: EmbeddedObject {
    
    @Persisted(indexed: true) var studentId: String = ""
    @Persisted(indexed: true) var studentName: String = ""
    @Persisted(indexed: true) var type: Int = COURSE_TYPE_FOLLOWED
    
    override init() {
        studentId = ""
        studentName = ""
        type = COURSE_TYPE_FOLLOWED
    }

    convenience init(update: StudentCourses) {
        self.init()
        studentId = update.studentId
        studentName = update.studentName
        type = update.type
    }

    convenience init(update: StudentCoursesData) {
        self.init()
        studentId = update.studentId
        studentName = update.studentName
        type = update.type
    }

}


class Certificate : Object {

    @Persisted var title: String
    @Persisted(indexed: true) var date: Int64 = -1
    @Persisted var rate: Double
    @Persisted(indexed: true) var courseId: String = ""
    @Persisted var partition: String = "public"
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.init()

    override init() {
        title = ""
        rate = 0.0
        date = -1
        courseId = ""
        _id = ObjectId.init()
    }

    func copy(update: Certificate) -> Certificate {
        title = update.title
        rate = update.rate
        date = update.date
        courseId = update.courseId
        return self
    }

}


struct AboutCourseData {
    let font: Int
    let text: String
}

struct SessionForDisplay {
    
    var title: String
    var date: Int64
    var dateStr: String
    var note: String
    var video: String
    var timelineMode: Int = 0 // EXAM = 1
    var courseId: String
    var courseName: String
    var lecturerId: String
    var lecturerName: String
    var studentId: String
    var studentName: String
    var timelineIndex: Int
    var mode: Int // STUDENT 0 , LECTURER 1,
    var duration: String = ""
    var imageUri: String = ""
    var isDraft: Int = 0
    
    init(course: CourseForData, timeline: TimelineData, mode: Int, userId: String, userName: String, i: Int) {
        title = timeline.title
        date = timeline.date
        dateStr = timeline.date.toStr
        note = timeline.note
        video = timeline.video
        timelineMode = timeline.mode
        courseId = course.id
        courseName = course.title
        lecturerId = course.lecturerId
        lecturerName = course.lecturerName
        studentId = if (mode == COURSE_MODE_STUDENT) {
            userId
        } else {
            ""
        }
        studentName = if (mode == COURSE_MODE_STUDENT) {
            userName
        } else {
            ""
        }
        timelineIndex = i
        self.mode = if (mode == COURSE_MODE_STUDENT) {
            0
        } else {
            1
        }
    }

}

struct TimelineData {
    
    var title: String
    var date: Int64
    var note: String
    var duration: String
    var video: String
    var mode: Int
    var degree: Int
    
    var isExam: Bool {
        return mode == 1
    }
    
    init(it: Timeline) {
        title = it.title
        date = it.date
        note = it.note
        duration = it.duration
        video = it.video
        mode = it.mode
        degree = it.degree
    }
}

struct CourseForData {

    var title: String
    var lecturerName: String
    var lecturerId: String
    var price: String
    var imageUri: String
    var about: [AboutCourseData]
    var briefVideo: String
    var timelines: [TimelineData]
    var nextTimeLine: String
    var students: [StudentCoursesData]
    var studentsSize: String
    var rate: Double = 5.0
    var raters: Int = 0
    var lastEdit: Int64
    var isDraft: Int = 0
    var id: String
    
    init() {
        title = ""
        lecturerName = ""
        lecturerId = ""
        price = ""
        imageUri = ""
        about = [AboutCourseData]()
        briefVideo = ""
        timelines = [TimelineData]()
        nextTimeLine = ""
        students = [StudentCoursesData]()
        studentsSize = "0"
        rate = 5.0
        raters = 0
        lastEdit = 0
        isDraft = 0
        id = ""
    }

    init(update: Course, currentTime: Int64) {
        title = update.title
        lecturerName = update.lecturerName
        lecturerId = update.lecturerId
        price = update.price
        imageUri = update.imageUri
        about = update.about.toAboutCourseData()
        briefVideo = update.briefVideo
        timelines = update.timelines.toTimelineData()
        let next = update.nextSession(current: currentTime)
        if (next == nil) {
            nextTimeLine = ""
        } else {
            nextTimeLine = "Next: " + next!
        }
        students = update.students.toStudentCoursesData()
        studentsSize = String(update.students.count)
        rate = update.rate
        raters = update.raters
        lastEdit = update.lastEdit
        isDraft = update.isDraft
        id = update._id.stringValue
    }
    
    func nextTimeLine(current: Int64) -> String? {
        return timelines.first { it in
            it.date > current
        }?.title
    }

}

struct StudentCoursesData {
    let studentId: String
    let studentName: String
    let type: Int
    
    init(studentId: String, studentName: String, type: Int) {
        self.studentId = studentId
        self.studentName = studentName
        self.type = type
    }


    init(it: StudentCourses){
        self.studentId = it.studentId
        self.studentName = it.studentName
        self.type = it.type
    }
}