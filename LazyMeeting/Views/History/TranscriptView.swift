import SwiftUI

struct TranscriptView: View {
    var body: some View {
        ScrollView {
            Text("Full transcript text goes here...")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}