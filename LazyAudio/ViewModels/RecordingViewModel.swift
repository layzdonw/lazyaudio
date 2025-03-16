import SwiftUI
import Combine

/// 录音视图模型
/// 管理录音相关的状态和业务逻辑
class RecordingViewModel: ObservableObject {
    // 音频源设置
    @Published var audioSourceType: AudioSourceType = .systemAudio
    @Published var selectedApp: String = ""
    @Published var useMicrophone: Bool = false
    
    // 录音状态
    @Published var isRecording: Bool = false
    @Published var showTranscription: Bool = false
    @Published var selectedText: String = ""
    
    // 应用列表
    @Published var runningApps: [AppModels.RunningApp] = []
    
    // 计算属性
    var canStartRecording: Bool {
        if audioSourceType == .appAudio && selectedApp.isEmpty {
            return false
        }
        return true
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // 当录音状态改变时，更新转录显示状态
        $isRecording
            .sink { [weak self] isRecording in
                if isRecording {
                    self?.showTranscription = true
                }
            }
            .store(in: &cancellables)
        
        // 当音频源类型改变时，如果是应用音频则重新加载应用列表
        $audioSourceType
            .sink { [weak self] sourceType in
                if sourceType == .appAudio {
                    self?.loadRunningApps()
                }
            }
            .store(in: &cancellables)
    }
    
    /// 加载运行中的应用
    func loadRunningApps() {
        // 清空现有列表并重新获取
        runningApps = []
        DispatchQueue.main.async {
            self.runningApps = AppModels.getRunningApps()
        }
    }
    
    /// 开始或停止录音
    func toggleRecording() {
        if !canStartRecording && !isRecording {
            return // 如果不能开始录制且当前未录制，则不执行操作
        }
        
        isRecording.toggle()
        
        if isRecording {
            // 开始录音的逻辑
            startRecording()
        } else {
            // 停止录音的逻辑
            stopRecording()
        }
    }
    
    private func startRecording() {
        // 实现开始录音的具体逻辑
        print("开始录音: 音频源=\(audioSourceType), 应用=\(selectedApp), 麦克风=\(useMicrophone)")
    }
    
    private func stopRecording() {
        // 实现停止录音的具体逻辑
        print("停止录音")
    }
} 
