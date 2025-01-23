import SwiftUI

struct HistoryView: View {
    var body: some View {
        List {
            Section(header: Text("Recordings")) {
                ForEach(0..<5) { _ in
                    NavigationLink {
                        RecordingDetailView()
                    } label: {
                        RecordingListItemView()
                    }
                }
            }
        }
    }
}