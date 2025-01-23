import SwiftUI

struct RecordingView: View {
    @State private var selectedAudioSource = 0
    
    var body: some View {
        VStack {
            AudioSourceSelectionView(selectedSource: $selectedAudioSource)
            TranscriptionDisplayView()
            RecordingControlsView()
        }
    }
}

#Preview {
    RecordingView()
}