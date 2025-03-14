import SwiftUI
import AVFoundation
import AppKit

struct LandingView: View {
    @State private var systemAudioChecked = true // 默认勾选，不可取消
    @State private var microphoneChecked = false // 默认未勾选，可选
    @State private var showAdvancedOptions = false // 控制是否显示高级选项
    @State private var showTooltip = false // 控制是否显示提示
    @State private var isRequestingPermission = false
    @State private var isPrimaryButtonHovered = false
    @State private var isSecondaryButtonHovered = false
    @State private var isHelpButtonHovered = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) private var colorScheme
    
    // 颜色定义
    private var backgroundColor: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: colorScheme == .dark 
                    ? [Color(hex: "1C2526"), Color(hex: "2D3748")] 
                    : [Color(hex: "F5F5F7"), Color(hex: "E5E7EB")]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? Color(hex: "E2E8F0") : Color(hex: "1C2526")
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color(hex: "A0AEC0") : Color(hex: "6B7280")
    }
    
    private var accentColor: Color {
        colorScheme == .dark ? Color(hex: "3399FF") : Color(hex: "007AFF")
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 顶部工具栏
                TopToolbar(isDarkMode: $isDarkMode, secondaryTextColor: secondaryTextColor)
                    
                    // 主要内容区域
                contentArea
            }
            
            // 权限请求遮罩
            if isRequestingPermission {
                PermissionOverlay()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isRequestingPermission)
        .animation(.easeInOut(duration: 0.3), value: microphoneChecked)
        .animation(.easeInOut(duration: 0.2), value: isPrimaryButtonHovered)
        .animation(.easeInOut(duration: 0.2), value: isSecondaryButtonHovered)
        .animation(.easeInOut(duration: 0.2), value: showAdvancedOptions)
        .animation(.easeInOut(duration: 0.2), value: showTooltip)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            // 延迟显示提示，让用户先看到界面
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showTooltip = true
                }
                
                // 3秒后自动隐藏提示
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showTooltip = false
                    }
                }
            }
        }
    }
    
    // 主要内容区域
    private var contentArea: some View {
        VStack(spacing: 40) {
            // 标题和图标
            AppHeader(
                accentColor: accentColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor
            )
            
            // 主要内容区域
            VStack(spacing: 24) {
                // 权限说明卡片
                PermissionInfoCard(
                    accentColor: accentColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor
                )
                
                // 权限选项卡片
                permissionOptionsCard
                
                // 帮助提示
                if !microphoneChecked {
                    HelpTipSection(
                        showTooltip: $showTooltip,
                        isHelpButtonHovered: $isHelpButtonHovered,
                        accentColor: accentColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        colorScheme: colorScheme
                    )
                }
            }
            .frame(width: 500)
            
            Spacer()
            
            // 底部区域：操作按钮
            ActionButtons(
                isPrimaryButtonHovered: $isPrimaryButtonHovered,
                isSecondaryButtonHovered: $isSecondaryButtonHovered,
                microphoneChecked: $microphoneChecked,
                accentColor: accentColor,
                onPrimaryAction: requestPermissions,
                onSecondaryAction: {
                    // 仅请求系统音频权限
                    microphoneChecked = false
                    requestPermissions()
                }
            )
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 60)
        .frame(maxWidth: 800)
        .frame(maxHeight: .infinity)
    }
    
    // 权限选项卡片
    private var permissionOptionsCard: some View {
        VStack(spacing: 16) {
            // 系统音频选项（必选）
            SystemAudioOption(
                accentColor: accentColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                colorScheme: colorScheme
            )
            
            // 麦克风选项（可选）
            MicrophoneOption(
                microphoneChecked: $microphoneChecked,
                accentColor: accentColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                colorScheme: colorScheme
            )
            
            // 高级选项折叠区
            AdvancedOptionsSection(
                showAdvancedOptions: $showAdvancedOptions,
                accentColor: accentColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                colorScheme: colorScheme
            )
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 请求权限
    private func requestPermissions() {
        isRequestingPermission = true
        
        // 首先请求系统音频权限
        requestSystemAudioPermission { systemGranted in
            // 如果系统音频权限被授予且用户选择了麦克风权限
            if systemGranted && microphoneChecked {
                requestMicrophonePermission { micGranted in
                    DispatchQueue.main.async {
                        isRequestingPermission = false
                        if systemGranted {
                            // 保存麦克风权限状态
                            UserDefaults.standard.set(micGranted, forKey: "microphonePermissionGranted")
                            // 设置已完成引导
                            hasCompletedOnboarding = true
                        } else {
                            // 系统音频权限被拒绝，显示错误
                            showPermissionError()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    isRequestingPermission = false
                    if systemGranted {
                        // 保存麦克风权限状态（未请求）
                        UserDefaults.standard.set(false, forKey: "microphonePermissionGranted")
                        // 设置已完成引导
                        hasCompletedOnboarding = true
                    } else {
                        // 系统音频权限被拒绝，显示错误
                        showPermissionError()
                    }
                }
            }
        }
    }
    
    // 请求系统音频权限
    private func requestSystemAudioPermission(completion: @escaping (Bool) -> Void) {
        // 注意：在 macOS 中，系统音频权限通常需要使用 ScreenCaptureKit 框架
        // 这里我们使用简化的模拟实现
        
        // 显示一个对话框，解释为什么需要系统音频权限
        let alert = NSAlert()
        alert.messageText = "需要系统音频权限"
        alert.informativeText = "LazyAudio 需要系统音频权限来录制系统或应用程序的声音。请在接下来的系统对话框中点击\"允许\"。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "继续")
        
        DispatchQueue.main.async {
            alert.runModal()
            
            // 在实际应用中，这里应该调用 ScreenCaptureKit 的 API 来请求系统音频权限
            // 为了演示，我们使用延迟来模拟权限请求过程
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // 假设权限被授予
                completion(true)
            }
        }
    }
    
    // 请求麦克风权限
    private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        // 请求麦克风权限
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            completion(granted)
        }
    }
    
    // 显示权限错误
    private func showPermissionError() {
        let alert = NSAlert()
        alert.messageText = "系统音频权限未授权"
        alert.informativeText = "系统音频权限是必需的，无法使用转录功能。请前往系统设置启用。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "前往设置")
        alert.addButton(withTitle: "退出")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // 打开系统偏好设置
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
        }
    }
}

// 预览
struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LandingView()
                .preferredColorScheme(.light)
            
            LandingView()
                .preferredColorScheme(.dark)
        }
    }
} 
