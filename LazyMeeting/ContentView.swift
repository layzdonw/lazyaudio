import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Recording View
            VStack {
                // Audio Source Selection
                HStack {
                    Picker("Audio Source", selection: .constant(0)) {
                        Text("System Audio").tag(0)
                        Text("Application Audio").tag(1)
                        Text("Microphone").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Application Selector (when Application Audio is selected)
                    if selectedTab == 1 {
                        Picker("Select App", selection: .constant(0)) {
                            Text("App 1").tag(0)
                            Text("App 2").tag(1)
                        }
                    }
                }
                .padding()
                
                // Transcription Display
                ScrollView {
                    Text("Real-time transcription will appear here...")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .background(Color(nsColor: .windowBackgroundColor))
                .cornerRadius(8)
                .padding()
                
                // Recording Controls
                HStack {
                    Button(action: {}) {
                        Image(systemName: "record.circle")
                            .font(.largeTitle)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "stop.circle")
                            .font(.largeTitle)
                    }
                }
                .padding()
            }
            .tabItem {
                Label("Record", systemImage: "mic")
            }
            .tag(0)
            
            // History View
            List {
                Section(header: Text("Recordings")) {
                    ForEach(0..<5) { _ in
                        NavigationLink {
                            RecordingDetailView()
                        } label: {
                            VStack(alignment: .leading) {
                                Text("Recording Title")
                                    .font(.headline)
                                Text("Date and Duration")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
            .tag(1)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

struct RecordingDetailView: View {
    var body: some View {
        VStack {
            // Audio Player
            HStack {
                Button(action: {}) {
                    Image(systemName: "play.circle")
                        .font(.largeTitle)
                }
                
                Slider(value: .constant(0.5))
                    .padding()
                
                Text("00:00 / 00:00")
            }
            .padding()
            
            // Transcript and AI Features
            TabView {
                ScrollView {
                    Text("Full transcript text goes here...")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .tabItem {
                    Label("Transcript", systemImage: "text.alignleft")
                }
                
                VStack {
                    Text("AI Summary")
                        .font(.title)
                        .padding()
                    
                    Text("Summary of the transcript will appear here...")
                        .padding()
                    
                    Spacer()
                    
                    // AI Chat
                    VStack {
                        ScrollView {
                            Text("Chat history with AI...")
                        }
                        
                        HStack {
                            TextField("Ask AI...", text: .constant(""))
                            Button(action: {}) {
                                Image(systemName: "arrow.up.circle")
                            }
                        }
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }
                .tabItem {
                    Label("AI", systemImage: "brain")
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
