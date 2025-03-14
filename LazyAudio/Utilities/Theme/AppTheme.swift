import SwiftUI

/// 应用主题管理器
/// 统一管理应用的颜色、字体、间距等样式
struct AppTheme {
    // MARK: - 颜色
    
    struct Colors {
        // 主要颜色
        static let primary = Color.accentColor
        static let secondary = Color.secondary
        
        // 背景颜色
        static let background = Color(nsColor: .windowBackgroundColor)
        static let secondaryBackground = Color(nsColor: .controlBackgroundColor)
        
        // 状态颜色
        static let success = Color.green
        static let warning = Color.yellow
        static let error = Color.red
        static let info = Color.blue
        
        // 录音相关颜色
        static let recording = Color.red
        static let recordingBackground = Color.red.opacity(0.1)
    }
    
    // MARK: - 字体
    
    struct Typography {
        // 标题
        static let largeTitle = Font.largeTitle
        static let title = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3
        
        // 正文
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
        
        // 自定义字体
        static let monospaced = Font.system(.body, design: .monospaced)
        static let monospacedCaption = Font.system(.caption, design: .monospaced)
    }
    
    // MARK: - 间距
    
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let regular: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let huge: CGFloat = 48
    }
    
    // MARK: - 圆角
    
    struct CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
        static let circular: CGFloat = 9999
    }
    
    // MARK: - 阴影
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
        
        init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
        
        static let small = Shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        static let large = Shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 动画
    
    struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
    
    // MARK: - 布局尺寸
    
    struct Layout {
        static let sidebarWidth: CGFloat = 250
        static let minContentWidth: CGFloat = 500
        static let minWindowWidth: CGFloat = 1080
        static let minWindowHeight: CGFloat = 720
    }
} 