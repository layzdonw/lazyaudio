import SwiftUI
import Combine
import Foundation
import AppKit

class SettingsViewModel: ObservableObject {
    // 通用设置
    @Published var isDarkMode: Bool = false
    @Published var selectedLanguageCode: String = "en"
    @Published var fontSize: Int = 1 // 0: 小, 1: 中, 2: 大
    
    // 转录设置
    @Published var localModelPath: String = ""
    @Published var cacheDirectory: String = ""
    
    // AI 设置
    @Published var selectedAIModel: Int = 0
    @Published var apiKey: String = ""
    @Published var apiBase: String = "https://api.openai.com/v1"
    @Published var modelTemperature: Double = 0.7
    @Published var maxTokens: Int = 2048
    
    // 存储设置
    @Published var storagePath: String = ""
    @Published var autoCleanup: Bool = true
    @Published var retentionPeriod: Int = 30
    
    // 错误处理
    @Published var showError: Bool = false
    @Published var errorMessage: String? = nil
    
    // 状态跟踪
    @Published var isChangingDirectory: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    let settingsService: SettingsServiceProtocol
    
    init(settingsService: SettingsServiceProtocol = SettingsService()) {
        self.settingsService = settingsService
        loadSettings()
        
        // 监听语言变化通知
        NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))
            .sink { [weak self] _ in
                self?.saveSelectedLanguage()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 设置加载
    
    func loadSettings() {
        isDarkMode = settingsService.isDarkMode
        selectedLanguageCode = settingsService.selectedLanguageCode
        fontSize = settingsService.fontSize
        
        localModelPath = settingsService.localModelPath?.path ?? ""
        cacheDirectory = settingsService.cacheDirectory?.path ?? ""
        
        selectedAIModel = settingsService.selectedAIModel
        apiKey = settingsService.apiKey
        apiBase = settingsService.apiBase
        modelTemperature = settingsService.modelTemperature
        maxTokens = settingsService.maxTokens
        
        storagePath = settingsService.storagePath?.path ?? ""
        autoCleanup = settingsService.autoCleanup
        retentionPeriod = settingsService.retentionPeriod
        
        // 验证存储路径是否生效
        print("当前存储路径: \(storagePath)")
        print("实际存储路径: \(settingsService.storagePath?.path ?? "未设置")")
        print("录音文件目录: \(settingsService.recordingsDirectory.path)")
    }
    
    // MARK: - 设置保存
    
    private func saveSelectedLanguage() {
        settingsService.setLanguage(selectedLanguageCode)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    // MARK: - 文件选择
    
    func selectLocalModelPath() {
        let openPanel = NSOpenPanel()
        openPanel.title = "选择模型文件".localized
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["onnx"]
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            isChangingDirectory = true
            settingsService.setLocalModelPath(url)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    self.isChangingDirectory = false
                    
                    if case .failure(let error) = completion {
                        self.showError(message: error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    self?.localModelPath = url.path
                }
                .store(in: &cancellables)
        }
    }
    
    func selectCacheDirectory() {
        let openPanel = NSOpenPanel()
        openPanel.title = "选择缓存目录".localized
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            isChangingDirectory = true
            settingsService.setCacheDirectory(url)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    self.isChangingDirectory = false
                    
                    if case .failure(let error) = completion {
                        self.showError(message: error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    self?.cacheDirectory = url.path
                }
                .store(in: &cancellables)
        }
    }
    
    func selectStoragePath() {
        let openPanel = NSOpenPanel()
        openPanel.title = "选择存储位置".localized
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            isChangingDirectory = true
            settingsService.setStoragePath(url)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    self.isChangingDirectory = false
                    
                    if case .failure(let error) = completion {
                        self.showError(message: error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    self?.storagePath = url.path
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: - 设置更新
    
    func updateDarkMode() {
        settingsService.setDarkMode(isDarkMode)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func updateFontSize() {
        settingsService.setFontSize(fontSize)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func updateAIModel() {
        settingsService.setAIModel(selectedAIModel)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func updateAPIKey() {
        settingsService.setAPIKey(apiKey)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func updateAPIBase() {
        settingsService.setAPIBase(apiBase)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func updateModelTemperature() {
        settingsService.setModelTemperature(modelTemperature)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func updateMaxTokens() {
        settingsService.setMaxTokens(maxTokens)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func updateAutoCleanup() {
        settingsService.setAutoCleanup(autoCleanup)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func updateRetentionPeriod() {
        settingsService.setRetentionPeriod(retentionPeriod)
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func updateStoragePath() {
        if !storagePath.isEmpty, let url = URL(string: storagePath) {
            isChangingDirectory = true
            settingsService.setStoragePath(url)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    self.isChangingDirectory = false
                    
                    if case .failure(let error) = completion {
                        self.showError(message: error.localizedDescription)
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }
    }
    
    func resetStoragePath() {
        // 使用Documents目录作为默认路径
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        isChangingDirectory = true
        settingsService.setStoragePath(documentsPath)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isChangingDirectory = false
                
                if case .failure(let error) = completion {
                    self.showError(message: error.localizedDescription)
                }
            } receiveValue: { [weak self] _ in
                self?.storagePath = documentsPath.path
                print("已重置存储路径为文档目录: \(documentsPath.path)")
            }
            .store(in: &cancellables)
    }
    
    func testStoragePath() {
        print("=== 存储路径测试 ===")
        print("当前路径: \(storagePath)")
        
        if let url = settingsService.storagePath {
            let success = url.startAccessingSecurityScopedResource()
            print("访问URL: \(url.path), 结果: \(success ? "成功" : "失败")")
            
            let recordingsDir = settingsService.recordingsDirectory
            print("录音目录: \(recordingsDir.path)")
            
            // 测试写入
            do {
                let testFile = recordingsDir.appendingPathComponent("test.txt")
                try "测试内容".write(to: testFile, atomically: true, encoding: .utf8)
                print("测试文件创建成功: \(testFile.path)")
                try FileManager.default.removeItem(at: testFile)
                print("测试文件删除成功")
            } catch {
                print("测试文件操作失败: \(error.localizedDescription)")
            }
            
            url.stopAccessingSecurityScopedResource()
        } else {
            print("存储路径未设置")
        }
        
        print("=== 测试结束 ===")
    }
    
    // MARK: - 其他功能
    
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
    
    // MARK: - 错误处理
    
    private func showError(message: String) {
        self.errorMessage = message
        self.showError = true
    }
} 
