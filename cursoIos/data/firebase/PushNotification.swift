import Foundation

struct PushNotification : Codable {
    //origin //main
    let to: String
    let topic: String
    let data: NotificationData
    
    init(to: String, topic: String, data: NotificationData) {
        self.to = to
        self.topic = topic
        self.data = data
    }
    
    init(info: [AnyHashable : Any]) {
        topic = info["topic"] as? String ?? ""
        to = info["to"] as? String ?? ""
        data = NotificationData.init(info: info["data"] as? [AnyHashable : Any])
    }
    
    var mapper: [AnyHashable : Any] {
        [
            "topic": topic,
            "to": to,
            "data" : data.mapper
        ]
    }
}

struct NotificationData : Codable {
    
    let title: String
    let message: String
    let routeKey: String
    let argOne: String
    let argTwo: String
    let argThree: Int
    
    init(title: String, message: String, routeKey: String, argOne: String, argTwo: String, argThree: Int) {
        self.title = title
        self.message = message
        self.routeKey = routeKey
        self.argOne = argOne
        self.argTwo = argTwo
        self.argThree = argThree
    }
    
    init(info: [AnyHashable : Any]?) {
        title = info?["title"] as? String ?? ""
        message = info?["message"] as? String ?? ""
        routeKey = info?["routeKey"] as? String ?? ""
        argOne = info?["argOne"] as? String ?? ""
        argTwo = info?["argTwo"] as? String ?? ""
        argThree = info?["argThree"] as? Int ?? 0
    }
    
    var mapper: [AnyHashable : Any] {
        [
            "title" : title,
            "message" : message,
            "routeKey" : routeKey,
            "argOne" : argOne,
            "argTwo" : argTwo,
            "argThree" : argThree
        ]
    }
    
}
