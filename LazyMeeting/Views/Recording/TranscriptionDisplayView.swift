import SwiftUI

struct TranscriptionDisplayView: View {
    @State private var transcriptionText = "实时转录将在这里显示...\n\n开始录制后，您说的话将会被自动转录并显示在这里。"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("实时转录")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                    Text("未录制")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ScrollView {
                Text(transcriptionText)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .frame(minHeight: 200)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding()
    }
}

#Preview {
    TranscriptionDisplayView()
}