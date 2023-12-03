import SwiftUI

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
/*
 

 @Composable
 fun HomeAllArticlesView(
     articles: List<ArticleForData>,
     additionalItem: (@Composable () -> Unit)? = null,
     nav: (ArticleForData) -> Unit,
 ) {
     ListBody(list = articles, bodyClick = nav, additionalItem) { (title, lecturerName, _, imageUri, _, _, readers, _, _, _, _, _) ->
         MainItem(title = title, imageUri = imageUri) {
             AllArticleIem(lecturerName = lecturerName, readers = readers)
         }
     }
 }
*/
