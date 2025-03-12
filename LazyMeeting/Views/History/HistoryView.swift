import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @State private var selectedRecording: String? = nil
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // 页面标题
            Text("历史记录")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
            // 搜索栏
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
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            // 历史记录列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredRecordings) { recording in
                        RecordingListItem(
                            recording: recording,
                            isSelected: selectedRecording == recording.id,
                            onSelect: {
                                selectedRecording = recording.id
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .padding(.top, 4)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// 录音状态枚举
enum RecordingStatus {
    case inProgress // 录制中
    case completed  // 已完成
    
    var color: Color {
        switch self {
        case .inProgress: return .red
        case .completed: return .green
        }
    }
    
    var text: String {
        switch self {
        case .inProgress: return "录制中"
        case .completed: return "已完成"
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
    var onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // 标题和状态栏
                HStack(alignment: .center, spacing: 10) {
                    Text(recording.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 录制状态标签
                    Group {
                        if recording.status == .inProgress {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                
                                Text("录制中")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text("已完成")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                
                // 信息行
                HStack(spacing: 16) {
                    // 日期
                    VStack(alignment: .leading, spacing: 2) {
                        Text("日期")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(recording.date)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // 时间
                    VStack(alignment: .leading, spacing: 2) {
                        Text("时间")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(recording.time)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // 时长
                    VStack(alignment: .leading, spacing: 2) {
                        Text("时长")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(recording.duration)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    // 右箭头
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(isSelected ? 1 : 0.6)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HistoryView()
}