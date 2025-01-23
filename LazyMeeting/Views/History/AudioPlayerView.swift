import SwiftUI

struct AudioPlayerView: View {
    @State private var progress: Double = 0.5
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "play.circle")
                    .font(.largeTitle)
            }
            
            Slider(value: $progress)
                .padding()
            
            Text("00:00 / 00:00")
        }
        .padding()
    }
}