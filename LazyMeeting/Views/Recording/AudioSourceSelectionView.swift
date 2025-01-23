import SwiftUI

struct AudioSourceSelectionView: View {
    @Binding var selectedSource: Int
    @State private var selectedApp = 0
    
    var body: some View {
        HStack {
            Picker("Audio Source", selection: $selectedSource) {
                Text("System Audio").tag(0)
                Text("Application Audio").tag(1)
                Text("Microphone").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if selectedSource == 1 {
                Picker("Select App", selection: $selectedApp) {
                    Text("App 1").tag(0)
                    Text("App 2").tag(1)
                }
            }
        }
        .padding()
    }
}