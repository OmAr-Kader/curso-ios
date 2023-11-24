import Foundation

protocol ArticleRepo {

    func getAllArticles(
        article: (ResultRealm<[Article]>) -> ()
    ) async

    func getArticlesById(
        id: String,
        article: (ResultRealm<Article?>) -> ()
    ) async

    func getLecturerArticles(
        id: String,
        article: (ResultRealm<[Article]>) -> ()
    ) async

    func insertArticle(article: Article) async -> ResultRealm<Article?>

    func editArticle(article: Article, edit: Article) async -> ResultRealm<Article?>

    func deleteArticle(article: Article) async -> Int
}
