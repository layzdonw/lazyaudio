import SwiftUI
import AppKit

struct NewSessionView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var sessionName: String = ""
    @State private var audioSourceType: AudioSourceType = .systemAudio
    @State private var useMicrophone: Bool = false
    @State private var selectedApp: String = ""
    @State private var selectedLanguage: Int = 0
    @State private var runningApps: [AppModels.RunningApp] = []
    
    private let languages = ["简体中文", "English", "日本語", "한국어"]
    
    enum AudioSourceType: Int {
        case systemAudio = 0
        case appAudio = 1
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // 标题
            HStack {
                Text("新建录制会话")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 会话名称
            VStack(alignment: .leading, spacing: 8) {
                Text("会话名称")
                    .font(.headline)
                
                TextField("输入会话名称", text: $sessionName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // 音频源选择
            VStack(alignment: .leading, spacing: 12) {
                Text("音频源")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    // 系统音频和应用音频二选一
                    Picker("音频类型", selection: $audioSourceType) {
                        Text("系统音频").tag(AudioSourceType.systemAudio)
                        Text("应用音频").tag(AudioSourceType.appAudio)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 8)
                    
                    // 如果选择应用音频，显示应用选择器
                    if audioSourceType == .appAudio {
                        HStack {
                            Text("选择应用")
                            
                            Spacer()
                            
                            Picker("", selection: $selectedApp) {
                                Text("请选择应用").tag("")
                                ForEach(runningApps) { app in
                                    Text(app.name).tag(app.bundleIdentifier)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 200)
                            .onChange(of: audioSourceType) { _ in
                                if audioSourceType == .appAudio && runningApps.isEmpty {
                                    runningApps = AppModels.getRunningApps()
                                }
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // 麦克风选项（独立选项）
                    Toggle(isOn: $useMicrophone) {
                        Label("同时录制麦克风", systemImage: "mic.fill")
                    }
                }
                .padding(.leading, 4)
            }
            
            // 语言选择
            VStack(alignment: .leading, spacing: 8) {
                Text("转录语言")
                    .font(.headline)
                
                Picker("", selection: $selectedLanguage) {
                    ForEach(0..<languages.count, id: \.self) { index in
                        Text(languages[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Spacer()
            
            // 按钮
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("取消")
                        .frame(width: 100)
                }
                .buttonStyle(BorderedButtonStyle())
                
                Spacer()
                
                Button(action: {
                    // 创建新会话
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("开始录制")
                        .frame(width: 100)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.vertical, 8)
                .background(Color.accentColor)
                .cornerRadius(8)
                .disabled(sessionName.isEmpty || (audioSourceType == .appAudio && selectedApp.isEmpty))
            }
        }
        .padding(24)
        .frame(width: 500, height: 400)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            if audioSourceType == .appAudio {
                runningApps = AppModels.getRunningApps()
            }
        }
    }
}

#Preview {
    NewSessionView()
} 