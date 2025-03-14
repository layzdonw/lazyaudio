import SwiftUI

/// AI功能视图
/// 展示所有可用的AI功能按钮
struct AIFunctionView: View {
    var body: some View {
        VStack(spacing: 12) {
            AIFunctionButton(icon: "doc.text", title: "生成摘要")
            AIFunctionButton(icon: "checklist", title: "生成任务")
            AIFunctionButton(icon: "square.grid.3x3.square", title: "生成Mindmap")
            AIFunctionButton(icon: "bubble.left.and.bubble.right", title: "直接Chat")
        }
        .padding()
    }
}

/// AI功能按钮
/// 用于展示单个AI功能
struct AIFunctionButton: View {
    var icon: String
    var title: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
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
    AIFunctionView()
        .frame(width: 250)
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
} 