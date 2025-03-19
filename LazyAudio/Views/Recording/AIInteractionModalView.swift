import SwiftUI

struct AIInteractionModalView: View {
    let title: String
    let systemImage: String
    @Binding var isPresented: Bool
    @State private var userInput: String = ""
    @State private var isLoading: Bool = false
    @State private var response: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题栏
            HStack {
                Label(title, systemImage: systemImage)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            // 输入区域
            TextEditor(text: $userInput)
                .frame(height: 100)
                .padding(8)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(8)
            
            // 发送按钮
            Button(action: sendRequest) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("发送")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || userInput.isEmpty)
            
            // 响应区域
            if !response.isEmpty {
                ScrollView {
                    Text(response)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
    
    private func sendRequest() {
        isLoading = true
        // TODO: 实现 AI 请求逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            response = "这是 AI 的响应示例..."
            isLoading = false
        }
    }
} 