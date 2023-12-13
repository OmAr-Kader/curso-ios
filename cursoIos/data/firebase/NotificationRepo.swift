import Foundation
//https://mrezkys.medium.com/swiftui-device-to-device-push-notification-with-firebase-d215aa838361

func postNotification(_ not: PushNotification) {
    //let receiverFCM = ""
    //let serverKey = ""

    let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("key=\(FIREBASE_SERVER_KEY)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    do {
        //let not = try JSONDecoder().decode([PushNotification].self, from: jsonData)

        let jsonData = try JSONSerialization.data(withJSONObject: not.mapper)
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
            }
        }.resume()
    } catch let error {
        loggerError("sendNot", error.localizedDescription)
    }
}
