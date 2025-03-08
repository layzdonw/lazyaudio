import SwiftUI

struct RecordingControlsView: View {
    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showScheduleOptions = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 顶部控制栏
            HStack {
                // 录制时间显示
                HStack(spacing: 10) {
                    Image(systemName: "clock")
                        .font(.system(size: 18))
                        .foregroundColor(isRecording ? .red : .secondary)
                    
                    Text(formattedTime(recordingDuration))
                        .font(.system(.title2, design: .monospaced))
                        .foregroundColor(isRecording ? .red : .secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                
                Spacer()
                
                // 录制状态
                if isRecording {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("录制中")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    )
                }
                
                // 录制选项
                Menu {
                    Button(action: { showScheduleOptions.toggle() }) {
                        Label("定时录制", systemImage: "calendar")
                    }
                    
                    Button(action: {}) {
                        Label("自动停止条件", systemImage: "timer")
                    }
                    
                    Divider()
                    
                    Button(action: {}) {
                        Label("录制设置", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(Circle())
                }
            }
            
            // 定时录制选项
            if showScheduleOptions {
                HStack(spacing: 20) {
                    DatePicker("开始时间", selection: .constant(Date()), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .frame(width: 200)
                    
                    Picker("持续时间", selection: .constant(60)) {
                        Text("30 分钟").tag(30)
                        Text("1 小时").tag(60)
                        Text("2 小时").tag(120)
                        Text("自定义").tag(-1)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                    
                    Button("设置") {
                        showScheduleOptions = false
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .cornerRadius(8)
            }
            
            // 主要控制按钮
            HStack(spacing: 30) {
                Spacer()
                
                // 录制按钮
                Button(action: {
                    toggleRecording()
                }) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red.opacity(0.1) : Color.accentColor.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .stroke(isRecording ? Color.red : Color.accentColor, lineWidth: 3)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: isRecording ? "stop.fill" : "record.circle")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(isRecording ? .red : .accentColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Circle())
                .keyboardShortcut(.return, modifiers: [])
                .help(isRecording ? "停止录制 (Return)" : "开始录制 (Return)")
                
                Spacer()
            }
            .padding(.vertical, 10)
            
            // 底部提示
            HStack {
                Spacer()
                
                if isRecording {
                    Text("按下 Return 键停止录制")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("按下 Return 键开始录制")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .windowBackgroundColor))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding()
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        
        if isRecording {
            // 开始计时
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                recordingDuration += 1
            }
        } else {
            // 停止计时
            timer?.invalidate()
            timer = nil
            recordingDuration = 0
        }
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    RecordingControlsView()
}