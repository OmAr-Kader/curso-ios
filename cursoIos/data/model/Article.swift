import Foundation
import RealmSwift

@BackgroundActor
class Article: Object {

    @Persisted var title: String
    @Persisted var lecturerName: String
    @Persisted(indexed: true) var lecturerId: String = ""
    @Persisted(indexed: true) var imageUri: String = ""
    @Persisted var text: List<ArticleText>
    @Persisted var readerIds: List<String>
    @Persisted var rate: Double = 5.0
    @Persisted var raters: Int = 0
    @Persisted var lastEdit: Int64
    @Persisted var isDraft: Int = 0
    @Persisted var partition: String = "public"
    @Persisted(primaryKey: true) var _id: ObjectId
    
    convenience init(title: String, lecturerName: String, lecturerId: String, imageUri: String, text: List<ArticleText>, lastEdit: Int64, isDraft: Int,
         readerIds: List<String>? = nil, rate: Double? = nil, raters: Int? = nil) {
        self.init()
        self.title = title
        self.lecturerName = lecturerName
        self.lecturerId = lecturerId
        self.imageUri = imageUri
        self.text = text
        self.readerIds = readerIds ?? List()
        self.rate = rate ??  5.0
        self.raters = raters ?? 0
        self.lastEdit = lastEdit
        self.isDraft = isDraft
    }
    
    override init() {
        super.init()
        title = ""
        lecturerName = ""
        lecturerId = ""
        imageUri = ""
        text = List()
        readerIds = List()
        rate = 5.0
        raters = 0
        lastEdit = 0
        isDraft = 0
    }

    convenience init(update: Article, readerIds: [String]) {
        self.init()
        title = update.title
        lecturerName = update.lecturerName
        lecturerId = update.lecturerId
        imageUri = update.imageUri
        text = update.text
        self.readerIds = readerIds.toRealmList()
        rate = update.rate
        raters = update.raters
        lastEdit = update.lastEdit
        isDraft = update.isDraft
        catchy {
            try _id = ObjectId.init(string: update._id.stringValue)
        }
    }

    convenience init(update: ArticleForData) {
        self.init()
        title = update.title
        lecturerName = update.lecturerName
        lecturerId = update.lecturerId
        imageUri = update.imageUri
        text = update.text.toArticleText()
        readerIds = update.readerIds.toRealmList()
        rate = update.rate
        raters = update.raters
        lastEdit = update.lastEdit
        partition = "public"
        isDraft = update.isDraft
        catchy {
            try _id = ObjectId.init(string: update.id)
        }
    }

    func copy(_ update: Article) -> Article {
        title = update.title
        lecturerName = update.lecturerName
        lecturerId = update.lecturerId
        imageUri = update.imageUri
        text = update.text
        readerIds = update.readerIds
        rate = update.rate
        raters = update.raters
        lastEdit = update.lastEdit
        isDraft = update.isDraft
        return self
    }
}

@BackgroundActor
class ArticleText: EmbeddedObject {
    
    @Persisted var font: Int = 14
    @Persisted var text: String = ""
    
    override init() {
        text = ""
        font = 0
    }
    
    convenience init(font: Int, text: String) {
        self.init()
        self.text = text
        self.font = font
    }
    
}

struct ArticleTextData : ForSubData {
    
    var font: Int = 14
    var text: String = ""
    
    mutating func copy(text: String) -> Self {
        self.text = text
        return self
    }
}

struct ArticleForData : ForData  {
    
    var title: String
    var lecturerName: String
    var lecturerId: String
    var imageUri: String
    var text: [ArticleTextData]
    var readerIds: [String]
    var readers: String
    var rate: Double = 5.0
    var raters: Int = 0
    var lastEdit: Int64
    var isDraft: Int = 0
    var id: String
    
    var scrollId: String {
        return id
    }
    
    init() {
        title = ""
        lecturerName = ""
        lecturerId = ""
        imageUri = ""
        text = [ArticleTextData]()
        readerIds = [String]()
        readers = "0"
        rate = 5.0
        raters = 0
        lastEdit = 0
        isDraft = 0
        id = ""
    }

    @BackgroundActor
    init(update: Article) {
        title = update.title
        lecturerName = update.lecturerName
        lecturerId = update.lecturerId
        imageUri = update.imageUri
        text = update.text.toArticleTextData()
        readerIds = update.readerIds.toList()
        readers = "" + String(update.readerIds.count)
        rate = update.rate
        raters = update.raters
        lastEdit = update.lastEdit
        isDraft = update.isDraft
        id = update._id.stringValue
    }
}
