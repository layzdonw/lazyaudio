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
                    runningApps: viewModel.runningApps,
                    onAppSourceSelected: {
                        viewModel.loadRunningApps()
                    }
                )
                
                // 录制控制按钮
                RecordingControlsView(
                    isRecording: Binding(
                        get: { viewModel.isRecording },
                        set: { _ in viewModel.toggleRecording() }
                    ),
                    canStartRecording: viewModel.canStartRecording
                )
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            
            Divider()
            
            // 转录内容显示区
            if viewModel.isRecording {
                VStack(spacing: 0) {
                    // 转录内容
                    TranscriptionDisplayView(
                        selectedText: .constant("正在录制...")
                    )
                }
            } else {
                EmptyTranscriptionView()
            }
        }
        .onAppear {
            viewModel.loadRunningApps()
        }
        .alert("录制错误", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("确定") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
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
