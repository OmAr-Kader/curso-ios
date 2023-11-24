import Foundation
import RealmSwift

class CourseRepoImp : BaseRepoImp, CourseRepo {

    func getCoursesById(
        id: String,
        course: (ResultRealm<Course?>) -> Unit
    ) async {
        do {
            let realmId = try ObjectId.init(string: id)
            await querySingle(course, "getCoursesById$id", "partition == $0 AND _id == $1", ["public", realmId])
        } catch {
            course(ResultRealm(value: nil, result: REALM_FAILED))
        }
    }

    func getAllCourses(
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await query(course, "getAllCourses", "partition == $0 AND isDraft == $1", ["public", -1])
    }

    func getStudentCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await query(course, "getStudentCourses$id", "partition == $0 AND students.studentId == $1 AND isDraft == $2", ["public", id, -1])
    }

    func getLecturerCourses(
        id: String,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await query(course, "getLecturerCourses$id", "partition == $0 AND lecturerId == $1", ["public", id])
    }

     func getAvailableLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
     ) async {
         await queryLess(
            course,
            "partition == $0 AND lecturerId == $1 AND timelines.date < $2",
            ["public", id, currentTime]
        )
     }
    
    func getUpcomingLecturerTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await queryLess(
            course,
            "partition == $0 AND lecturerId == $1 AND timelines.date > $2",
            ["public", id, currentTime]
        )
    }
    
    func getAvailableStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await queryLess(
            course,
            "partition == $0 AND students.studentId == $1 AND isDraft == $2 AND timelines.date < $3",
            ["public", id, -1, currentTime]
        )
    }

    func getUpcomingStudentTimeline(
        id: String,
        currentTime: Int64,
        course: (ResultRealm<[Course]>) -> Unit
    ) async {
        await queryLess(
            course,
            "partition == $0 AND students.studentId == $1 AND isDraft == $2 AND timelines.date > $3",
            ["public", id, -1, currentTime]
        )
    }

    func insertCourse(course: Course) async -> ResultRealm<Course?> {
        return await insert(course)
    }

    func editCourse(
        course: Course,
        edit: Course
    ) async -> ResultRealm<Course?> {
        return await self.edit(course._id) { it in it.copy(edit) }
    }

    func deleteCourse(course: Course) async -> Int {
        return await delete(course, "_id == $0", course._id)
    }
    
}
