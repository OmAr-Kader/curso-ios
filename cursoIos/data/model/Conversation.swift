import Foundation
import RealmSwift

class Conversation : Object {

    @Persisted(indexed: true) var courseId: String = ""
    @Persisted var courseName: String
    @Persisted var type: Int //  -1 => Main Course Conversation,
    @Persisted var messages: List<Message>
    @Persisted var partition: String = "public"
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.init()
    
    override init() {
        courseId = ""
        courseName = ""
        type = -1
        messages = List()
        _id = ObjectId.init()
    }

    convenience init(update: ConversationForData) {
        self.init()
        courseId = update.courseId
        courseName = update.courseName
        messages = update.messages.toMessage()
        type = update.type
        catchy {
            try _id = ObjectId.init(string: update.id)
        }
    }

    convenience init(update: Conversation, hexString: String) {
        self.init()
        courseId = update.courseId
        courseName = update.courseName
        messages = update.messages
        type = update.type
        catchy {
            try _id = ObjectId.init(string: hexString)
        }
    }

    func copy(_ update: Conversation) -> Conversation {
        courseId = update.courseId
        courseName = update.courseName
        messages = update.messages
        type = update.type
        return self
    }

}

class Message : EmbeddedObject {
    
    @Persisted var message: String
    @Persisted var data: Int64
    @Persisted var senderId: String
    @Persisted var senderName: String
    @Persisted var timestamp: Int64 // For Timeline Video,
    @Persisted var fromStudent: Bool
    
    override init() {
        message = ""
        data = -1
        senderId = ""
        senderName = ""
        timestamp = -1
        fromStudent = true
    }

    convenience init(update: MessageForData) {
        self.init()
        message = update.message
        data = update.data
        senderId = update.senderId
        senderName = update.senderName
        timestamp = update.timestamp
        fromStudent = update.fromStudent
    }
}

struct MessageForData {
    
    var message: String
    var data: Int64
    var senderId: String
    var senderName: String
    var timestamp: Int64
    var fromStudent: Bool
    
    init(update: Message) {
        message = update.message
        data = update.data
        senderId = update.senderId
        senderName = update.senderName
        timestamp = update.timestamp
        fromStudent = update.fromStudent
    }
}

struct ConversationForData {
    
    var courseId: String
    var courseName: String
    var type: Int //  -1 => Main Course Conversation,
    var messages: [MessageForData]
    var id: String

    init(update: Conversation) {
        courseId = update.courseId
        courseName = update.courseName
        type = update.type
        messages = update.messages.toMessageData()
        id = update._id.stringValue
    }

}
