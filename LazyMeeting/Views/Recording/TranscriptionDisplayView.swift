import SwiftUI

struct TranscriptionDisplayView: View {
    var body: some View {
        ScrollView {
            Text("Real-time transcription will appear here...")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(8)
        .padding()
    }
}