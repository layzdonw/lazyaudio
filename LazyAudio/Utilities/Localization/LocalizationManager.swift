import Foundation
import SwiftUI
import Combine

/// 本地化管理器
/// 负责处理应用的本地化
class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
            setupLocale()
            NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        }
    }
    
    static let shared = LocalizationManager()
    
    private init() {
        // 从用户默认设置中获取语言，如果没有则使用系统语言
        if let languageCode = UserDefaults.standard.string(forKey: "app_language"),
           let language = Language(rawValue: languageCode) {
            self.currentLanguage = language
        } else {
            // 获取系统语言
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            if preferredLanguage.starts(with: "zh") {
                self.currentLanguage = .chinese
            } else {
                self.currentLanguage = .english
            }
        }
        
        setupLocale()
    }
    
    private func setupLocale() {
        // 设置应用的语言环境
        UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // 重新加载本地化资源束
        Bundle.main.localizedString(forKey: "", value: nil, table: nil)
    }
    
    /// 获取本地化字符串
    /// - Parameter key: 本地化键
    /// - Returns: 本地化字符串
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    /// 支持的语言列表
    var supportedLanguages: [Language] {
        return Language.allCases
    }
    
    /// 切换语言
    /// - Parameter language: 目标语言
    func switchLanguage(to language: Language) {
        self.currentLanguage = language
    }
}

/// 支持的语言
enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .chinese:
            return "简体中文"
        }
    }
    
    var locale: Locale {
        return Locale(identifier: self.rawValue)
    }
}

/// 本地化字符串扩展
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
    }
    
    /// 带格式的本地化字符串
    /// - Parameter arguments: 格式化参数
    /// - Returns: 格式化后的本地化字符串
    func localizedFormat(_ arguments: CVarArg...) -> String {
        let localizedFormat = self.localized
        return String(format: localizedFormat, arguments: arguments)
    }
}

/// 本地化环境键
struct LocalizationKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

/// 环境值扩展
extension EnvironmentValues {
    var localizationManager: LocalizationManager {
        get { self[LocalizationKey.self] }
        set { self[LocalizationKey.self] = newValue }
    }
}

/// 本地化文本视图
struct LocalizedText: View {
    let key: String
    var font: Font? = nil
    var color: Color? = nil
    var alignment: TextAlignment = .leading
    
    var body: some View {
        Text(key.localized)
            .font(font)
            .foregroundColor(color)
            .multilineTextAlignment(alignment)
    }
}

/// 标题文本的本地化版本
struct LocalizedTitle: View {
    let key: String
    var font: Font = .title
    var color: Color? = nil
    
    var body: some View {
        LocalizedText(key: key, font: font, color: color)
    }
}

/// 带参数的本地化文本
struct LocalizedFormatText: View {
    let key: String
    let arguments: [CVarArg]
    var font: Font? = nil
    var color: Color? = nil
    
    init(_ key: String, _ arguments: CVarArg..., font: Font? = nil, color: Color? = nil) {
        self.key = key
        self.arguments = arguments
        self.font = font
        self.color = color
    }
    
    var body: some View {
        let localizedFormat = NSLocalizedString(key, comment: "")
        let formattedString = String(format: localizedFormat, arguments: arguments)
        
        Text(formattedString)
            .font(font)
            .foregroundColor(color)
    }
} 