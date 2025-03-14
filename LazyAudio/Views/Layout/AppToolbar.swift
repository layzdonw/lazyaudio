import SwiftUI

/// 应用工具栏组件
/// 包含新建会话、切换主题和设置按钮
struct AppToolbar: ToolbarContent {
    @Binding var isDarkMode: Bool
    @Binding var showSettings: Bool
    @Binding var showNewSession: Bool
    
    var body: some ToolbarContent {
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
}

#Preview {
    VStack {
        Text("工具栏预览")
    }
    .toolbar {
        AppToolbar(
            isDarkMode: .constant(false),
            showSettings: .constant(false),
            showNewSession: .constant(false)
        )
    }
} 