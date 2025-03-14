import SwiftUI

struct RecordingDetailView: View {
    var body: some View {
        VStack {
            AudioPlayerView()
            
            TabView {
                TranscriptView()
                    .tabItem {
                        Label("Transcript", systemImage: "text.alignleft")
                    }
                
                AISummaryView()
                    .tabItem {
                        Label("AI", systemImage: "brain")
                    }
            }
            .padding()
        }
    }
}