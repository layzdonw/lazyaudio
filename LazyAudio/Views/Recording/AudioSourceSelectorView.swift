import SwiftUI
import AppKit

/// 音频源选择组件
/// 用于选择录音的音频源
struct AudioSourceSelectorView: View {
    @Binding var audioSourceType: AudioSourceType
    @Binding var selectedApp: String
    @Binding var useMicrophone: Bool
    let isRecording: Bool
    let runningApps: [AppModels.RunningApp]
    var onAppSourceSelected: (() -> Void)? // 添加一个回调函数，用于刷新应用列表
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 音频源类型选择
            Picker("音频源", selection: $audioSourceType) {
                Text("系统音频").tag(AudioSourceType.systemAudio)
                Text("应用音频").tag(AudioSourceType.appAudio)
                Text("麦克风").tag(AudioSourceType.microphone)
            }
            .pickerStyle(.segmented)
            .disabled(isRecording)
            .onChange(of: audioSourceType) { newValue in
                // 当切换到应用音频时，调用回调函数刷新应用列表
                if newValue == .appAudio {
                    onAppSourceSelected?()
                }
            }
            
            // 应用选择器（仅在应用音频模式下显示）
            if audioSourceType == .appAudio {
                Picker("选择应用", selection: $selectedApp) {
                    Text("请选择应用").tag("")
                    ForEach(runningApps) { app in
                        Text(app.name).tag(app.bundleIdentifier)
                    }
                }
                .pickerStyle(.menu)
                .disabled(isRecording)
            }
            
            // 麦克风选项（仅在系统音频或应用音频模式下显示）
            if audioSourceType == .systemAudio || audioSourceType == .appAudio {
                Toggle("同时录制麦克风", isOn: $useMicrophone)
                    .disabled(isRecording)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    AudioSourceSelectorView(
        audioSourceType: .constant(.systemAudio),
        selectedApp: .constant(""),
        useMicrophone: .constant(false),
        isRecording: false,
        runningApps: []
    )
} 
