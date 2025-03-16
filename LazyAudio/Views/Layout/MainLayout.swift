import SwiftUI

/// 主应用布局组件
/// 负责管理两栏式布局结构
struct MainLayout<LeftContent: View, CenterContent: View>: View {
    let leftContent: LeftContent
    let centerContent: CenterContent
    
    init(
        @ViewBuilder left: () -> LeftContent,
        @ViewBuilder center: () -> CenterContent
    ) {
        self.leftContent = left()
        self.centerContent = center()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧栏
            leftContent
                .frame(width: 350)
                .background(Color(nsColor: .windowBackgroundColor))
            
            // 分隔线
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // 中间内容区
            centerContent
                .frame(minWidth: 500)
        }
        .frame(minWidth: 800, minHeight: 720)
    }
}

#Preview {
    MainLayout(
        left: { Color.red.opacity(0.3) },
        center: { Color.blue.opacity(0.3) }
    )
} 