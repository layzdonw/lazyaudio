import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    
    private let languages = ["简体中文", "English", "日本語", "한국어"]
    private let tokenOptions = [1024, 2048, 4096, 8192]
    private let retentionOptions = [
        (label: "7 天", value: 7),
        (label: "30 天", value: 30),
        (label: "90 天", value: 90),
        (label: "永久", value: -1)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("设置")
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
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            // 设置内容
            ScrollView {
                VStack(spacing: 20) {
                    // 外观设置
                    SettingsSection(title: "外观设置", icon: "paintbrush.fill") {
                        Toggle(isOn: $viewModel.isDarkMode) {
                            Label("深色模式", systemImage: "moon.fill")
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("字体大小")
                            Spacer()
                            Picker("", selection: $viewModel.fontSize) {
                                Text("小").tag(0)
                                Text("中").tag(1)
                                Text("大").tag(2)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 180)
                        }
                    }
                    
                    // 语言设置
                    SettingsSection(title: "语言设置", icon: "globe") {
                        Picker("界面语言", selection: $viewModel.selectedLanguage) {
                            ForEach(0..<languages.count, id: \.self) { index in
                                Text(languages[index]).tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // 转录模型设置
                    SettingsSection(title: "转录模型设置", icon: "waveform") {
                        Toggle(isOn: $viewModel.useSherpaOnnx) {
                            Label("使用本地模型 (sherpa-onnx)", systemImage: "cpu")
                        }
                        
                        if viewModel.useSherpaOnnx {
                            Divider()
                            
                            Text("sherpa-onnx 配置")
                                .font(.headline)
                                .padding(.top, 4)
                            
                            HStack {
                                Text("模型路径")
                                Spacer()
                                Text(viewModel.localModelPath.isEmpty ? "未选择" : viewModel.localModelPath)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .frame(maxWidth: 200, alignment: .trailing)
                                
                                Button("选择...") {
                                    viewModel.selectLocalModelPath()
                                }
                                .buttonStyle(BorderedButtonStyle())
                            }
                            
                            HStack {
                                Text("缓存目录")
                                Spacer()
                                Text(viewModel.cacheDirectory.isEmpty ? "默认" : viewModel.cacheDirectory)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .frame(maxWidth: 200, alignment: .trailing)
                                
                                Button("选择...") {
                                    viewModel.selectCacheDirectory()
                                }
                                .buttonStyle(BorderedButtonStyle())
                            }
                        }
                    }
                    
                    // AI 增强设置
                    SettingsSection(title: "AI 增强设置", icon: "brain") {
                        Picker("AI 模型", selection: $viewModel.selectedAIModel) {
                            Text("GPT-3.5").tag(0)
                            Text("GPT-4").tag(1)
                            Text("Claude").tag(2)
                            Text("Gemini").tag(3)
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Divider()
                        
                        Text("API 配置")
                            .font(.headline)
                            .padding(.top, 4)
                        
                        HStack {
                            Text("API 密钥")
                            Spacer()
                            SecureField("输入 API 密钥", text: $viewModel.apiKey)
                                .frame(width: 250)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            Text("API 地址")
                            Spacer()
                            TextField("输入 API 地址", text: $viewModel.apiBase)
                                .frame(width: 250)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Divider()
                        
                        Text("高级设置")
                            .font(.headline)
                            .padding(.top, 4)
                        
                        HStack {
                            Text("温度")
                            Slider(value: $viewModel.modelTemperature, in: 0...1, step: 0.1)
                                .frame(width: 200)
                            Text(String(format: "%.1f", viewModel.modelTemperature))
                                .frame(width: 30)
                        }
                        
                        HStack {
                            Text("最大标记数")
                            Spacer()
                            Picker("", selection: $viewModel.maxTokens) {
                                ForEach(tokenOptions, id: \.self) { option in
                                    Text("\(option)").tag(option)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                        }
                    }
                    
                    // 存储设置
                    SettingsSection(title: "存储设置", icon: "folder.fill") {
                        HStack {
                            Text("存储位置")
                            Spacer()
                            Text(viewModel.storagePath.isEmpty ? "默认" : viewModel.storagePath)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(maxWidth: 200, alignment: .trailing)
                            
                            Button("更改...") {
                                viewModel.selectStoragePath()
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                        
                        Divider()
                        
                        Toggle(isOn: $viewModel.autoCleanup) {
                            Text("自动清理过期录音")
                        }
                        
                        if viewModel.autoCleanup {
                            Picker("保留时间", selection: $viewModel.retentionPeriod) {
                                ForEach(retentionOptions, id: \.value) { option in
                                    Text(option.label).tag(option.value)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    
                    // 关于
                    SettingsSection(title: "关于", icon: "info.circle.fill") {
                        HStack {
                            Text("版本")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button("检查更新") {
                                viewModel.checkForUpdates()
                            }
                            .buttonStyle(BorderedButtonStyle())
                            
                            Button("隐私政策") {
                                viewModel.openPrivacyPolicy()
                            }
                            .buttonStyle(BorderedButtonStyle())
                            
                            Button("使用条款") {
                                viewModel.openTermsOfService()
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 600, height: 700)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct SettingsSection<Content: View>: View {
    var title: String
    var icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .font(.headline)
            }
            
            content
                .padding(.leading, 4)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView()
} 