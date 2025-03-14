import SwiftUI
import AppKit

// MARK: - 组件

// 顶部工具栏
struct TopToolbar: View {
    @Binding var isDarkMode: Bool
    var secondaryTextColor: Color
    
    var body: some View {
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
    }
}

// 应用标题和图标
struct AppHeader: View {
    var accentColor: Color
    var primaryTextColor: Color
    var secondaryTextColor: Color
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(accentColor)
            
            Text("LazyAudio")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(primaryTextColor)
            
            Text("智能会议转录与分析")
                .font(.title3)
                .foregroundColor(secondaryTextColor)
        }
    }
}

// 权限信息卡片
struct PermissionInfoCard: View {
    var accentColor: Color
    var primaryTextColor: Color
    var secondaryTextColor: Color
    
    var body: some View {
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
    }
}

// 系统音频选项
struct SystemAudioOption: View {
    var accentColor: Color
    var primaryTextColor: Color
    var secondaryTextColor: Color
    var colorScheme: ColorScheme
    
    var body: some View {
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
    }
}

// 麦克风选项
struct MicrophoneOption: View {
    @Binding var microphoneChecked: Bool
    var accentColor: Color
    var primaryTextColor: Color
    var secondaryTextColor: Color
    var colorScheme: ColorScheme
    
    var body: some View {
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
    }
}

// 高级选项部分
struct AdvancedOptionsSection: View {
    @Binding var showAdvancedOptions: Bool
    var accentColor: Color
    var primaryTextColor: Color
    var secondaryTextColor: Color
    var colorScheme: ColorScheme
    
    var body: some View {
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
}

// 帮助提示部分
struct HelpTipSection: View {
    @Binding var showTooltip: Bool
    @Binding var isHelpButtonHovered: Bool
    var accentColor: Color
    var primaryTextColor: Color
    var secondaryTextColor: Color
    var colorScheme: ColorScheme
    
    var body: some View {
        VStack {
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
                .onHover(perform: { hovering in
                    isHelpButtonHovered = hovering
                })
            }
            .padding(12)
            .background(colorScheme == .dark ? Color(hex: "1C2526").opacity(0.5) : Color(hex: "F5F5F7").opacity(0.5))
            .cornerRadius(8)
            
            if showTooltip {
                TooltipContent(accentColor: accentColor, primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor)
            }
        }
    }
}

// 提示内容
struct TooltipContent: View {
    var accentColor: Color
    var primaryTextColor: Color
    var secondaryTextColor: Color
    
    var body: some View {
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

// 操作按钮
struct ActionButtons: View {
    @Binding var isPrimaryButtonHovered: Bool
    @Binding var isSecondaryButtonHovered: Bool
    @Binding var microphoneChecked: Bool
    var accentColor: Color
    var onPrimaryAction: () -> Void
    var onSecondaryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 主按钮
            Button(action: onPrimaryAction) {
                Text("授权并开始")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 44)
                    .background(isPrimaryButtonHovered ? accentColor : accentColor)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            .onHover(perform: { hovering in
                isPrimaryButtonHovered = hovering
                if hovering {
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            })
            
            // 次按钮（仅当麦克风可选时显示）
            Button(action: onSecondaryAction) {
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
            .onHover(perform: { hovering in
                isSecondaryButtonHovered = hovering
                if hovering {
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            })
        }
        .padding(.bottom, 40)
    }
}

// 权限请求遮罩
struct PermissionOverlay: View {
    var body: some View {
        ZStack {
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