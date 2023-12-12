import SwiftUI

struct HomeOwnCoursesView : View {
    let courses: [CourseForData]
    let theme: Theme
    let nav: (CourseForData) -> Unit
    var body: some View {
        ListBody(list: courses, bodyClick: nav) { course in
            MainItem(
                title: course.title, imageUri: course.imageUri, textColor: theme.textColor
            ) {
                OwnCourseItem(
                    nextTimeLine: course.nextTimeLine,
                    students: course.studentsSize,
                    theme: theme
                )
            }
        }
    }
}

struct HomeAllCoursesView : View {
    let courses: [CourseForData]
    let theme: Theme
    let nav: (CourseForData) -> Unit
    
    var body: some View {
        ListBody(list: courses, bodyClick: nav) { c in
            MainItem(title: c.title, imageUri: c.imageUri, textColor: theme.textColor) {
                AllCourseItem(lecturerName: c.lecturerName, price: c.price, theme: theme)
            }
        }
    }
}


struct HomeAllCoursesAdditionalView<Additional: View> : View {
    let courses: [CourseForData]
    let theme: Theme
    @ViewBuilder var additionalView:  () -> Additional
    let nav: (CourseForData) -> Unit
    var body: some View {
        ListBodyEditAdditional(
            list: courses, nav: nav, additionalItem: self.additionalView
        ) { c in
            MainItem(title: c.title, imageUri: c.imageUri, textColor: theme.textColor) {
                AllCourseItem(lecturerName: c.lecturerName, price: c.price, theme: theme)
            }
        }
    }
}

struct HomeAllArticlesView : View {
    let articles: [ArticleForData]
    let theme: Theme
    let nav: (ArticleForData) -> Unit

    var body: some View {
        ListBody(list: articles, bodyClick: nav) { c in
            MainItem(title: c.title, imageUri: c.imageUri, textColor: theme.textColor) {
                AllArticleIem(
                    lecturerName: c.lecturerName,
                    readers: c.readers,
                    theme: theme
                )
            }
        }
    }
}

struct LecturerCoursesView : View {
    let courses: [CourseForData]
    let theme: Theme
    let nav: (CourseForData) -> Unit
    
    var body: some View {
        ListBody(list: courses, bodyClick: nav) { course in
            MainItem(
                title: course.title, imageUri: course.imageUri, textColor: theme.textColor
            ) {
                LecturerCourseItem(nextTimeLine: course.nextTimeLine, students: course.studentsSize, price: course.price, theme: theme
                )
            }
        }
    }
}



struct StudentTimeLineView : View {
    let sessions: [SessionForDisplay]
    let theme: Theme
    let nav: (SessionForDisplay) -> Unit

    var body: some View {
        ListBody(list: sessions, bodyClick: nav) { session in
            MainItem(
                title: session.title,
                imageUri: session.imageUri,
                textColor: theme.textColor
                ) {
                     TimelineItem(
                        courseName: session.courseName,
                        date: session.dateStr, duration:
                        session.duration,
                        textGrayColor: theme.textGrayColor
                     )
                }
        }
    }
}

