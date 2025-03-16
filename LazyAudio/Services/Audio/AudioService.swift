import Foundation
import Combine

/// 音频服务协议
/// 定义音频录制和播放的接口
protocol AudioServiceProtocol {
    /// 开始录制
    /// - Parameters:
    ///   - sourceType: 音频源类型
    ///   - appBundleId: 应用程序包标识符（仅在应用音频模式下使用）
    ///   - useMicrophone: 是否同时录制麦克风
    func startRecording(sourceType: AudioSourceType, appBundleId: String?, useMicrophone: Bool) -> AnyPublisher<AudioStatus, Error>
    
    /// 停止录制
    func stopRecording() -> AnyPublisher<URL, Error>
    
    /// 播放音频
    /// - Parameter url: 音频文件URL
    func playAudio(url: URL) -> AnyPublisher<AudioPlaybackStatus, Error>
    
    /// 暂停播放
    func pauseAudio()
    
    /// 停止播放
    func stopAudio()
    
}

/// 音频状态
enum AudioStatus {
    case preparing
    case recording(duration: TimeInterval)
    case paused
    case stopped
    case error(message: String)
}

/// 音频播放状态
enum AudioPlaybackStatus {
    case loading
    case playing(progress: Double, duration: TimeInterval)
    case paused(progress: Double)
    case stopped
    case finished
    case error(message: String)
}

/// 音频服务实现
class AudioService: AudioServiceProtocol {
    private var cancellables = Set<AnyCancellable>()
    
    func startRecording(sourceType: AudioSourceType, appBundleId: String?, useMicrophone: Bool) -> AnyPublisher<AudioStatus, Error> {
        // 实际实现中，这里应该调用系统API进行录音
        // 这里使用模拟数据
        let statusSubject = PassthroughSubject<AudioStatus, Error>()
        
        // 模拟准备阶段
        statusSubject.send(.preparing)
        
        // 模拟录制过程
        var duration: TimeInterval = 0
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
        timer.sink { [weak self] _ in
            guard let self = self else { return }
            
            duration += 1
            statusSubject.send(.recording(duration: duration))
        }
        .store(in: &cancellables)
        
        return statusSubject.eraseToAnyPublisher()
    }
    
    func stopRecording() -> AnyPublisher<URL, Error> {
        // 取消所有计时器
        cancellables.removeAll()
        
        // 模拟生成录音文件
        let resultSubject = PassthroughSubject<URL, Error>()
        
        // 模拟文件URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "recording_\(Date().timeIntervalSince1970).m4a"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        // 模拟延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            resultSubject.send(fileURL)
            resultSubject.send(completion: .finished)
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
    
    func playAudio(url: URL) -> AnyPublisher<AudioPlaybackStatus, Error> {
        // 实际实现中，这里应该调用系统API播放音频
        // 这里使用模拟数据
        let statusSubject = PassthroughSubject<AudioPlaybackStatus, Error>()
        
        // 模拟加载
        statusSubject.send(.loading)
        
        // 模拟播放过程
        let totalDuration: TimeInterval = 120 // 模拟2分钟的音频
        var currentTime: TimeInterval = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            
            timer.sink { [weak self] _ in
                guard let self = self else { return }
                
                currentTime += 0.1
                let progress = currentTime / totalDuration
                
                if currentTime >= totalDuration {
                    statusSubject.send(.finished)
                    statusSubject.send(completion: .finished)
                } else {
                    statusSubject.send(.playing(progress: progress, duration: currentTime))
                }
            }
            .store(in: &self.cancellables)
        }
        
        return statusSubject.eraseToAnyPublisher()
    }
    
    func pauseAudio() {
        // 取消播放计时器
        cancellables.removeAll()
    }
    
    func stopAudio() {
        // 取消播放计时器
        cancellables.removeAll()
    }
} 
