import SwiftUI

/// 设置选项类型
enum SettingsOptionType {
    case toggle(isOn: Binding<Bool>)
    case picker(selection: Binding<String>, options: [String])
    case button(action: () -> Void)
    case slider(value: Binding<Double>, range: ClosedRange<Double>, step: Double)
}

/// 设置选项组件
/// 用于显示单个设置选项
struct SettingsOptionView: View {
    let title: String
    let description: String?
    let type: SettingsOptionType
    
    init(title: String, description: String? = nil, type: SettingsOptionType) {
        self.title = title
        self.description = description
        self.type = type
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                    
                    if let description = description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 根据类型显示不同的控件
                switch type {
                case .toggle(let isOn):
                    Toggle("", isOn: isOn)
                        .labelsHidden()
                
                case .picker(let selection, let options):
                    Picker("", selection: selection) {
                        ForEach(options, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 150)
                
                case .button(let action):
                    Button("设置", action: action)
                        .buttonStyle(BorderedButtonStyle())
                
                case .slider(let value, let range, let step):
                    HStack {
                        Text("\(Int(range.lowerBound))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: value, in: range, step: step)
                            .frame(width: 100)
                        
                        Text("\(Int(range.upperBound))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
                .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        SettingsOptionView(
            title: "启用深色模式",
            description: "切换应用的外观主题",
            type: .toggle(isOn: .constant(true))
        )
        
        SettingsOptionView(
            title: "语言选择",
            description: "选择应用界面语言",
            type: .picker(selection: .constant("简体中文"), options: ["简体中文", "English", "日本語"])
        )
        
        SettingsOptionView(
            title: "清除缓存",
            description: "删除所有临时文件",
            type: .button(action: {})
        )
        
        SettingsOptionView(
            title: "音量调节",
            description: "调整播放音量",
            type: .slider(value: .constant(50), range: 0...100, step: 1)
        )
    }
    .padding()
    .frame(width: 400)
} 