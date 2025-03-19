import SwiftUI

struct TranscriptionDisplayView: View {
    @State private var transcriptionText = "实时转录将在这里显示...\n\n开始录制后，您说的话将会被自动转录并显示在这里。"
    @Binding var selectedText: String
    @State private var showAIModal = false
    @State private var modalTitle = ""
    @State private var modalSystemImage = ""
    
    init(selectedText: Binding<String> = .constant("")) {
        self._selectedText = selectedText
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.orange)
                    
                    Text("实时转录")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("录制中")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(Color.red, lineWidth: 1)
                        )
                )
                
            }
            .padding(.horizontal)
            .padding(.top)
            
            // 转录内容
            VStack(alignment: .leading, spacing: 0) {
                // 工具栏
                HStack {
                    Button(action: {
                        modalTitle = "翻译"
                        modalSystemImage = "globe"
                        showAIModal = true
                    }) {
                        Label("翻译", systemImage: "globe")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        if !selectedText.isEmpty {
                            Button(action: {
                                modalTitle = "问一下"
                                modalSystemImage = "questionmark.circle"
                                showAIModal = true
                            }) {
                                Label("问一下", systemImage: "questionmark.circle")
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                        
                        Button(action: {
                            modalTitle = "生成摘要"
                            modalSystemImage = "list.bullet.clipboard"
                            showAIModal = true
                        }) {
                            Label("生成摘要", systemImage: "list.bullet.clipboard")
                        }
                        .buttonStyle(BorderedButtonStyle())
                        
                        Button(action: {
                            modalTitle = "提取关键点"
                            modalSystemImage = "text.badge.checkmark"
                            showAIModal = true
                        }) {
                            Label("提取关键点", systemImage: "text.badge.checkmark")
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                
                // 分隔线
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                
                // 文本内容
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(transcriptionText)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                            .onChange(of: NSPasteboard.general.string(forType: .string)) { newValue in
                                if let text = newValue {
                                    selectedText = text
                                }
                            }
                            .padding()
                    }
                }
                .background(Color(nsColor: .textBackgroundColor))
            }
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.2))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showAIModal) {
            AIInteractionModalView(
                title: modalTitle,
                systemImage: modalSystemImage,
                isPresented: $showAIModal
            )
        }
    }
}

#Preview {
    TranscriptionDisplayView()
}
