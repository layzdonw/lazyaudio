import SwiftUI

/// 通用侧边栏组件
/// 用于展示左侧或右侧的内容面板
struct SidebarView<Content: View>: View {
    let titleKey: String
    let content: Content
    let showTitle: Bool
    
    init(titleKey: String, showTitle: Bool = true, @ViewBuilder content: () -> Content) {
        self.titleKey = titleKey
        self.showTitle = showTitle
        self.content = content()
    }
    
    var body: some View {
        VStack {
            if showTitle {
                LocalizedText(key: titleKey, font: .headline)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
            }
            
            content
            
            Spacer()
        }
    }
}

#Preview {
    VStack {
        SidebarView(titleKey: "history.title") {
            Text("带标题的侧边栏")
        }
        .frame(width: 250, height: 250)
        
        SidebarView(titleKey: "history.title", showTitle: false) {
            Text("无标题的侧边栏")
        }
        .frame(width: 250, height: 250)
    }
    .background(Color(nsColor: .windowBackgroundColor))
} 