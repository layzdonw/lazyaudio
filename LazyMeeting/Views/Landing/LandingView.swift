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
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max" : "moon")
                            .font(.system(size: 16))
                            .foregroundColor(secondaryTextColor)
                            .frame(width: 32, height: 32)
                            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(isDarkMode ? "切换到浅色模式" : "切换到深色模式")
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // 主要内容
                VStack(spacing: 40) {
                    // 标题和图标
                    VStack(spacing: 16) {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(accentColor)
                        
                        Text("LazyMeeting")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(primaryTextColor)
                        
                        Text("智能会议转录与分析")
                            .font(.title3)
                            .foregroundColor(secondaryTextColor)
                    }
                    
                    // 主要内容区域
                    VStack(spacing: 24) {
                        // 权限说明卡片
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(accentColor)
                                
                                Text("为什么需要权限？")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(primaryTextColor)
                                
                                Spacer()
                            }
                            
                            Text("系统音频权限用于捕获您的Mac声音（必选），麦克风权限用于录制您的语音（可选）。授权后，您可以立即体验实时转录功能！")
                                .font(.system(size: 13))
                                .foregroundColor(secondaryTextColor)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // 权限选项卡片
                        VStack(spacing: 16) {
                            // 系统音频选项（必选）
                            HStack(spacing: 12) {
                                Toggle("", isOn: .constant(true))
                                    .toggleStyle(CheckboxToggleStyle(color: accentColor))
                                    .disabled(true)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("系统音频")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(primaryTextColor)
                                    
                                    Text("捕获您的Mac声音")
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryTextColor)
                                }
                                
                                Spacer()
                                
                                Text("必选")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(colorScheme == .dark ? Color(hex: "1C2526").opacity(0.5) : Color(hex: "F5F5F7").opacity(0.5))
                            .cornerRadius(8)
                            
                            // 麦克风选项（可选）
                            HStack(spacing: 12) {
                                Toggle("", isOn: $microphoneChecked)
                                    .toggleStyle(CheckboxToggleStyle(color: accentColor))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("麦克风")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(primaryTextColor)
                                    
                                    Text("录制您的语音")
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryTextColor)
                                }
                                
                                Spacer()
                                
                                Text("可选")
                                    .font(.system(size: 12))
                                    .foregroundColor(secondaryTextColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(colorScheme == .dark ? Color(hex: "1C2526").opacity(0.5) : Color(hex: "F5F5F7").opacity(0.5))
                            .cornerRadius(8)
                            
                            // 高级选项折叠区
                            VStack(spacing: 8) {
                                Button(action: {
                                    withAnimation {
                                        showAdvancedOptions.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text("高级选项")
                                            .font(.system(size: 13))
                                            .foregroundColor(accentColor)
                                        
                                        Spacer()
                                        
                                        Image(systemName: showAdvancedOptions ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(accentColor)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if showAdvancedOptions {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("应用音频")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(primaryTextColor)
                                        
                                        Text("选择特定应用的音频进行转录")
                                            .font(.system(size: 12))
                                            .foregroundColor(secondaryTextColor)
                                        
                                        // 这里可以添加应用选择器
                                        Text("此功能将在后续版本中提供")
                                            .font(.system(size: 12))
                                            .foregroundColor(secondaryTextColor)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                    .padding(.top, 8)
                                    .transition(.opacity)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(colorScheme == .dark ? Color(hex: "1C2526").opacity(0.5) : Color(hex: "F5F5F7").opacity(0.5))
                            .cornerRadius(8)
                        }
                        .padding(16)
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // 帮助提示
                        if !microphoneChecked {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(accentColor)
                                
                                Text("提示：您可以稍后在设置中随时启用麦克风")
                                    .font(.system(size: 12))
                                    .foregroundColor(secondaryTextColor)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        showTooltip.toggle()
                                    }
                                }) {
                                    Image(systemName: "questionmark.circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(isHelpButtonHovered ? accentColor : secondaryTextColor)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onHover { hovering in
                                    isHelpButtonHovered = hovering
                                }
                            }
                            .padding(12)
                            .background(colorScheme == .dark ? Color(hex: "1C2526").opacity(0.5) : Color(hex: "F5F5F7").opacity(0.5))
                            .cornerRadius(8)
                            
                            if showTooltip {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("关于权限")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(primaryTextColor)
                                    
                                    Text("• 系统音频权限是必需的，用于捕获您的Mac声音\n• 麦克风权限是可选的，用于录制您的语音\n• 您可以随时在设置中更改这些权限")
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryTextColor)
                                    
                                    Button("了解更多") {
                                        NSWorkspace.shared.open(URL(string: "https://support.apple.com/zh-cn/guide/mac-help/mchla1b1e1fe/mac")!)
                                    }
                                    .font(.system(size: 12))
                                    .foregroundColor(accentColor)
                                }
                                .padding(12)
                                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .transition(.opacity)
                            }
                        }
                    }
                    .frame(width: 500)
                    
                    Spacer()
                    
                    // 底部区域：操作按钮
                    VStack(spacing: 16) {
                        // 主按钮
                        Button(action: {
                            requestPermissions()
                        }) {
                            Text("授权并开始")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 200, height: 44)
                                .background(isPrimaryButtonHovered ? accentColor : accentColor)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                        .onHover { hovering in
                            isPrimaryButtonHovered = hovering
                            if hovering {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }
                        
                        // 次按钮（仅当麦克风可选时显示）
                        Button(action: {
                            // 仅请求系统音频权限
                            microphoneChecked = false
                            requestPermissions()
                        }) {
                            Text("稍后设置")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(accentColor)
                                .frame(width: 200, height: 44)
                                .background(isSecondaryButtonHovered ? Color(nsColor: .controlColor) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(accentColor, lineWidth: 1)
                                )
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                        .onHover { hovering in
                            isSecondaryButtonHovered = hovering
                            if hovering {
                                NSCursor.pointingHand.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 60)
                .frame(maxWidth: 800)
                .frame(maxHeight: .infinity)
            }
            
            // 权限请求遮罩
            if isRequestingPermission {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("请在系统对话框中授予权限...")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("这将允许应用捕获音频进行转录")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(30)
                .background(Color(nsColor: .windowBackgroundColor).opacity(0.9))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
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
        alert.informativeText = "LazyMeeting 需要系统音频权限来录制系统或应用程序的声音。请在接下来的系统对话框中点击\"允许\"。"
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

// 自定义复选框样式
struct CheckboxToggleStyle: ToggleStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 1)
                    .frame(width: 20, height: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(configuration.isOn ? color : Color.clear)
                    )
                
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    configuration.isOn.toggle()
                }
            }
            
            configuration.label
        }
    }
}

// 扩展 Color 以支持十六进制颜色代码
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
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
