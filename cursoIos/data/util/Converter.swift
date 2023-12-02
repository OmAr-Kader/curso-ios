import Foundation
import RealmSwift


extension List {
    
    func toList() -> [Element] {
        var list: [Element] = [Element]()
        self.forEach { it in
            list.append(it)
        }
        return list
    }

}

extension Array<String> {
    
    func toRealmList() -> List<String> {
        let realmList: List<String> = List()
        self.forEach { it in
            realmList.append(it)
        }
        return realmList
    }

}

extension Array where Element : EmbeddedObject {
    
    func toRealmList() -> List<Element> {
        let realmList: List<Element> = List()
        self.forEach { it in
            realmList.append(it)
        }
        return realmList
    }

}

extension Array where Element : Object {
    
    func toRealmList() -> List<Element> {
        let realmList: List<Element> = List()
        self.forEach { it in
            realmList.append(it)
        }
        return realmList
    }
}

extension [StudentLecturerData] {

    func toStudentLecturer() -> List<StudentLecturer> {
        return self.map { it in
            StudentLecturer(update: it)
        }.toRealmList()
    }
    
    var alreadyFollowed: (String) -> Bool {
        return { it in
            first { sc in
                sc.studentId == it
            } != nil
        }
    }
}

extension List<StudentLecturer> {
    
    func toStudentLecturerData() -> [StudentLecturerData] {
        return self.toList().map { it in
            StudentLecturerData(update: it)
        }
    }
}

extension [Article] {
    
    func toArticleForData() -> [ArticleForData] {
        return self.map { it in
            ArticleForData(update: it)
        }
    }
}

extension [ArticleTextData] {

    func toArticleText() -> List<ArticleText> {
        return self.map { it in
            ArticleText(font: it.font, text: it.text)
        }.toRealmList()
    }
}

extension List<ArticleText> {
    
    func toArticleTextData() -> [ArticleTextData] {
        return self.toList().map { it in
            ArticleTextData(font: it.font, text: it.text)
        }
    }
}

extension [MessageForData] {

    func toMessage() -> List<Message> {
        return self.map { it in
            Message(update: it)
        }.toRealmList()
    }
}

extension List<Message> {
    
    func toMessageData() -> [MessageForData] {
        return self.toList().map { it in
            MessageForData(update: it)
        }
    }
}

extension [CourseForData] {
    
    func splitCourses() -> [SessionForDisplay] {
        var courses = [SessionForDisplay]()
        forEach { course in
            for (index, it) in course.timelines.enumerated() {
                let it = SessionForDisplay(
                    title: it.title,
                    date: it.date,
                    dateStr: it.date.toStr,
                    note: it.note,
                    video: it.video,
                    timelineMode: it.mode,
                    courseId: course.id,
                    courseName: course.title,
                    lecturerId: course.lecturerId,
                    lecturerName: course.lecturerName,
                    studentId: "",
                    studentName: "",
                    timelineIndex: index,
                    mode: 1,
                    duration: it.duration,
                    imageUri: course.imageUri,
                    isDraft: course.isDraft
                )
                courses.append(it)
            }
        }
        return courses
    }
}

extension [Course] {
    func toCourseForData(_ currentTime: Int64) -> [CourseForData] {
        return self.map { it in
            CourseForData(update: it, currentTime: currentTime)
        }
    }
}

extension [AboutCourseData] {

    func toAboutCourse() -> List<AboutCourse> {
        return self.map { it in
            AboutCourse(font: it.font, text: it.text)
        }.toRealmList()
    }
}

extension List<AboutCourse> {
    
    func toAboutCourseData() -> [AboutCourseData] {
        return self.toList().map { it in
            AboutCourseData(font: it.font, text: it.text)
        }
    }
}

extension [TimelineData] {

    func toTimeline() -> List<Timeline> {
        return self.map { it in
            Timeline(it: it)
        }.toRealmList()
    }
}

extension List<Timeline> {
    
    func toTimelineData() -> [TimelineData] {
        return self.toList().map { it in
            TimelineData(it: it)
        }
    }
}

extension [StudentCoursesData] {

    func toStudentCourses() -> List<StudentCourses> {
        return self.map { it in
            StudentCourses(update: it)
        }.toRealmList()
    }
}

extension List<StudentCourses> {
    
    func toStudentCoursesData() -> [StudentCoursesData] {
        return self.toList().map { it in
            StudentCoursesData(it: it)
        }
    }
}
