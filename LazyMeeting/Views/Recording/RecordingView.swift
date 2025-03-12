import SwiftUI
import AppKit

struct RecordingView: View {
    @State private var audioSourceType: AudioSourceType = .systemAudio
    @State private var selectedApp: String = ""
    @State private var useMicrophone: Bool = false
    @State private var isRecording = false
    @State private var showTranscription = false
    @State private var selectedText: String? = nil
    @State private var runningApps: [AppModels.RunningApp] = []
    
    enum AudioSourceType: Int {
        case systemAudio = 0
        case appAudio = 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部控制区
            VStack(spacing: 16) {
                // 标题区域
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("实时转录")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("选择音频源并开始录制")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 录制状态
                    if isRecording {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("录制中")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        )
                    }
                }
                
                // 音频源选择
                VStack(spacing: 12) {
                    // 系统音频和应用音频二选一
                    HStack {
                        Text("音频源:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $audioSourceType) {
                            Text("系统音频").tag(AudioSourceType.systemAudio)
                            Text("应用音频").tag(AudioSourceType.appAudio)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 200)
                        .disabled(isRecording)
                        
                        if audioSourceType == .appAudio {
                            Picker("", selection: $selectedApp) {
                                Text("选择应用").tag("")
                                ForEach(runningApps) { app in
                                    Text(app.name).tag(app.bundleIdentifier)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 200)
                            .disabled(isRecording)
                        }
                        
                        Spacer()
                    }
                    
                    // 麦克风选项（独立选项）
                    HStack {
                        Toggle(isOn: $useMicrophone) {
                            Label("同时录制麦克风", systemImage: "mic.fill")
                        }
                        .disabled(isRecording)
                        
                        Spacer()
                        
                        // 录制按钮
                        Button(action: {
                            if audioSourceType == .appAudio && selectedApp.isEmpty && !isRecording {
                                return // 如果选择了应用音频但没有选择具体应用，则不允许开始录制
                            }
                            isRecording.toggle()
                            showTranscription = isRecording
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: isRecording ? "stop.fill" : "record.circle.fill")
                                    .font(.system(size: 16))
                                
                                Text(isRecording ? "停止录制" : "开始录制")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(isRecording ? Color.red : Color.accentColor)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(audioSourceType == .appAudio && selectedApp.isEmpty && !isRecording)
                    }
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            
            // 分隔线
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            // 转录内容区域
            if showTranscription {
                VStack(spacing: 0) {
                    // 工具栏
                    HStack {
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Label("翻译", systemImage: "globe")
                            }
                            .buttonStyle(BorderedButtonStyle())
                            
                            Button(action: {}) {
                                Label("复制", systemImage: "doc.on.doc")
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Label("导出", systemImage: "arrow.down.doc")
                            }
                            .buttonStyle(BorderedButtonStyle())
                            
                            Button(action: {}) {
                                Label("清除", systemImage: "trash")
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                    
                    // 分隔线
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                    
                    // 文本内容
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(0..<10, id: \.self) { index in
                                TranscriptionItem(
                                    timestamp: "13:45:\(index * 5)",
                                    text: "这是一段示例转录文本，显示了实时转录的效果。这是第 \(index + 1) 段文本。",
                                    isSelected: selectedText == "text-\(index)",
                                    onSelect: {
                                        selectedText = "text-\(index)"
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            } else {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        Text("开始录制后，转录内容将在这里显示")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            // 在视图出现时加载运行中的应用列表
            loadRunningApps()
        }
        .onChange(of: audioSourceType) { _ in
            // 当音频源类型变更时，如果是应用音频则重新加载应用列表
            if audioSourceType == .appAudio {
                loadRunningApps()
            }
        }
    }
    
    // 加载运行中的应用列表
    private func loadRunningApps() {
        // 清空现有列表并重新获取
        runningApps = []
        DispatchQueue.main.async {
            runningApps = AppModels.getRunningApps()
            
            // 如果列表为空，再尝试一次
            if runningApps.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    runningApps = AppModels.getRunningApps()
                }
            }
        }
    }
}

struct AudioSourceButton: View {
    var title: String
    var icon: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : .accentColor)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? Color.accentColor : Color.accentColor.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TranscriptionItem: View {
    var timestamp: String
    var text: String
    var isSelected: Bool
    var onSelect: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("[\(timestamp)]")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
            
            Button(action: {}) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
            }
            .buttonStyle(PlainButtonStyle())
            .help("AI解析")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .onTapGesture {
            onSelect()
        }
    }
}

#Preview {
    RecordingView()
}