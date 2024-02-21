import Foundation
import FirebaseStorage
import FirebaseCore

extension FirebaseApp {
 
    func upload(
        _ uri: URL,
        _ nameFile: String,
        _ invoke: @escaping (String) -> Unit,
        _ failed: @escaping () -> Unit
    ) {
        let storage = Storage.storage(app: self).reference().child(nameFile)
        storage.putFile(from: uri) { it, e in
            if (it == nil) {
                failed()
                print("FirebaseApp.upload" + (e?.localizedDescription ?? ""))
                return
            }
            print("==" + "put")
            storage.downloadURL { u, ee in
                if (u == nil) {
                    failed()
                    print("FirebaseApp.upload" + (ee?.localizedDescription ?? ""))
                    return
                }
                print("==" + u!.absoluteString)
                invoke(u!.absoluteString)
            }
        }
    }
    
    func deleteFile(
        _ uri: String
    ) {
        Storage.storage(app: self).reference(forURL: uri).delete { e in
            loggerError("FirebaseApp.delete", e?.localizedDescription ?? "")
        }
    }

}

