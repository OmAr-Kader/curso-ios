import Foundation
import RealmSwift

class ArticleRepoImp : BaseRepoImp, ArticleRepo {

    @BackgroundActor
    func getAllArticles(
        article: (ResultRealm<[Article]>) -> ()
    ) async {
        await query(
            article,
            "getAllArticles",
            "%K == %@ AND %K == %@",
            "partition", "public",
            "isDraft", NSNumber(-1))
    }

    @BackgroundActor
    func getArticlesById(
        id: String,
        article: (ResultRealm<Article?>) -> ()
    ) async {
        do {
            let realmId = try ObjectId.init(string: id)
            await querySingle(
                article,
                "getArticlesById\(id)",
                "%K == %@ AND %K == %@",
                "partition", "public",
                "_id", realmId
            )
        } catch {
            article(ResultRealm(value: nil, result: REALM_FAILED))
        }
    }
    
    @BackgroundActor
    func getLecturerArticles(
        id: String,
        article: (ResultRealm<[Article]>) -> ()
    ) async {
        await query(
            article,
            "getLecturerArticles\(id)",
            "%K == %@ AND %K == %@",
            "partition", "public",
            "lecturerId", NSString(string: id)
        )
    }

    @BackgroundActor
    func insertArticle(article: Article) async -> ResultRealm<Article?> {
        return await insert(article)
    }

    @BackgroundActor
    func editArticle(article: Article, edit: Article) async -> ResultRealm<Article?> {
        return await self.edit(article._id) { it in it.copy(edit) }
    }

    @BackgroundActor
    func deleteArticle(article: Article) async -> Int {
        return await delete(article, article._id)
    }
}
