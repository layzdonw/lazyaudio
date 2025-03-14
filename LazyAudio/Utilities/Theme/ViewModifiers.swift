import SwiftUI

// MARK: - 卡片样式修饰符

/// 卡片样式修饰符
/// 为视图添加卡片样式，包括背景、圆角和阴影
struct CardModifier: ViewModifier {
    var padding: CGFloat = AppTheme.Spacing.regular
    var cornerRadius: CGFloat = AppTheme.CornerRadius.medium
    var shadowStyle: AppTheme.Shadow = .small
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.Colors.background)
            .cornerRadius(cornerRadius)
            .shadow(
                color: shadowStyle.color,
                radius: shadowStyle.radius,
                x: shadowStyle.x,
                y: shadowStyle.y
            )
    }
}

// MARK: - 按钮样式修饰符

/// 主要按钮样式修饰符
/// 为按钮添加主要样式，包括背景色、文字颜色和圆角
struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, AppTheme.Spacing.small)
            .padding(.horizontal, AppTheme.Spacing.medium)
            .background(AppTheme.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

/// 次要按钮样式修饰符
/// 为按钮添加次要样式，包括边框、文字颜色和圆角
struct SecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, AppTheme.Spacing.small)
            .padding(.horizontal, AppTheme.Spacing.medium)
            .background(Color.clear)
            .foregroundColor(AppTheme.Colors.primary)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(AppTheme.Colors.primary, lineWidth: 1)
            )
    }
}

// MARK: - 输入框样式修饰符

/// 输入框样式修饰符
/// 为输入框添加统一样式，包括背景、圆角和边框
struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.small)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - 扩展 View

extension View {
    /// 应用卡片样式
    func cardStyle(
        padding: CGFloat = AppTheme.Spacing.regular,
        cornerRadius: CGFloat = AppTheme.CornerRadius.medium,
        shadowStyle: AppTheme.Shadow = .small
    ) -> some View {
        self.modifier(CardModifier(
            padding: padding,
            cornerRadius: cornerRadius,
            shadowStyle: shadowStyle
        ))
    }
    
    /// 应用主要按钮样式
    func primaryButtonStyle() -> some View {
        self.modifier(PrimaryButtonModifier())
    }
    
    /// 应用次要按钮样式
    func secondaryButtonStyle() -> some View {
        self.modifier(SecondaryButtonModifier())
    }
    
    /// 应用输入框样式
    func textFieldStyle() -> some View {
        self.modifier(TextFieldModifier())
    }
} 