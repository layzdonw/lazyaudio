import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    @State private var showNewSession = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧栏 - 历史记录和快速导航 (20%宽度)
            VStack {
                Text("历史记录")
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                HistoryView()
            }
            .frame(width: 250)
            .background(Color(nsColor: .windowBackgroundColor))
            
            // 分隔线
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1)
            
            // 中间栏 - 实时转录展示和操作 (60%宽度)
            RecordingView()
                .frame(minWidth: 500)
            
            // 分隔线
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1)
            
            // 右侧栏 - 设置和AI功能 (20%宽度，可折叠)
            VStack {
                Text("AI 功能")
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                // AI功能按钮
                VStack(spacing: 12) {
                    AIFunctionButton(icon: "doc.text", title: "生成摘要")
                    AIFunctionButton(icon: "checklist", title: "生成任务")
                    AIFunctionButton(icon: "square.grid.3x3.square", title: "生成Mindmap")
                    AIFunctionButton(icon: "bubble.left.and.bubble.right", title: "直接Chat")
                }
                .padding()
                
                Spacer()
            }
            .frame(width: 250)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 1080, minHeight: 720)
        .toolbar {
            ToolbarItem(placement: .navigation) {
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
            NewSessionView()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct AIFunctionButton: View {
    var icon: String
    var title: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
