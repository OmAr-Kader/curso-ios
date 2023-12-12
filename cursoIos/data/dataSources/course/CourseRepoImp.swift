import Foundation
import RealmSwift

class CourseRepoImp : BaseRepoImp, CourseRepo {

    @BackgroundActor
    func getCoursesById(
        id: String,
        course: (ResultRealm<Course?>) -> Unit
    ) async {
        do {
            let realmId = try ObjectId.init(string: id)
            await querySingle(
                course,
                "getCoursesById\(id)",
                "%K == %@ AND %K == %@",
                "partition", "public",
                "_id", realmId
            )
        } catch {
            course(ResultRealm(value: nil, result: REALM_FAILED))
        }
    }

    @BackgroundActor
    func getAllCourses(
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await query(
            course,
            "getAllCourses",
            "%K == %@ AND %K == %@",
            "partition", "public",
            "isDraft", NSNumber(-1)
        )
    }

    @BackgroundActor
    func getStudentCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        print("it" + id)
        await query(
            course,
            "getStudentCourses\(id)",
            "%K == %@ AND ANY %K == %@ AND %K == %@",
            "partition", "public",
            "students.studentId", NSString(string: id),
            "isDraft", NSNumber(-1)
        )
    }

    @BackgroundActor
    func getLecturerCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await query(
            course,
            "getLecturerCourses\(id)",
            "%K == %@ AND %K == %@",
            "partition", "public",
            "lecturerId", NSString(string: id))
    }

     @BackgroundActor
    func getAvailableLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
     ) async {
         await queryLess(
            course,
            "%K == %@ AND %K == %@ AND ANY %K < %@",
            "partition", "public",
            "lecturerId ",NSString(string: id),
            "timelines.date", NSNumber(value: currentTime)
        )
     }
    
    @BackgroundActor
    func getUpcomingLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await queryLess(
            course,
            "%K == %@ AND %K == %@ AND ANY %K > %@",
            "partition", "public",
            "lecturerId ",NSString(string: id),
            "timelines.date", NSNumber(value: currentTime)
        )
    }
    
    @BackgroundActor
    func getAvailableStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await queryLess(
            course,
            "%K == %@ AND ANY %K == %@ AND %K == %@ AND ANY %K < %@",
            "partition", "public",
            "students.studentId", NSString(string: id),
            "isDraft", -1,
            "timelines.date", NSNumber(value: currentTime)
        )
    }

    @BackgroundActor
    func getUpcomingStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await queryLess(
            course,
            "%K == %@ AND ANY %K == %@ AND %K == %@ AND ANY %K > %@",
            "partition", "public",
            "students.studentId", NSString(string: id),
            "isDraft", -1,
            "timelines.date", NSNumber(value: currentTime)
        )
    }

    @BackgroundActor
    func insertCourse(course: Course) async -> ResultRealm<Course?> {
        return await insert(course)
    }

    @BackgroundActor
    func editCourse(
        course: Course,
        edit: Course
    ) async -> ResultRealm<Course?> {
        return await self.edit(course._id) { it in it.copy(edit) }
    }

    @BackgroundActor
    func deleteCourse(course: Course) async -> Int {
        return await delete(course, course._id)
    }
    
}
