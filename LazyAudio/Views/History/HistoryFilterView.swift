import SwiftUI

/// 历史记录过滤类型
enum HistoryFilterType: String, CaseIterable, Identifiable {
    case all = "全部"
    case today = "今天"
    case yesterday = "昨天"
    case thisWeek = "本周"
    case thisMonth = "本月"
    
    var id: String { self.rawValue }
}

/// 历史记录过滤器组件
/// 用于筛选历史记录列表
struct HistoryFilterView: View {
    @Binding var selectedFilter: HistoryFilterType
    @Binding var searchText: String
    
    var body: some View {
        VStack(spacing: 12) {
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索历史记录", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            
            // 过滤选项
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(HistoryFilterType.allCases) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter,
                            action: {
                                selectedFilter = filter
                            }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

/// 过滤选项芯片
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HistoryFilterView(
        selectedFilter: .constant(.all),
        searchText: .constant("")
    )
    .padding()
    .frame(width: 300)
} 