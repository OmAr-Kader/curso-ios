import Foundation
import RealmSwift

class ArticleRepoImp : BaseRepoImp, ArticleRepo {

    func getAllArticles(
        article: (ResultRealm<[Article]>) -> ()
    ) async {
        await query(article, "getAllArticles", "partition == $0 AND isDraft == $1", ["public", -1])
    }

    func getArticlesById(
        id: String,
        article: (ResultRealm<Article?>) -> ()
    ) async {
        do {
            let realmId = try ObjectId.init(string: id)
            await querySingle(article, "getArticlesById$id", "partition == $0 AND _id == $1", ["public", realmId])
        } catch {
            article(ResultRealm(value: nil, result: REALM_FAILED))
        }
    }
    
    func getLecturerArticles(
        id: String,
        article: (ResultRealm<[Article]>) -> ()
    ) async {
        await query(article, "getLecturerArticles$id", "partition == $0 AND lecturerId == $1", ["public", id])
    }


    func insertArticle(article: Article) async -> ResultRealm<Article?> {
        return await insert(article)
    }

    func editArticle(article: Article, edit: Article) async -> ResultRealm<Article?> {
        return await self.edit(article._id) { it in it.copy(edit) }
    }

    func deleteArticle(article: Article) async -> Int {
        return await delete(article, "_id == $0", article._id)
    }
}
