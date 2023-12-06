
protocol ArticleRepo {

    @BackgroundActor
    func getAllArticles(
        article: (ResultRealm<[Article]>) -> ()
    ) async

    @BackgroundActor
    func getArticlesById(
        id: String,
        article: (ResultRealm<Article?>) -> ()
    ) async

    @BackgroundActor
    func getLecturerArticles(
        id: String,
        article: (ResultRealm<[Article]>) -> ()
    ) async

    @BackgroundActor
    func insertArticle(article: Article) async -> ResultRealm<Article?>

    @BackgroundActor
    func editArticle(article: Article, edit: Article) async -> ResultRealm<Article?>

    @BackgroundActor
    func deleteArticle(article: Article) async -> Int
}
