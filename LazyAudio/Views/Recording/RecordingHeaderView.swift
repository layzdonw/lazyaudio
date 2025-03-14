import SwiftUI

/// 录音头部视图
/// 显示标题和录音状态
struct RecordingHeaderView: View {
    let isRecording: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("实时转录")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("选择音频源并开始录制")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 录制状态
            if isRecording {
                RecordingStatusBadge()
            }
        }
    }
}

/// 录音状态徽章
/// 显示当前录音状态
struct RecordingStatusBadge: View {
    var body: some View {
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
}

#Preview {
    VStack {
        RecordingHeaderView(isRecording: false)
        RecordingHeaderView(isRecording: true)
    }
    .padding()
} 