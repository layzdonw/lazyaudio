import Foundation
import Combine
import AppKit

/// 应用设置键
enum SettingsKey: String {
    case storagePath = "storagePath"
    case storagePathBookmark = "storagePathBookmark"
    case isDarkMode = "isDarkMode"
    case selectedLanguageCode = "selectedLanguageCode"
    case selectedAIModel = "selectedAIModel"
    case apiKey = "apiKey"
    case apiBase = "apiBase"
    case localModelPath = "localModelPath"
    case localModelPathBookmark = "localModelPathBookmark"
    case cacheDirectory = "cacheDirectory"
    case cacheDirectoryBookmark = "cacheDirectoryBookmark"
    case modelTemperature = "modelTemperature"
    case maxTokens = "maxTokens"
    case autoCleanup = "autoCleanup"
    case retentionPeriod = "retentionPeriod"
    case fontSize = "fontSize"
}

/// 设置服务协议
protocol SettingsServiceProtocol {
    // 通用设置
    var isDarkMode: Bool { get }
    var selectedLanguageCode: String { get }
    var fontSize: Int { get }
    
    // 存储设置
    var storagePath: URL? { get }
    var recordingsDirectory: URL { get }
    var autoCleanup: Bool { get }
    var retentionPeriod: Int { get }
    
    // 转录设置
    var localModelPath: URL? { get }
    var cacheDirectory: URL? { get }
    
    // AI设置
    var selectedAIModel: Int { get }
    var apiKey: String { get }
    var apiBase: String { get }
    var modelTemperature: Double { get }
    var maxTokens: Int { get }
    
    // 设置方法
    func setDarkMode(_ isDarkMode: Bool) -> AnyPublisher<Void, Never>
    func setLanguage(_ code: String) -> AnyPublisher<Void, Never>
    func setFontSize(_ size: Int) -> AnyPublisher<Void, Never>
    
    func setStoragePath(_ url: URL) -> AnyPublisher<Void, Error>
    func setAutoCleanup(_ enabled: Bool) -> AnyPublisher<Void, Never>
    func setRetentionPeriod(_ days: Int) -> AnyPublisher<Void, Never>
    
    func setLocalModelPath(_ url: URL) -> AnyPublisher<Void, Error>
    func setCacheDirectory(_ url: URL) -> AnyPublisher<Void, Error>
    
    func setAIModel(_ model: Int) -> AnyPublisher<Void, Never>
    func setAPIKey(_ key: String) -> AnyPublisher<Void, Never>
    func setAPIBase(_ base: String) -> AnyPublisher<Void, Never>
    func setModelTemperature(_ temperature: Double) -> AnyPublisher<Void, Never>
    func setMaxTokens(_ tokens: Int) -> AnyPublisher<Void, Never>
    
    func resetToDefaults() -> AnyPublisher<Void, Error>
}

/// 设置服务实现
class SettingsService: SettingsServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    // MARK: - 属性访问器
    
    // 通用设置
    var isDarkMode: Bool {
        userDefaults.bool(forKey: SettingsKey.isDarkMode.rawValue)
    }
    
    var selectedLanguageCode: String {
        userDefaults.string(forKey: SettingsKey.selectedLanguageCode.rawValue) ?? "zh-Hans"
    }
    
    var fontSize: Int {
        let size = userDefaults.integer(forKey: SettingsKey.fontSize.rawValue)
        return size == 0 ? 1 : size // 默认为中等大小
    }
    
    // 存储设置
    var storagePath: URL? {
        resolveBookmarkedURL(for: .storagePath)
    }
    
    var recordingsDirectory: URL {
        if let baseURL = storagePath {
            // 使用存储路径下的Recordings子文件夹
            let recordingsPath = baseURL.appendingPathComponent("Recordings")
            
            // 确保目录存在
            if !fileManager.fileExists(atPath: recordingsPath.path) {
                try? fileManager.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
            }
            
            return recordingsPath
        } else {
            // 默认使用 Documents/Recordings 目录
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let recordingsPath = documentsPath.appendingPathComponent("Recordings")
            
            // 确保目录存在
            if !fileManager.fileExists(atPath: recordingsPath.path) {
                try? fileManager.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
            }
            
            return recordingsPath
        }
    }
    
    var autoCleanup: Bool {
        userDefaults.bool(forKey: SettingsKey.autoCleanup.rawValue)
    }
    
    var retentionPeriod: Int {
        let period = userDefaults.integer(forKey: SettingsKey.retentionPeriod.rawValue)
        return period == 0 ? 30 : period // 默认为30天
    }
    
    // 转录设置
    var localModelPath: URL? {
        resolveBookmarkedURL(for: .localModelPath)
    }
    
    var cacheDirectory: URL? {
        resolveBookmarkedURL(for: .cacheDirectory)
    }
    
    // AI设置
    var selectedAIModel: Int {
        userDefaults.integer(forKey: SettingsKey.selectedAIModel.rawValue)
    }
    
    var apiKey: String {
        userDefaults.string(forKey: SettingsKey.apiKey.rawValue) ?? ""
    }
    
    var apiBase: String {
        userDefaults.string(forKey: SettingsKey.apiBase.rawValue) ?? "https://api.openai.com/v1"
    }
    
    var modelTemperature: Double {
        let temp = userDefaults.double(forKey: SettingsKey.modelTemperature.rawValue)
        return temp == 0 ? 0.7 : temp // 默认为0.7
    }
    
    var maxTokens: Int {
        let tokens = userDefaults.integer(forKey: SettingsKey.maxTokens.rawValue)
        return tokens == 0 ? 2048 : tokens // 默认为2048
    }
    
    // MARK: - 设置方法
    
    // 通用设置
    func setDarkMode(_ isDarkMode: Bool) -> AnyPublisher<Void, Never> {
        userDefaults.set(isDarkMode, forKey: SettingsKey.isDarkMode.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    func setLanguage(_ code: String) -> AnyPublisher<Void, Never> {
        userDefaults.set(code, forKey: SettingsKey.selectedLanguageCode.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    func setFontSize(_ size: Int) -> AnyPublisher<Void, Never> {
        userDefaults.set(size, forKey: SettingsKey.fontSize.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    // 存储设置
    func setStoragePath(_ url: URL) -> AnyPublisher<Void, Error> {
        return createDirectoryWithPermissions(at: url)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "SettingsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service not available"])).eraseToAnyPublisher()
                }
                
                // 创建录音文件夹
                let recordingsPath = url.appendingPathComponent("Recordings")
                if !self.fileManager.fileExists(atPath: recordingsPath.path) {
                    do {
                        try self.fileManager.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
                    } catch {
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                }
                
                return self.saveSecurityScopedBookmark(url: url, for: .storagePath)
            }
            .eraseToAnyPublisher()
    }
    
    func setAutoCleanup(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        userDefaults.set(enabled, forKey: SettingsKey.autoCleanup.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    func setRetentionPeriod(_ days: Int) -> AnyPublisher<Void, Never> {
        userDefaults.set(days, forKey: SettingsKey.retentionPeriod.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    // 转录设置
    func setLocalModelPath(_ url: URL) -> AnyPublisher<Void, Error> {
        return saveSecurityScopedBookmark(url: url, for: .localModelPath)
    }
    
    func setCacheDirectory(_ url: URL) -> AnyPublisher<Void, Error> {
        return createDirectoryWithPermissions(at: url)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "SettingsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service not available"])).eraseToAnyPublisher()
                }
                return self.saveSecurityScopedBookmark(url: url, for: .cacheDirectory)
            }
            .eraseToAnyPublisher()
    }
    
    // AI设置
    func setAIModel(_ model: Int) -> AnyPublisher<Void, Never> {
        userDefaults.set(model, forKey: SettingsKey.selectedAIModel.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    func setAPIKey(_ key: String) -> AnyPublisher<Void, Never> {
        userDefaults.set(key, forKey: SettingsKey.apiKey.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    func setAPIBase(_ base: String) -> AnyPublisher<Void, Never> {
        userDefaults.set(base, forKey: SettingsKey.apiBase.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    func setModelTemperature(_ temperature: Double) -> AnyPublisher<Void, Never> {
        userDefaults.set(temperature, forKey: SettingsKey.modelTemperature.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    func setMaxTokens(_ tokens: Int) -> AnyPublisher<Void, Never> {
        userDefaults.set(tokens, forKey: SettingsKey.maxTokens.rawValue)
        return Just(()).eraseToAnyPublisher()
    }
    
    // 重置设置
    func resetToDefaults() -> AnyPublisher<Void, Error> {
        let resultSubject = PassthroughSubject<Void, Error>()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            // 重置所有设置，但保留语言设置
            let language = self.selectedLanguageCode
            
            // 重置 UserDefaults 中的所有键
            for key in SettingsKey.allCases {
                userDefaults.removeObject(forKey: key.rawValue)
            }
            
            // 恢复语言设置
            userDefaults.set(language, forKey: SettingsKey.selectedLanguageCode.rawValue)
            
            // 确保默认目录存在
            let documentsPath = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let recordingsPath = documentsPath.appendingPathComponent("Recordings")
            
            do {
                if !self.fileManager.fileExists(atPath: recordingsPath.path) {
                    try self.fileManager.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
                }
                
                DispatchQueue.main.async {
                    resultSubject.send(())
                    resultSubject.send(completion: .finished)
                }
            } catch {
                DispatchQueue.main.async {
                    resultSubject.send(completion: .failure(error))
                }
            }
            
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
    
    // MARK: - 权限和书签辅助方法
    
    /// 创建目录并检查权限
    private func createDirectoryWithPermissions(at url: URL) -> AnyPublisher<Void, Error> {
        let resultSubject = PassthroughSubject<Void, Error>()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // 检查目录是否存在，不存在则创建
                if !self.fileManager.fileExists(atPath: url.path) {
                    try self.fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                }
                
                // 检查是否有写入权限
                let testFile = url.appendingPathComponent("test_write_permission")
                try "test".write(to: testFile, atomically: true, encoding: .utf8)
                try self.fileManager.removeItem(at: testFile)
                
                DispatchQueue.main.async {
                    resultSubject.send(())
                    resultSubject.send(completion: .finished)
                }
            } catch {
                // 权限检查失败，可能需要请求访问权限
                DispatchQueue.main.async {
                    if self.shouldPromptUserForPermission(error: error) {
                        self.promptUserForDirectoryPermission(completionHandler: { granted in
                            if granted {
                                resultSubject.send(())
                                resultSubject.send(completion: .finished)
                            } else {
                                resultSubject.send(completion: .failure(error))
                            }
                        })
                    } else {
                        resultSubject.send(completion: .failure(error))
                    }
                }
            }
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
    
    /// 保存安全作用域书签
    private func saveSecurityScopedBookmark(url: URL, for key: SettingsKey) -> AnyPublisher<Void, Error> {
        let resultSubject = PassthroughSubject<Void, Error>()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // 确保URL有正确的访问权限
                if !url.startAccessingSecurityScopedResource() {
                    let error = NSError(
                        domain: "SettingsService", 
                        code: -1, 
                        userInfo: [NSLocalizedDescriptionKey: "无法访问安全作用域资源"]
                    )
                    throw error
                }
                
                // 创建安全作用域书签
                let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                
                // 停止访问
                url.stopAccessingSecurityScopedResource()
                
                // 保存书签和路径
                userDefaults.set(bookmarkData, forKey: key.rawValue + "Bookmark")
                userDefaults.set(url.path, forKey: key.rawValue)
                
                print("成功保存书签: \(key.rawValue), 路径: \(url.path)")
                
                DispatchQueue.main.async {
                    resultSubject.send(())
                    resultSubject.send(completion: .finished)
                }
            } catch {
                print("保存书签失败: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    resultSubject.send(completion: .failure(error))
                }
            }
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
    
    /// 解析安全作用域书签URL
    private func resolveBookmarkedURL(for key: SettingsKey) -> URL? {
        guard let bookmarkData = userDefaults.data(forKey: key.rawValue + "Bookmark") else {
            return nil
        }
        
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            // 开始访问安全作用域资源
            let success = url.startAccessingSecurityScopedResource()
            print("访问安全作用域资源 \(key.rawValue): \(success ? "成功" : "失败")")
            
            if isStale {
                // 如果书签过期，尝试重新创建
                print("书签过期，尝试重新创建: \(key.rawValue)")
                if let newBookmarkData = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
                    userDefaults.set(newBookmarkData, forKey: key.rawValue + "Bookmark")
                    print("成功重新创建书签: \(key.rawValue)")
                }
            }
            
            return url
        } catch {
            print("解析书签失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 判断是否应该提示用户授予权限
    private func shouldPromptUserForPermission(error: Error) -> Bool {
        // 根据错误类型判断是否是权限问题
        let nsError = error as NSError
        return nsError.domain == NSCocoaErrorDomain && 
               (nsError.code == NSFileWriteNoPermissionError || 
                nsError.code == NSFileReadNoPermissionError)
    }
    
    /// 提示用户授予目录访问权限
    private func promptUserForDirectoryPermission(completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "需要访问权限"
            alert.informativeText = "LazyAudio 需要访问您选择的文件夹以保存录音文件。请在接下来的对话框中选择该文件夹并授予权限。"
            alert.addButton(withTitle: "继续")
            alert.addButton(withTitle: "取消")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // 显示文件夹选择器
                let openPanel = NSOpenPanel()
                openPanel.message = "请选择文件夹并授予访问权限"
                openPanel.prompt = "授权访问"
                openPanel.canChooseDirectories = true
                openPanel.canChooseFiles = false
                openPanel.canCreateDirectories = true
                
                if openPanel.runModal() == .OK, let url = openPanel.url {
                    // 用户选择了文件夹并授予了权限
                    completionHandler(true)
                } else {
                    // 用户取消了操作
                    completionHandler(false)
                }
            } else {
                // 用户点击了取消
                completionHandler(false)
            }
        }
    }
}

extension SettingsKey: CaseIterable {
    static var allCases: [SettingsKey] {
        return [
            .isDarkMode, .selectedLanguageCode,
            .selectedAIModel, .apiKey, .apiBase,
            .localModelPath, .localModelPathBookmark,
            .cacheDirectory, .cacheDirectoryBookmark,
            .modelTemperature, .maxTokens,
            .storagePath, .storagePathBookmark,
            .autoCleanup, .retentionPeriod, .fontSize
        ]
    }
} 
