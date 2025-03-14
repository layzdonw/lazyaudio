import SwiftUI

struct AudioSourceSelectionView: View {
    @Binding var selectedSource: Int
    @State private var selectedApp = 0
    @State private var useMicrophone = false
    @State private var isSystemAudio = true
    @State private var microphonePermissionGranted = false
    
    private let appOptions = [
        (name: "Zoom", icon: "video.fill"),
        (name: "Microsoft Teams", icon: "person.2.fill"),
        (name: "Webex", icon: "video.badge.plus"),
        (name: "Google Meet", icon: "video.and.waveform"),
        (name: "Safari", icon: "safari"),
        (name: "Chrome", icon: "globe"),
        (name: "其他应用...", icon: "ellipsis.circle")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("选择音频源")
                .font(.headline)
                .foregroundColor(.primary)
            
            // 音频源选择
            HStack(spacing: 12) {
                // 系统音频选项
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSystemAudio ? Color.accentColor.opacity(0.2) : Color(nsColor: .controlBackgroundColor))
                            .frame(width: 140, height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isSystemAudio ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSystemAudio ? 2 : 1)
                            )
                        
                        VStack(spacing: 10) {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 28))
                                .foregroundColor(isSystemAudio ? .accentColor : .secondary)
                            
                            Text("系统音频")
                                .font(.subheadline)
                                .foregroundColor(isSystemAudio ? .primary : .secondary)
                        }
                    }
                    .onTapGesture {
                        isSystemAudio = true
                        selectedSource = 0
                    }
                }
                
                // 应用音频选项
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(!isSystemAudio ? Color.accentColor.opacity(0.2) : Color(nsColor: .controlBackgroundColor))
                            .frame(width: 140, height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(!isSystemAudio ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: !isSystemAudio ? 2 : 1)
                            )
                        
                        VStack(spacing: 10) {
                            Image(systemName: "app.fill")
                                .font(.system(size: 28))
                                .foregroundColor(!isSystemAudio ? .accentColor : .secondary)
                            
                            Text("应用音频")
                                .font(.subheadline)
                                .foregroundColor(!isSystemAudio ? .primary : .secondary)
                        }
                    }
                    .onTapGesture {
                        isSystemAudio = false
                        selectedSource = 1
                    }
                }
            }
            
            // 应用选择部分
            if !isSystemAudio {
                VStack(alignment: .leading, spacing: 10) {
                    Text("选择应用")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                        ForEach(0..<appOptions.count, id: \.self) { index in
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(selectedApp == index ? Color.accentColor.opacity(0.2) : Color(nsColor: .controlBackgroundColor))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedApp == index ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: selectedApp == index ? 2 : 1)
                                        )
                                    
                                    Image(systemName: appOptions[index].icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(selectedApp == index ? .accentColor : .secondary)
                                }
                                
                                Text(appOptions[index].name)
                                    .font(.caption)
                                    .foregroundColor(selectedApp == index ? .primary : .secondary)
                                    .lineLimit(1)
                                    .frame(width: 70)
                            }
                            .onTapGesture {
                                selectedApp = index
                            }
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .cornerRadius(10)
            }
            
            // 麦克风选项 - 只有在用户授予麦克风权限时才显示
            if microphonePermissionGranted {
                Toggle(isOn: $useMicrophone) {
                    HStack(spacing: 10) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                        
                        Text("同时录制麦克风")
                            .font(.subheadline)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(12)
        .onAppear {
            // 从 UserDefaults 中读取麦克风权限状态
            microphonePermissionGranted = UserDefaults.standard.bool(forKey: "microphonePermissionGranted")
        }
    }
}

#Preview {
    AudioSourceSelectionView(selectedSource: .constant(1))
}