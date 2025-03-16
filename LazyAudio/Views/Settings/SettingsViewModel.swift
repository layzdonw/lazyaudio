import SwiftUI
import Combine
import Foundation
import AppKit

class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var selectedLanguageCode: String = "en"
    @Published var useSherpaOnnx: Bool = false
    @Published var selectedAIModel: Int = 0
    @Published var apiKey: String = ""
    @Published var apiBase: String = "https://api.openai.com/v1"
    @Published var localModelPath: String = ""
    @Published var cacheDirectory: String = ""
    @Published var modelTemperature: Double = 0.7
    @Published var maxTokens: Int = 2048
    @Published var storagePath: String = ""
    @Published var autoCleanup: Bool = true
    @Published var retentionPeriod: Int = 30
    @Published var fontSize: Int = 1 // 0: 小, 1: 中, 2: 大
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        
        // 监听语言变化通知
        NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))
            .sink { [weak self] _ in
                self?.saveSettings()
            }
            .store(in: &cancellables)
    }
    
    private func updateAppearance() {
        // 在实际应用中，这里需要实现深色模式切换逻辑
        // 由于 SwiftUI 的限制，可能需要通过 AppDelegate 或其他方式实现
    }
    
    func selectLocalModelPath() {
        let openPanel = NSOpenPanel()
        openPanel.title = "选择模型文件".localized
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["onnx"]
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                self.localModelPath = url.path
            }
        }
    }
    
    func selectCacheDirectory() {
        let openPanel = NSOpenPanel()
        openPanel.title = "选择缓存目录".localized
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                self.cacheDirectory = url.path
            }
        }
    }
    
    func selectStoragePath() {
        let openPanel = NSOpenPanel()
        openPanel.title = "选择存储位置".localized
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                self.storagePath = url.path
            }
        }
    }
    
    func checkForUpdates() {
        // 模拟检查更新
        print("检查更新...")
    }
    
    func openPrivacyPolicy() {
        if let url = URL(string: "https://example.com/privacy") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func openTermsOfService() {
        if let url = URL(string: "https://example.com/terms") {
            NSWorkspace.shared.open(url)
        }
    }
    
    // 保存设置
    func saveSettings() {
        // 这里实现保存设置到UserDefaults或其他存储
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        UserDefaults.standard.set(selectedLanguageCode, forKey: "selectedLanguageCode")
        UserDefaults.standard.set(useSherpaOnnx, forKey: "useSherpaOnnx")
        UserDefaults.standard.set(selectedAIModel, forKey: "selectedAIModel")
        UserDefaults.standard.set(apiKey, forKey: "apiKey")
        UserDefaults.standard.set(apiBase, forKey: "apiBase")
        UserDefaults.standard.set(localModelPath, forKey: "localModelPath")
        UserDefaults.standard.set(cacheDirectory, forKey: "cacheDirectory")
        UserDefaults.standard.set(modelTemperature, forKey: "modelTemperature")
        UserDefaults.standard.set(maxTokens, forKey: "maxTokens")
        UserDefaults.standard.set(storagePath, forKey: "storagePath")
        UserDefaults.standard.set(autoCleanup, forKey: "autoCleanup")
        UserDefaults.standard.set(retentionPeriod, forKey: "retentionPeriod")
        UserDefaults.standard.set(fontSize, forKey: "fontSize")
    }
    
    // 加载设置
    func loadSettings() {
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        selectedLanguageCode = UserDefaults.standard.string(forKey: "selectedLanguageCode") ?? LocalizationManager.shared.currentLanguage.rawValue
        useSherpaOnnx = UserDefaults.standard.bool(forKey: "useSherpaOnnx")
        selectedAIModel = UserDefaults.standard.integer(forKey: "selectedAIModel")
        apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        apiBase = UserDefaults.standard.string(forKey: "apiBase") ?? "https://api.openai.com/v1"
        localModelPath = UserDefaults.standard.string(forKey: "localModelPath") ?? ""
        cacheDirectory = UserDefaults.standard.string(forKey: "cacheDirectory") ?? ""
        modelTemperature = UserDefaults.standard.double(forKey: "modelTemperature")
        if modelTemperature == 0 { modelTemperature = 0.7 } // 默认值
        maxTokens = UserDefaults.standard.integer(forKey: "maxTokens")
        if maxTokens == 0 { maxTokens = 2048 } // 默认值
        storagePath = UserDefaults.standard.string(forKey: "storagePath") ?? ""
        autoCleanup = UserDefaults.standard.bool(forKey: "autoCleanup")
        retentionPeriod = UserDefaults.standard.integer(forKey: "retentionPeriod")
        if retentionPeriod == 0 { retentionPeriod = 30 } // 默认值
        fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        if fontSize == 0 { fontSize = 1 } // 默认为中等大小
    }
} 