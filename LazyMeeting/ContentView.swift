import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 录制视图
            RecordingView()
                .tabItem {
                    Label("录制", systemImage: "mic.circle.fill")
                }
                .tag(0)
            
            // 历史记录视图
            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "clock.fill")
                }
                .tag(1)
        }
        .frame(minWidth: 800, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showSettings = true
                }) {
                    Label("设置", systemImage: "gear")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}
