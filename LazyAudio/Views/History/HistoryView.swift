import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @State private var selectedRecording: String? = nil
    @State private var isHovering: String? = nil
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedFilter: HistoryFilterType = .all
    
    // 模拟数据
    private let recordings = [
        Recording(id: "1", title: "团队周会", date: "2023-03-01", time: "14:30", duration: "45分钟", status: .completed),
        Recording(id: "2", title: "产品规划讨论", date: "2023-03-03", time: "10:15", duration: "32分钟", status: .completed),
        Recording(id: "3", title: "客户访谈", date: "2023-03-05", time: "16:00", duration: "28分钟", status: .inProgress),
        Recording(id: "4", title: "技术评审", date: "2023-03-08", time: "11:30", duration: "50分钟", status: .completed),
        Recording(id: "5", title: "项目启动会", date: "2023-03-10", time: "09:00", duration: "60分钟", status: .completed)
    ]
    
    var filteredRecordings: [Recording] {
        if searchText.isEmpty {
            return recordings
        } else {
            return recordings.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(nsColor: .windowBackgroundColor) : Color(white: 0.97)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 页面标题和搜索栏
            VStack(spacing: 16) {
                // 页面标题
                HStack {
                    LocalizedText(key: "history.title", font: .system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // 右上角的筛选按钮
                    Button(action: {
                        // 筛选逻辑
                    }) {
                        HStack(spacing: 6) {
                            LocalizedText(key: selectedFilter.rawValue, font: .system(size: 14, weight: .medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.primary.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.primary.opacity(0.06))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 搜索栏
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("history.search".localized, text: $searchText)
                        .font(.system(size: 15))
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // 分割线
            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 1)
                .padding(.horizontal, 24)
            
            // 过滤选项栏
            HistoryFilterView(selectedFilter: $selectedFilter, searchText: $searchText)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            
            // 历史记录列表
            ScrollView {
                if filteredRecordings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        LocalizedText(key: "history.no_results", font: .system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredRecordings) { recording in
                            RecordingListItem(
                                recording: recording,
                                isSelected: selectedRecording == recording.id,
                                isHovering: isHovering == recording.id,
                                onSelect: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedRecording = recording.id
                                    }
                                },
                                onHover: { isHovering in
                                    self.isHovering = isHovering ? recording.id : nil
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
            .background(backgroundColor)
        }
        .background(backgroundColor)
    }
}

// 录音状态枚举
enum RecordingStatus {
    case inProgress // 录制中
    case completed  // 已完成
    
    var color: Color {
        switch self {
        case .inProgress: return Color(red: 0.9, green: 0.3, blue: 0.3)
        case .completed: return Color(red: 0.2, green: 0.8, blue: 0.4)
        }
    }
    
    var text: String {
        switch self {
        case .inProgress: return "录制中"
        case .completed: return "已完成"
        }
    }
    
    var icon: String {
        switch self {
        case .inProgress: return "record.circle"
        case .completed: return "checkmark.circle"
        }
    }
}

struct Recording: Identifiable {
    var id: String
    var title: String
    var date: String
    var time: String
    var duration: String
    var status: RecordingStatus
}

struct RecordingListItem: View {
    var recording: Recording
    var isSelected: Bool
    var isHovering: Bool
    var onSelect: () -> Void
    var onHover: (Bool) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var cardBackground: Color {
        if isSelected {
            return Color.accentColor.opacity(0.15)
        } else if isHovering {
            return colorScheme == .dark ? Color(white: 0.2) : Color.white
        } else {
            return colorScheme == .dark ? Color(white: 0.15) : Color.white
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // 左侧状态指示器
                Circle()
                    .fill(recording.status.color)
                    .frame(width: 8, height: 8)
                    .opacity(recording.status == .inProgress ? 1 : 0)
                
                // 主要内容
                VStack(alignment: .leading, spacing: 6) {
                    // 第一行：会话名称和状态
                    HStack {
                        // 会话名称（可能超长）
                        Text(recording.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .help(recording.title) // 悬停时显示完整标题
                        
                        Spacer()
                        
                        // 状态标签
                        if recording.status == .inProgress {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(recording.status.color)
                                    .frame(width: 6, height: 6)
                                
                                Text(recording.status.text)
                                    .font(.system(size: 12))
                                    .foregroundColor(recording.status.color)
                            }
                        } else {
                            Text(recording.status.text)
                                .font(.system(size: 12))
                                .foregroundColor(recording.status.color)
                        }
                    }
                    
                    // 第二行：录制时间和时长
                    HStack(spacing: 16) {
                        // 日期和时间
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Text("\(recording.date) \(recording.time)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .help("\(recording.date) \(recording.time)") // 悬停时显示完整日期时间
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 时长
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Text(recording.duration)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .help(recording.duration) // 悬停时显示完整时长
                        }
                    }
                }
                .padding(.leading, 4)
                
                // 右侧箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .accentColor : .secondary.opacity(0.5))
                    .opacity(isHovering || isSelected ? 1 : 0.6)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackground)
                    .shadow(color: Color.black.opacity(isHovering || isSelected ? 0.08 : 0.04), radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover(perform: { hovering in
            onHover(hovering)
        })
    }
}

// 悬停检测扩展
extension View {
    func onHover(_ perform: @escaping (Bool) -> Void) -> some View {
        #if os(macOS)
        return self.onHover(perform: perform)
        #else
        return self // iOS doesn't have onHover
        #endif
    }
}

#Preview {
    HistoryView()
}