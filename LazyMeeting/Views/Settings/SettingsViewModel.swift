import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            updateAppearance()
        }
    }
    
    @Published var selectedLanguage: Int {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        }
    }
    
    @Published var selectedModel: Int {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "selectedModel")
        }
    }
    
    @Published var apiKey: String {
        didSet {
            // 在实际应用中，应该安全地存储 API 密钥，例如使用钥匙串
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
        }
    }
    
    @Published var modelTemperature: Double {
        didSet {
            UserDefaults.standard.set(modelTemperature, forKey: "modelTemperature")
        }
    }
    
    @Published var maxTokens: Int {
        didSet {
            UserDefaults.standard.set(maxTokens, forKey: "maxTokens")
        }
    }
    
    @Published var localModelPath: String {
        didSet {
            UserDefaults.standard.set(localModelPath, forKey: "localModelPath")
        }
    }
    
    @Published var storagePath: String {
        didSet {
            UserDefaults.standard.set(storagePath, forKey: "storagePath")
        }
    }
    
    @Published var autoCleanup: Bool {
        didSet {
            UserDefaults.standard.set(autoCleanup, forKey: "autoCleanup")
        }
    }
    
    @Published var retentionPeriod: Int {
        didSet {
            UserDefaults.standard.set(retentionPeriod, forKey: "retentionPeriod")
        }
    }
    
    init() {
        // 从 UserDefaults 加载设置
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.selectedLanguage = UserDefaults.standard.integer(forKey: "selectedLanguage")
        self.selectedModel = UserDefaults.standard.integer(forKey: "selectedModel")
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        self.modelTemperature = UserDefaults.standard.double(forKey: "modelTemperature")
        self.maxTokens = UserDefaults.standard.integer(forKey: "maxTokens")
        self.localModelPath = UserDefaults.standard.string(forKey: "localModelPath") ?? ""
        self.storagePath = UserDefaults.standard.string(forKey: "storagePath") ?? ""
        self.autoCleanup = UserDefaults.standard.bool(forKey: "autoCleanup")
        self.retentionPeriod = UserDefaults.standard.integer(forKey: "retentionPeriod")
        
        // 设置默认值
        if self.modelTemperature == 0 {
            self.modelTemperature = 0.7
        }
        
        if self.maxTokens == 0 {
            self.maxTokens = 4096
        }
        
        if self.retentionPeriod == 0 {
            self.retentionPeriod = 30
        }
        
        // 初始化时应用当前的外观设置
        updateAppearance()
    }
    
    private func updateAppearance() {
        // 在实际应用中，这里需要实现深色模式切换逻辑
        // 由于 SwiftUI 的限制，可能需要通过 AppDelegate 或其他方式实现
    }
    
    func selectLocalModelPath() {
        // 在实际应用中，这里应该打开文件选择器
        // 由于 SwiftUI 的限制，可能需要通过 NSOpenPanel 实现
    }
    
    func selectStoragePath() {
        // 在实际应用中，这里应该打开文件夹选择器
    }
    
    func checkForUpdates() {
        // 检查更新逻辑
    }
    
    func openPrivacyPolicy() {
        // 打开隐私政策
        if let url = URL(string: "https://example.com/privacy") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func openTermsOfService() {
        // 打开使用条款
        if let url = URL(string: "https://example.com/terms") {
            NSWorkspace.shared.open(url)
        }
    }
} 