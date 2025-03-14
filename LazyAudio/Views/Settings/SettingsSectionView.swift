import SwiftUI

/// 设置部分组件
/// 用于显示设置中的一个部分，包含标题和内容
struct SettingsSectionView<Content: View>: View {
    let title: String
    let iconName: String
    let content: Content
    
    init(title: String, iconName: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.iconName = iconName
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .font(.headline)
            }
            
            // 内容
            content
                .padding(.leading, 24)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    SettingsSectionView(title: "通用设置", iconName: "gear") {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("启用深色模式", isOn: .constant(true))
            Toggle("自动保存录音", isOn: .constant(false))
        }
    }
    .padding()
    .frame(width: 400)
} 