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
                loggerError("FirebaseApp.upload", e?.localizedDescription ?? "")
                return
            }
            storage.downloadURL { u, ee in
                if (u == nil) {
                    failed()
                    loggerError("FirebaseApp.upload", ee?.localizedDescription ?? "")
                    return
                }
                
                invoke(u!.absoluteString)
            }
        }
    }
    
    func deleteFile(
        uri: String
    ) {
        Storage.storage(app: self).reference(forURL: uri).delete { e in
            loggerError("FirebaseApp.delete", e?.localizedDescription ?? "")
        }
    }

}

/*
 @androidx.compose.runtime.Composable
 fun android.content.Context.filePicker(
     isImage: Boolean,
     invoke: (android.net.Uri) -> Unit,
 ): () -> Unit {
     val photoPicker = androidx.activity.compose.rememberLauncherForActivityResult(
         contract = androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia()
     ) {
         if (it != null) {
             invoke.invoke(it)
         }
     }
     val launcher = androidx.activity.compose.rememberLauncherForActivityResult(
         androidx.activity.result.contract.ActivityResultContracts.RequestPermission()
     ) { isGranted ->
         if (isGranted) {
             photoPicker.launch(
                 androidx.activity.result.PickVisualMediaRequest(
                     if (isImage)
                         androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia.ImageOnly
                     else
                         androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia.VideoOnly
                 )
             )
         }
     }
     return androidx.compose.runtime.remember {
         return@remember {
             if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                 if (isImage) android.Manifest.permission.READ_MEDIA_IMAGES else android.Manifest.permission.READ_MEDIA_VIDEO
             } else {
                 android.Manifest.permission.READ_EXTERNAL_STORAGE
             }.let {
                 androidx.core.content.ContextCompat.checkSelfPermission(
                     this@filePicker,
                     it
                 ).let { per ->
                     if (per == android.content.pm.PackageManager.PERMISSION_GRANTED) {
                         photoPicker.launch(
                             androidx.activity.result.PickVisualMediaRequest(
                                 if (isImage)
                                     androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia.ImageOnly
                                 else
                                     androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia.VideoOnly
                             )
                         )
                     } else {
                         launcher.launch(it)
                     }
                 }
             }
         }
     }
 }*/
