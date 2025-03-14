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
                TranscriptionDisplayView(
                    selectedText: $viewModel.selectedText
                )
            } else {
                EmptyTranscriptionView()
            }
        }
        .onAppear {
            viewModel.loadRunningApps()
        }
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