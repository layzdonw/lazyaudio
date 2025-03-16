import SwiftUI
import AppKit

struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部控制区
            VStack(spacing: 16) {
                // 标题区域
                RecordingHeaderView(isRecording: viewModel.isRecording)
                
                // 音频源选择
                AudioSourceSelectorView(
                    audioSourceType: $viewModel.audioSourceType,
                    selectedApp: $viewModel.selectedApp,
                    useMicrophone: $viewModel.useMicrophone,
                    isRecording: viewModel.isRecording,
                    runningApps: viewModel.runningApps
                )
                
                // 录制控制按钮
                RecordingControlsView(
                    isRecording: $viewModel.isRecording,
                    canStartRecording: viewModel.canStartRecording
                )
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            
            Divider()
            
            // 转录内容显示区
            if viewModel.showTranscription {
                VStack(spacing: 0) {
                    // AI功能区
                    AIFunctionHeaderView()
                    
                    // 转录内容
                    TranscriptionDisplayView(
                        selectedText: $viewModel.selectedText
                    )
                }
            } else {
                EmptyTranscriptionView()
            }
        }
        .onAppear {
            viewModel.loadRunningApps()
        }
    }
}

/// AI功能头部视图
/// 包含AI相关的功能按钮和选项
struct AIFunctionHeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("AI 功能")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                AIFunctionButton(title: "总结", icon: "text.line.first.and.arrowtriangle.forward")
                AIFunctionButton(title: "提取关键点", icon: "list.bullet")
                AIFunctionButton(title: "翻译", icon: "character.book.closed")
                AIFunctionButton(title: "问答", icon: "questionmark.circle")
                Spacer()
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
    }
}

/// AI功能按钮
struct AIFunctionButton: View {
    var title: String
    var icon: String
    
    var body: some View {
        Button(action: {
            // AI功能动作
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.caption)
            }
            .frame(width: 60, height: 50)
        }
        .buttonStyle(.plain)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

/// 空转录视图
/// 当没有转录内容时显示
struct EmptyTranscriptionView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "waveform")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .padding()
            
            Text("开始录制后将在此显示转录内容")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    RecordingView()
}
