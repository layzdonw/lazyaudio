import SwiftUI

/// 主应用布局组件
/// 负责管理三栏式布局结构
struct MainLayout<LeftContent: View, CenterContent: View, RightContent: View>: View {
    let leftContent: LeftContent
    let centerContent: CenterContent
    let rightContent: RightContent
    
    init(
        @ViewBuilder left: () -> LeftContent,
        @ViewBuilder center: () -> CenterContent,
        @ViewBuilder right: () -> RightContent
    ) {
        self.leftContent = left()
        self.centerContent = center()
        self.rightContent = right()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧栏
            leftContent
                .frame(width: 250)
                .background(Color(nsColor: .windowBackgroundColor))
            
            // 分隔线
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // 中间内容区
            centerContent
                .frame(minWidth: 500)
            
            // 分隔线
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // 右侧栏
            rightContent
                .frame(width: 250)
                .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 1080, minHeight: 720)
    }
}

#Preview {
    MainLayout(
        left: { Color.red.opacity(0.3) },
        center: { Color.blue.opacity(0.3) },
        right: { Color.green.opacity(0.3) }
    )
} 