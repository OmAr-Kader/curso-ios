import Foundation
import RealmSwift

class Preference : Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.init()
    @Persisted(indexed: true) var ketString: String = ""
    @Persisted var value: String = ""

    override init() {
        _id = ObjectId.init()
        ketString = ""
        value = ""
    }
    
    convenience init(ketString: String, value: String) {
        self.init()
        self.ketString = ketString
        self.value = value
    }

}
