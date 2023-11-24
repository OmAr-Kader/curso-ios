import Foundation

struct PushNotification : Codable {
    //origin //main
    let data: NotificationData
    let topic: String
    let to: String
    
    init(info: [AnyHashable : Any]) {
        topic = info["topic"] as? String ?? ""
        to = info["to"] as? String ?? ""
        data = NotificationData.init(info: info["data"] as? [AnyHashable : Any])
    }
}

struct NotificationData : Codable {
    
    let title: String
    let message: String
    let routeKey: String
    let argOne: String
    let argTwo: String
    let argThree: Int

    init(info: [AnyHashable : Any]?) {
        title = info?["title"] as? String ?? ""
        message = info?["message"] as? String ?? ""
        routeKey = info?["routeKey"] as? String ?? ""
        argOne = info?["argOne"] as? String ?? ""
        argTwo = info?["argTwo"] as? String ?? ""
        argThree = info?["argThree"] as? Int ?? 0
   }
}
