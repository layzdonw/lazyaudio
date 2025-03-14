import Foundation
import AppKit

// 定义一个命名空间来避免命名冲突
enum AppModels {
    // 运行中的应用模型
    struct RunningApp: Identifiable, Hashable {
        let id: String
        let name: String
        let bundleIdentifier: String
        let icon: NSImage?
        
        init(id: String? = nil, name: String, bundleIdentifier: String, icon: NSImage? = nil) {
            self.id = id ?? bundleIdentifier
            self.name = name
            self.bundleIdentifier = bundleIdentifier
            self.icon = icon
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(bundleIdentifier)
        }
        
        static func == (lhs: RunningApp, rhs: RunningApp) -> Bool {
            return lhs.bundleIdentifier == rhs.bundleIdentifier
        }
    }
    
    // 获取系统正在运行的应用列表
    static func getRunningApps() -> [RunningApp] {
        let workspace = NSWorkspace.shared
        let runningApplications = workspace.runningApplications
        
        var apps: [RunningApp] = []
        
        for app in runningApplications {
            if app.activationPolicy == .regular, // 只获取常规应用
               let bundleIdentifier = app.bundleIdentifier,
               let appName = app.localizedName {
                let icon = app.icon
                apps.append(RunningApp(name: appName, bundleIdentifier: bundleIdentifier, icon: icon))
            }
        }
        
        // 按应用名称排序
        apps.sort { $0.name < $1.name }
        
        return apps
    }
} 