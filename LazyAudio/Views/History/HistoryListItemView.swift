import SwiftUI

/// 历史记录列表项
/// 显示单个历史记录会话
struct HistoryListItemView: View {
    let title: String
    let date: Date
    let duration: TimeInterval
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formattedDuration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(isSelected ? 1 : 0)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack {
        HistoryListItemView(
            title: "会议记录",
            date: Date(),
            duration: 1825,
            isSelected: false,
            onSelect: {}
        )
        
        HistoryListItemView(
            title: "课程笔记",
            date: Date().addingTimeInterval(-86400),
            duration: 3600,
            isSelected: true,
            onSelect: {}
        )
    }
    .padding()
    .frame(width: 300)
} 