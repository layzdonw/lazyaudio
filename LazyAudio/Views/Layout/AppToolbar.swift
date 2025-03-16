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
                Label("main.new_session".localized, systemImage: "plus")
            }
        }
        
        ToolbarItem(placement: .automatic) {
            Button(action: {
                isDarkMode.toggle()
            }) {
                Label("main.toggle_theme".localized, systemImage: isDarkMode ? "sun.max" : "moon")
            }
        }
        
        ToolbarItem(placement: .automatic) {
            Button(action: {
                showSettings = true
            }) {
                Label("settings.title".localized, systemImage: "gear")
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