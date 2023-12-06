
class ArticleData {
    
    var repository: ArticleRepo
    
    init(repository: ArticleRepo) {
        self.repository = repository
    }
    
    @BackgroundActor
    func getAllArticles(
        _ article: (ResultRealm<[Article]>) -> ()
    ) async {
        await repository.getAllArticles(article: article)
    }

    @BackgroundActor
    func getArticlesById(
        _ id: String,
        _ article: (ResultRealm<Article?>) -> ()
    ) async {
        await repository.getArticlesById(id: id, article: article)
    }

    @BackgroundActor
    func getLecturerArticles(
        _ id: String,
        _ article: (ResultRealm<[Article]>) -> ()
    ) async {
        await repository.getLecturerArticles(id: id, article: article)
    }

    @BackgroundActor
    func insertArticle(_ article: Article) async -> ResultRealm<Article?> {
        return await repository.insertArticle(article: article)
    }

    @BackgroundActor
    func editArticle(_ article: Article,_ edit: Article) async -> ResultRealm<Article?> {
        return await repository.editArticle(article: article, edit: edit)
    }

    @BackgroundActor
    func deleteArticle(_ article: Article) async -> Int {
        return await repository.deleteArticle(article: article)
    }
}

