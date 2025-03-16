import SwiftUI

/// 音频源选择组件
/// 用于选择录音的音频源
struct AudioSourceSelectorView: View {
    @Binding var audioSourceType: AudioSourceType
    @Binding var selectedApp: String
    @Binding var useMicrophone: Bool
    let isRecording: Bool
    let runningApps: [AppModels.RunningApp]
    
    var body: some View {
        VStack(spacing: 12) {
            // 系统音频和应用音频二选一
            HStack {
                LocalizedText(key: "recording.audio_source", font: .subheadline)
                    .foregroundColor(.secondary)
                
                Picker("", selection: $audioSourceType) {
                    LocalizedText(key: "recording.system_audio").tag(AudioSourceType.systemAudio)
                    LocalizedText(key: "recording.app_audio").tag(AudioSourceType.appAudio)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
                .disabled(isRecording)
                
                if audioSourceType == .appAudio {
                    Picker("", selection: $selectedApp) {
                        LocalizedText(key: "recording.select_app").tag("")
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
                    Label {
                        LocalizedText(key: "recording.use_microphone")
                    } icon: {
                        Image(systemName: "mic.fill")
                    }
                }
                .disabled(isRecording)
                
                Spacer()
            }
        }
    }
}

/// 音频源类型
enum AudioSourceType: Int {
    case systemAudio = 0
    case appAudio = 1
}

#Preview {
    AudioSourceSelectorView(
        audioSourceType: .constant(.systemAudio),
        selectedApp: .constant(""),
        useMicrophone: .constant(false),
        isRecording: false,
        runningApps: AppModels.getRunningApps()
    )
    .padding()
} 
