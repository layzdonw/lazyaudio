import SwiftUI

struct AudioSourceSelectionView: View {
    @Binding var selectedSource: Int
    @State private var selectedApp = 0
    @State private var useMicrophone = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("音频源设置")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                Picker("音频源", selection: $selectedSource) {
                    Label("系统音频", systemImage: "speaker.wave.3")
                        .tag(0)
                    Label("应用音频", systemImage: "app")
                        .tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 4)
                
                if selectedSource == 1 {
                    HStack(spacing: 12) {
                        Text("选择应用:")
                            .foregroundColor(.secondary)
                        
                        Menu {
                            Button("Zoom") { selectedApp = 0 }
                            Button("Microsoft Teams") { selectedApp = 1 }
                            Button("Webex") { selectedApp = 2 }
                            Button("Google Meet") { selectedApp = 3 }
                            Divider()
                            Button("其他应用...") { selectedApp = 4 }
                        } label: {
                            HStack {
                                Text(getAppName())
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .frame(minWidth: 180)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(6)
                        }
                    }
                }
                
                Toggle(isOn: $useMicrophone) {
                    Label("同时录制麦克风", systemImage: "mic")
                }
                .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                .padding(.top, 4)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding()
    }
    
    private func getAppName() -> String {
        switch selectedApp {
        case 0: return "Zoom"
        case 1: return "Microsoft Teams"
        case 2: return "Webex"
        case 3: return "Google Meet"
        case 4: return "选择其他应用..."
        default: return "选择应用"
        }
    }
}

#Preview {
    AudioSourceSelectionView(selectedSource: .constant(1))
}