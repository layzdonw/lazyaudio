import SwiftUI

/// 通用侧边栏组件
/// 用于展示左侧或右侧的内容面板
struct SidebarView<Content: View>: View {
    let titleKey: String
    let content: Content
    
    init(titleKey: String, @ViewBuilder content: () -> Content) {
        self.titleKey = titleKey
        self.content = content()
    }
    
    var body: some View {
        VStack {
            LocalizedText(key: titleKey, font: .headline)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            content
            
            Spacer()
        }
    }
}

#Preview {
    SidebarView(titleKey: "history.title") {
        Text("侧边栏内容")
    }
    .frame(width: 250, height: 500)
    .background(Color(nsColor: .windowBackgroundColor))
} 