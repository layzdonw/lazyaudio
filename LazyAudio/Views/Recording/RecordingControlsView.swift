import SwiftUI

/// 录音控制组件
/// 包含开始/停止录制按钮
struct RecordingControlsView: View {
    @Binding var isRecording: Bool
    var canStartRecording: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            // 录制按钮
            Button(action: {
                if !canStartRecording && !isRecording {
                    return // 如果不能开始录制且当前未录制，则不执行操作
                }
                isRecording.toggle()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isRecording ? "stop.fill" : "record.circle.fill")
                        .font(.system(size: 16))
                    
                    Text(isRecording ? "停止录制" : "开始录制")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isRecording ? Color.red : Color.accentColor)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canStartRecording && !isRecording)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        RecordingControlsView(isRecording: .constant(false), canStartRecording: true)
        RecordingControlsView(isRecording: .constant(true), canStartRecording: true)
        RecordingControlsView(isRecording: .constant(false), canStartRecording: false)
    }
    .padding()
}