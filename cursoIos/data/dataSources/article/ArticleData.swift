import Foundation

class ArticleData {
    
    var repository: ArticleRepo
    
    init(repository: ArticleRepo) {
        self.repository = repository
    }
    
    func getAllArticles(
        _ article: (ResultRealm<[Article]>) -> ()
    ) async {
        await repository.getAllArticles(article: article)
    }

    func getArticlesById(
        _ id: String,
        _ article: (ResultRealm<Article?>) -> ()
    ) async {
        await repository.getArticlesById(id: id, article: article)
    }

    func getLecturerArticles(
        _ id: String,
        _ article: (ResultRealm<[Article]>) -> ()
    ) async {
        await repository.getLecturerArticles(id: id, article: article)
    }

    func insertArticle(_ article: Article) async -> ResultRealm<Article?> {
        return await repository.insertArticle(article: article)
    }

    func editArticle(_ article: Article,_ edit: Article) async -> ResultRealm<Article?> {
        return await repository.editArticle(article: article, edit: edit)
    }

    func deleteArticle(_ article: Article) async -> Int {
        return await repository.deleteArticle(article: article)
    }
}

