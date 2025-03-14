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
    }
    
    /// 获取本地化字符串
    /// - Parameter key: 本地化键
    /// - Returns: 本地化字符串
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
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
}

/// 本地化字符串扩展
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
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
    
    var body: some View {
        Text(key.localized)
            .font(font)
            .foregroundColor(color)
    }
} 