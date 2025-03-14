import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    @State private var showNewSession = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        MainLayout(
            left: {
                // 左侧栏 - 历史记录和快速导航
                SidebarView(title: "历史记录") {
                    HistoryView()
                }
            },
            center: {
                // 中间栏 - 实时转录展示和操作
                RecordingView()
            },
            right: {
                // 右侧栏 - 设置和AI功能
                SidebarView(title: "AI 功能") {
                    AIFunctionView()
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showNewSession = true
                }) {
                    Label("新建", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isDarkMode.toggle()
                }) {
                    Label("切换模式", systemImage: isDarkMode ? "sun.max" : "moon")
                }
            }
            
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
        .sheet(isPresented: $showNewSession) {
            TempNewSessionView()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

/// 新建会话视图
/// 临时占位组件，需要实现具体功能
struct TempNewSessionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("新建会话")
                .font(.title)
                .padding()
            
            Button("关闭") {
                dismiss()
            }
            .padding()
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    ContentView()
}
