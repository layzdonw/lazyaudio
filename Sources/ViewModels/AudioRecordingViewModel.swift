import Foundation
import SwiftUI

enum AudioSourceType {
    case microphone
    case systemAudio
    case appAudio(pid: pid_t)
}

@Observable
final class AudioRecordingViewModel {
    private let recordingService: AudioRecordingService
    private(set) var isRecording = false
    private(set) var errorMessage: String?
    private(set) var runningApps: [NSRunningApplication] = []
    
    var audioSourceType: AudioSourceType = .microphone
    var selectedApp: NSRunningApplication?
    var useMicrophone: Bool = true
    
    init(recordingService: AudioRecordingService = AudioRecordingService()) {
        self.recordingService = recordingService
    }
    
    func loadRunningApps() {
        runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
    }
    
    func startRecording() {
        do {
            let sourceType: AudioSourceType
            if useMicrophone {
                sourceType = .microphone
            } else if let app = selectedApp {
                sourceType = .appAudio(pid: app.processIdentifier)
            } else {
                sourceType = .systemAudio
            }
            
            try recordingService.startRecording(sourceType: sourceType)
            isRecording = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func stopRecording() {
        recordingService.stopRecording()
        isRecording = false
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    var canStartRecording: Bool {
        if useMicrophone {
            return true
        } else if selectedApp != nil {
            return true
        } else {
            return true // 系统音频录制
        }
    }
} 