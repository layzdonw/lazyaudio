import SwiftUI

struct RecordingView: View {
    @State private var selectedAudioSource = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 标题
                HStack {
                    Text("新建录制")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // 音频源选择
                AudioSourceSelectionView(selectedSource: $selectedAudioSource)
                
                // 转录显示
                TranscriptionDisplayView()
                
                // 录制控制
                RecordingControlsView()
                
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(minWidth: 700, minHeight: 600)
    }
}

#Preview {
    RecordingView()
}