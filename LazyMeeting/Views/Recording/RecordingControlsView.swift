import SwiftUI

struct RecordingControlsView: View {
    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 16) {
            // 录制时间显示
            HStack {
                Text(formattedTime(recordingDuration))
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(isRecording ? .red : .secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                
                Spacer()
                
                if isRecording {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("录制中")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .stroke(Color.red, lineWidth: 1)
                    )
                }
            }
            
            // 控制按钮
            HStack(spacing: 24) {
                Spacer()
                
                Button(action: {
                    toggleRecording()
                }) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red.opacity(0.1) : Color.accentColor.opacity(0.1))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: isRecording ? "stop.fill" : "record.circle")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(isRecording ? .red : .accentColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Circle())
                .help(isRecording ? "停止录制" : "开始录制")
                
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