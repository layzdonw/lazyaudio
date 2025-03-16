import SwiftUI

struct AIChatView: View {
    @State private var message = ""
    
    var body: some View {
        VStack {
            ScrollView {
                Text("Chat history with AI...")
            }
            
            HStack {
                TextField("Ask AI...", text: $message)
                Button(action: {}) {
                    Image(systemName: "arrow.up.circle")
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}
