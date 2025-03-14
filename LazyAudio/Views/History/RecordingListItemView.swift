import SwiftUI

struct RecordingListItemView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recording Title")
                .font(.headline)
            Text("Date and Duration")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}