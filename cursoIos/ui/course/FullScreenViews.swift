import SwiftUI
import AVKit

struct PlayerView: View {
    let videoURL : String
    @State private var player : AVPlayer?
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .onAppear() {
                    guard let url = URL(string: videoURL) else {
                        return
                    }
                    let player = AVPlayer(url: url)
                    self.player = player
                    player.play()
                }
                .onDisappear() {
                    player?.pause()
                }
        }.background(Color.black)
    }
}


struct ImageViewScreen : View {
    let imageUri: String
    var body: some View {
        GeometryReader { geo in
            VStack {
                ImageView(urlString: imageUri).frame(width: geo.size.width)
            }.background(Color.black).frame(width: geo.size.width)
        }
    }
}
