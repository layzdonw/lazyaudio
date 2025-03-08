import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @State private var selectedRecording: String? = nil
    
    // 模拟数据
    private let recordings = [
        Recording(id: "1", title: "团队周会", date: "2023-03-01", time: "14:30", duration: "45分钟"),
        Recording(id: "2", title: "产品规划讨论", date: "2023-03-03", time: "10:15", duration: "32分钟"),
        Recording(id: "3", title: "客户访谈", date: "2023-03-05", time: "16:00", duration: "28分钟"),
        Recording(id: "4", title: "技术评审", date: "2023-03-08", time: "11:30", duration: "50分钟"),
        Recording(id: "5", title: "项目启动会", date: "2023-03-10", time: "09:00", duration: "60分钟")
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
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // 历史记录列表
            ScrollView {
                LazyVStack(spacing: 8) {
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
            }
        }
    }
}

struct Recording: Identifiable {
    var id: String
    var title: String
    var date: String
    var time: String
    var duration: String
}

struct RecordingListItem: View {
    var recording: Recording
    var isSelected: Bool
    var onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Label(recording.date, systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label(recording.time, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label(recording.duration, systemImage: "timer")
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
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HistoryView()
}