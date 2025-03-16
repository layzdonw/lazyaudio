import SwiftUI

/// 录音头部视图
/// 显示标题和录音状态
struct RecordingHeaderView: View {
    let isRecording: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                LocalizedText(key: "recording.title", font: .title2.bold())
                    .foregroundColor(.primary)
                
                LocalizedText(key: "recording.subtitle", font: .subheadline)
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
            LocalizedText(key: "recording.status", font: .subheadline.weight(.medium))
                .foregroundColor(.red)
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