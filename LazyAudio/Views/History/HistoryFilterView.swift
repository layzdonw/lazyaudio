import SwiftUI

/// 历史记录过滤类型
enum HistoryFilterType: String, CaseIterable, Identifiable {
    case all = "history.filter.all"
    case today = "history.filter.today"
    case yesterday = "history.filter.yesterday"
    case thisWeek = "history.filter.this_week"
    case thisMonth = "history.filter.this_month"
    
    var id: String { self.rawValue }
    
    var localizedName: String {
        return self.rawValue.localized
    }
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
                
                TextField("history.search".localized, text: $searchText)
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
                            title: filter.localizedName,
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