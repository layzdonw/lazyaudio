import SwiftUI

struct RecordingControlsView: View {
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "record.circle")
                    .font(.largeTitle)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "stop.circle")
                    .font(.largeTitle)
            }
        }
        .padding()
    }
}