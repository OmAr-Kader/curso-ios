import SwiftUI
import AVKit

struct PlayerView: View {
    @StateObject var pref: PrefObserve

    private var videoURL: String {
        return pref.getArgumentOne(it: VIDEO_SCREEN_ROUTE) ?? ""
    }
    @State private var player : AVPlayer? = nil
    @State private var isBackVisiable : Bool = true
    @State private var controller = AVPlayerViewController()

    var body: some View {
        /*VStack {
        }.background(Color.black)*/
        ZStack {
            VideoPlayer(
                player: player
            ).onAppear() {
                guard let url = URL(string: videoURL) else {
                    return
                }
                let player = AVPlayer(url: url)
                self.player = player
                controller.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                controller.player = player
                
                controller.player?.play()
            }.onDisappear() {
                player?.pause()
            }
            //if isBackVisiable {
            BackButton {
                pref.backPress()
            }.onTop().onStart()
            //}
        }.toolbar(.visible, for: .navigationBar)
    }
}

struct ImageViewScreen : View {
    
    @StateObject var pref: PrefObserve
    private var imageUri: String {
        return pref.getArgumentOne(it: IMAGE_SCREEN_ROUTE) ?? ""
    }

    var body: some View {
        ZStack {
            FullZStack {
                VStack {
                    ImageCacheView(imageUri)//.frame(width: geo.size.width)
                }.background(Color.black)//.frame(width: geo.size.width)
            }//.toolbar(.visible, for: .navigationBar)
            BackButton {
                pref.backPress()
            }.onStart().onTop()
        }
    }
}
