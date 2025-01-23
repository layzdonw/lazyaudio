import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Recording View
            RecordingView()
                .tabItem {
                Label("Record", systemImage: "mic")
            }
            .tag(0)
            
            // History View
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}
#Preview {
    ContentView()
}
