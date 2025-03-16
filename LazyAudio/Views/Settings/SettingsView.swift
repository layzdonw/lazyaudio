import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    private let languages = ["简体中文", "English", "日本語", "한국어"]
    private let tokenOptions = [1024, 2048, 4096, 8192]
    private let retentionOptions = [
        (label: "settings.retention.7days".localized, value: 7),
        (label: "settings.retention.30days".localized, value: 30),
        (label: "settings.retention.90days".localized, value: 90),
        (label: "settings.retention.forever".localized, value: -1)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                LocalizedText(key: "settings.title", font: .title2.bold())
                
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
                    SettingsSection(title: "settings.general".localized, icon: "paintbrush.fill") {
                        Toggle(isOn: $viewModel.isDarkMode) {
                            Label {
                                LocalizedText(key: "settings.dark_mode")
                            } icon: {
                                Image(systemName: "moon.fill")
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            LocalizedText(key: "settings.font_size")
                            Spacer()
                            Picker("", selection: $viewModel.fontSize) {
                                LocalizedText(key: "settings.font_size.small").tag(0)
                                LocalizedText(key: "settings.font_size.medium").tag(1)
                                LocalizedText(key: "settings.font_size.large").tag(2)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 180)
                        }
                    }
                    
                    // 语言设置
                    SettingsSection(title: "settings.language".localized, icon: "globe") {
                        Picker("", selection: $viewModel.selectedLanguageCode) {
                            ForEach(localizationManager.supportedLanguages, id: \.id) { language in
                                Text(language.displayName).tag(language.rawValue)
                            }
                        }
                        .onChange(of: viewModel.selectedLanguageCode) { newLanguageCode in
                            if let language = Language(rawValue: newLanguageCode) {
                                localizationManager.switchLanguage(to: language)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // 转录模型设置
                    SettingsSection(title: "settings.transcription".localized, icon: "waveform") {
                        LocalizedText(key: "settings.sherpa_config", font: .headline)
                            .padding(.top, 4)
                        
                        HStack {
                            LocalizedText(key: "settings.model_path")
                            Spacer()
                            Text(viewModel.localModelPath.isEmpty ? "settings.not_selected".localized : viewModel.localModelPath)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(maxWidth: 200, alignment: .trailing)
                            
                            Button("settings.choose".localized) {
                                viewModel.selectLocalModelPath()
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                        
                        HStack {
                            LocalizedText(key: "settings.cache_directory")
                            Spacer()
                            Text(viewModel.cacheDirectory.isEmpty ? "settings.default".localized : viewModel.cacheDirectory)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(maxWidth: 200, alignment: .trailing)
                            
                            Button("settings.choose".localized) {
                                viewModel.selectCacheDirectory()
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                    }
                    
                    // AI 增强设置
                    SettingsSection(title: "settings.ai".localized, icon: "brain") {
                        HStack {
                            LocalizedText(key: "settings.ai_model")
                            Spacer()
                            Picker("", selection: $viewModel.selectedAIModel) {
                                Text("GPT-3.5").tag(0)
                                Text("GPT-4").tag(1)
                                Text("Claude").tag(2)
                                Text("Gemini").tag(3)
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Divider()
                        
                        LocalizedText(key: "settings.api_config", font: .headline)
                            .padding(.top, 4)
                        
                        HStack {
                            LocalizedText(key: "settings.api_key")
                            Spacer()
                            SecureField("settings.enter_api_key".localized, text: $viewModel.apiKey)
                                .frame(width: 250)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            LocalizedText(key: "settings.api_base")
                            Spacer()
                            TextField("settings.enter_api_base".localized, text: $viewModel.apiBase)
                                .frame(width: 250)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Divider()
                        
                        LocalizedText(key: "settings.advanced", font: .headline)
                            .padding(.top, 4)
                        
                        HStack {
                            LocalizedText(key: "settings.temperature")
                            Slider(value: $viewModel.modelTemperature, in: 0...1, step: 0.1)
                                .frame(width: 200)
                            Text(String(format: "%.1f", viewModel.modelTemperature))
                                .frame(width: 30)
                        }
                        
                        HStack {
                            LocalizedText(key: "settings.max_tokens")
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
                    SettingsSection(title: "settings.storage".localized, icon: "folder.fill") {
                        HStack {
                            LocalizedText(key: "settings.storage_location")
                            Spacer()
                            Text(viewModel.storagePath.isEmpty ? "settings.default".localized : viewModel.storagePath)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(maxWidth: 200, alignment: .trailing)
                            
                            Button("settings.change".localized) {
                                viewModel.selectStoragePath()
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                        
                        Divider()
                        
                        Toggle(isOn: $viewModel.autoCleanup) {
                            LocalizedText(key: "settings.auto_cleanup")
                        }
                        
                        if viewModel.autoCleanup {
                            HStack {
                                LocalizedText(key: "settings.retention_period")
                                Spacer()
                                Picker("", selection: $viewModel.retentionPeriod) {
                                    ForEach(retentionOptions, id: \.value) { option in
                                        Text(option.label).tag(option.value)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 150)
                            }
                        }
                    }
                    
                    // 关于
                    SettingsSection(title: "settings.about".localized, icon: "info.circle.fill") {
                        HStack {
                            LocalizedText(key: "settings.version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button("settings.check_updates".localized) {
                                viewModel.checkForUpdates()
                            }
                            .buttonStyle(BorderedButtonStyle())
                            
                            Button("settings.privacy_policy".localized) {
                                viewModel.openPrivacyPolicy()
                            }
                            .buttonStyle(BorderedButtonStyle())
                            
                            Button("settings.terms".localized) {
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
        .onAppear {
            // 初始化语言选择
            viewModel.selectedLanguageCode = localizationManager.currentLanguage.rawValue
        }
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