import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    private let languages = ["简体中文", "English", "日本語", "한국어"]
    private let models = ["GPT-3.5", "GPT-4", "Claude", "Gemini", "本地模型"]
    private let tokenOptions = [1024, 2048, 4096, 8192]
    private let retentionOptions = [
        (label: "7 天", value: 7),
        (label: "30 天", value: 30),
        (label: "90 天", value: 90),
        (label: "永久", value: -1)
    ]
    
    var body: some View {
        NavigationView {
            List {
                // 外观设置
                Section(header: Text("外观设置")) {
                    Toggle(isOn: $viewModel.isDarkMode) {
                        Label("深色模式", systemImage: "moon.fill")
                    }
                }
                
                // 语言设置
                Section(header: Text("语言设置")) {
                    Picker("界面语言", selection: $viewModel.selectedLanguage) {
                        ForEach(0..<languages.count, id: \.self) { index in
                            Text(languages[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // AI 模型设置
                Section(header: Text("AI 模型设置")) {
                    Picker("转录模型", selection: $viewModel.selectedModel) {
                        ForEach(0..<models.count, id: \.self) { index in
                            Text(models[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    if viewModel.selectedModel == 4 { // 本地模型
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
                    } else {
                        HStack {
                            Text("API 密钥")
                            Spacer()
                            SecureField("输入 API 密钥", text: $viewModel.apiKey)
                                .frame(width: 200)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("高级设置")
                            .font(.headline)
                        
                        HStack {
                            Text("温度")
                            Slider(value: $viewModel.modelTemperature, in: 0...1, step: 0.1)
                                .frame(width: 200)
                            Text(String(format: "%.1f", viewModel.modelTemperature))
                                .frame(width: 30)
                        }
                        
                        HStack {
                            Text("最大标记数")
                            Picker("", selection: $viewModel.maxTokens) {
                                ForEach(tokenOptions, id: \.self) { option in
                                    Text("\(option)").tag(option)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 存储设置
                Section(header: Text("存储设置")) {
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
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("检查更新") {
                        viewModel.checkForUpdates()
                    }
                    
                    Button("隐私政策") {
                        viewModel.openPrivacyPolicy()
                    }
                    
                    Button("使用条款") {
                        viewModel.openTermsOfService()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 600)
    }
}

#Preview {
    SettingsView()
} 