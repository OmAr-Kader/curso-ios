import Foundation

class ArticleData {
    
    var repository: ArticleRepo
    
    init(repository: ArticleRepo) {
        self.repository = repository
    }
    
    func getAllArticles(
        article: (ResultRealm<[Article]>) -> ()
    ) async {
        await repository.getAllArticles(article: article)
    }

    func getArticlesById(
        id: String,
        article: (ResultRealm<Article?>) -> ()
    ) async {
        await repository.getArticlesById(id: id, article: article)
    }

    func getLecturerArticles(
        id: String,
        article: (ResultRealm<[Article]>) -> ()
    ) async {
        await repository.getLecturerArticles(id: id, article: article)
    }

    func insertArticle(article: Article) async -> ResultRealm<Article?> {
        return await repository.insertArticle(article: article)
    }

    func editArticle(article: Article, edit: Article) async -> ResultRealm<Article?> {
        return await repository.editArticle(article: article, edit: edit)
    }

    func deleteArticle(article: Article) async -> Int {
        return await repository.deleteArticle(article: article)
    }
}

