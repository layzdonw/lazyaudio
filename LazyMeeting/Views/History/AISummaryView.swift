import SwiftUI

struct AISummaryView: View {
    @State private var chatMessage = ""
    
    var body: some View {
        VStack {
            Text("AI Summary")
                .font(.title)
                .padding()
            
            Text("Summary of the transcript will appear here...")
                .padding()
            
            Spacer()
            
            AIChatView()
        }
    }
}