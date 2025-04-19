import Foundation
import Combine
import AVFoundation
import AudioToolbox
import OSLog
import AppKit
import UniformTypeIdentifiers
import Darwin

/// 音频源类型
enum AudioSourceType: Int {
    case systemAudio = 0
    case appAudio = 1
    case microphone = 2
}

/// 音频处理插件协议
protocol AudioProcessingPlugin {
    func process(buffer: AVAudioPCMBuffer, format: AVAudioFormat) -> AVAudioPCMBuffer
}

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
    
    /// 添加音频处理插件
    func addProcessingPlugin(_ plugin: AudioProcessingPlugin)
    
    /// 移除所有音频处理插件
    func removeAllProcessingPlugins()
    
    /// 获取当前运行的应用列表
    func getRunningApps() -> [AppModels.RunningApp]
    
    /// 刷新应用和音频进程列表
    func refreshAudioProcesses()
    
    /// 获取所有音频进程
    var audioProcesses: [AudioProcess] { get }
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

/// 错误扩展
extension String: Error, LocalizedError {
    public var errorDescription: String? { self }
}

/// 音频对象ID扩展
extension AudioObjectID {
    static let system = AudioObjectID(kAudioObjectSystemObject)
    static let unknown = kAudioObjectUnknown
    
    var isUnknown: Bool { self == .unknown }
    var isValid: Bool { !isUnknown }
    
    static func readProcessList() throws -> [AudioObjectID] {
        try AudioObjectID.system.readProcessList()
    }
    
    func readProcessList() throws -> [AudioObjectID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyProcessObjectList,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        var err = AudioObjectGetPropertyDataSize(self, &address, 0, nil, &dataSize)
        guard err == noErr else { throw "获取进程列表数据大小错误: \(err)" }
        
        var value = [AudioObjectID](repeating: .unknown, count: Int(dataSize) / MemoryLayout<AudioObjectID>.size)
        err = AudioObjectGetPropertyData(self, &address, 0, nil, &dataSize, &value)
        guard err == noErr else { throw "获取进程列表数据错误: \(err)" }
        
        return value.filter { $0.isValid }
    }
    
    /// 获取当前运行的具有音频功能的进程列表
    static func readAudioProcessesFromCurrentlyRunningProcesses() throws -> [AudioObjectID] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyProcessObjectList,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var propertySize: UInt32 = 0
        var err = AudioObjectGetPropertyDataSize(
            AudioObjectID.system,
            &address,
            0, 
            nil,
            &propertySize
        )
        
        guard err == noErr else {
            throw "获取音频进程列表大小错误: \(err)"
        }
        
        let processCount = Int(propertySize) / MemoryLayout<AudioObjectID>.size
        var processIDs = [AudioObjectID](repeating: 0, count: processCount)
        
        err = AudioObjectGetPropertyData(
            AudioObjectID.system,
            &address,
            0,
            nil,
            &propertySize,
            &processIDs
        )
        
        guard err == noErr else {
            throw "获取音频进程列表错误: \(err)"
        }
        
        return processIDs.filter { $0.isValid }
    }
    
    static func translatePIDToAudioObjectID(pid: pid_t) throws -> AudioObjectID {
        try AudioObjectID.system.translatePIDToAudioObjectID(pid: pid)
    }
    
    func translatePIDToAudioObjectID(pid: pid_t) throws -> AudioObjectID {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyTranslatePIDToProcessObject,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var qualifierPid = pid
        let qualifierSize = UInt32(MemoryLayout<pid_t>.size)
        var dataSize = UInt32(MemoryLayout<AudioObjectID>.size)
        var objectID = AudioObjectID.unknown
        
        let err = AudioObjectGetPropertyData(
            self,
            &address,
            qualifierSize,
            &qualifierPid,
            &dataSize,
            &objectID
        )
        
        guard err == noErr else { throw "获取进程音频对象ID错误: \(err)" }
        guard objectID.isValid else { throw "无效的进程ID: \(pid)" }
        
        return objectID
    }
    
    func readProcessBundleID() -> String? {
        if let result = try? readString(kAudioProcessPropertyBundleID) {
            return result.isEmpty ? nil : result
        }
        return nil
    }
    
    /// 检查进程是否正在产生音频
    func readProcessIsRunning() -> Bool {
        (try? readBool(kAudioProcessPropertyIsRunning)) ?? false
    }
    
    /// 读取进程的PID
    func readProcessPID() -> pid_t? {
        try? read(kAudioProcessPropertyPID, defaultValue: -1)
    }
    
    func readBool(_ selector: AudioObjectPropertySelector) throws -> Bool {
        let value: UInt32 = try read(selector, defaultValue: 0)
        return value == 1
    }
    
    func read<T>(_ selector: AudioObjectPropertySelector, defaultValue: T) throws -> T {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        var err = AudioObjectGetPropertyDataSize(self, &address, 0, nil, &dataSize)
        guard err == noErr else { throw "获取属性数据大小错误: \(err)" }
        
        var value: T = defaultValue
        err = AudioObjectGetPropertyData(self, &address, 0, nil, &dataSize, &value)
        guard err == noErr else { throw "获取属性数据错误: \(err)" }
        
        return value
    }
    
    func readString(_ selector: AudioObjectPropertySelector) throws -> String {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var dataSize: UInt32 = 0
        var err = AudioObjectGetPropertyDataSize(self, &address, 0, nil, &dataSize)
        guard err == noErr else { throw "获取字符串数据大小错误: \(err)" }
        
        var value: CFString = "" as CFString
        err = AudioObjectGetPropertyData(self, &address, 0, nil, &dataSize, &value)
        guard err == noErr else { throw "获取字符串数据错误: \(err)" }
        
        return value as String
    }
}

/// 进程信息模型
struct AudioProcess: Identifiable, Hashable {
    let id: pid_t
    let objectID: AudioObjectID
    let bundleID: String?
    let name: String
    let path: String?
    let isApp: Bool
    let audioActive: Bool
    
    init(objectID: AudioObjectID) throws {
        self.objectID = objectID
        
        // 获取进程ID
        guard let pid = objectID.readProcessPID() else {
            throw "无法获取进程ID"
        }
        self.id = pid
        
        // 获取BundleID
        self.bundleID = objectID.readProcessBundleID()
        
        // 获取进程音频活动状态
        self.audioActive = objectID.readProcessIsRunning()
        
        // 获取进程信息
        if let (procName, procPath) = processInfo(for: pid) {
            self.name = procName
            self.path = procPath
            
            // 检查是否为应用
            let url = URL(fileURLWithPath: procPath)
            self.isApp = url.pathExtension.lowercased() == "app"
        } else if let bundleID = self.bundleID, let lastComponent = bundleID.components(separatedBy: ".").last {
            self.name = lastComponent
            self.path = nil
            self.isApp = bundleID.contains(".app.")
        } else {
            self.name = "未知进程 (\(pid))"
            self.path = nil
            self.isApp = false
        }
    }
    
    init(app: NSRunningApplication, audioObjectID: AudioObjectID) {
        self.id = app.processIdentifier
        self.objectID = audioObjectID
        self.bundleID = app.bundleIdentifier
        self.name = app.localizedName ?? "未知应用"
        self.path = app.bundleURL?.path
        self.isApp = true
        self.audioActive = audioObjectID.readProcessIsRunning()
    }
    
    static func == (lhs: AudioProcess, rhs: AudioProcess) -> Bool {
        lhs.id == rhs.id && lhs.objectID == rhs.objectID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(objectID)
    }
}

/// 获取进程的名称和路径
private func processInfo(for pid: pid_t) -> (name: String, path: String)? {
    let nameBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))
    let pathBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))
    
    defer {
        nameBuffer.deallocate()
        pathBuffer.deallocate()
    }
    
    let nameLength = proc_name(pid, nameBuffer, UInt32(MAXPATHLEN))
    let pathLength = proc_pidpath(pid, pathBuffer, UInt32(MAXPATHLEN))
    
    guard nameLength > 0, pathLength > 0 else {
        return nil
    }
    
    let name = String(cString: nameBuffer)
    let path = String(cString: pathBuffer)
    
    return (name, path)
}

/// 音频捕获控制器
class AudioCaptureController {
    private let processTapID: AudioObjectID
    private let aggregateDeviceID: AudioObjectID
    private var deviceProcID: AudioDeviceIOProcID?
    private var tapStreamDescription: AudioStreamBasicDescription
    private var isRunning = false
    private let logger = Logger(subsystem: "com.lazyaudio", category: "AudioCaptureController")
    
    init(audioObjectID: AudioObjectID, muteWhenRunning: Bool = false) throws {
        // 创建进程捕获描述
        let tapDescription = CATapDescription(stereoMixdownOfProcesses: [audioObjectID])
        tapDescription.uuid = UUID()
        tapDescription.muteBehavior = muteWhenRunning ? .mutedWhenTapped : .unmuted
        
        var tapID: AudioObjectID = .unknown
        var err = AudioHardwareCreateProcessTap(tapDescription, &tapID)
        guard err == noErr else { throw "创建进程捕获失败: \(err)" }
        
        self.processTapID = tapID
        
        // 获取系统输出设备ID
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultSystemOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var systemOutputID: AudioDeviceID = .unknown
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        err = AudioObjectGetPropertyData(AudioObjectID.system, &address, 0, nil, &dataSize, &systemOutputID)
        guard err == noErr else { throw "获取默认输出设备失败: \(err)" }
        
        // 获取输出设备UID
        address.mSelector = kAudioDevicePropertyDeviceUID
        var outputUID: CFString = "" as CFString
        dataSize = UInt32(MemoryLayout<CFString>.size)
        err = AudioObjectGetPropertyData(systemOutputID, &address, 0, nil, &dataSize, &outputUID)
        guard err == noErr else { throw "获取输出设备UID失败: \(err)" }
        
        // 创建聚合设备
        let aggregateUID = UUID().uuidString
        let description: [String: Any] = [
            kAudioAggregateDeviceNameKey: "LazyAudio-\(audioObjectID)",
            kAudioAggregateDeviceUIDKey: aggregateUID,
            kAudioAggregateDeviceMainSubDeviceKey: outputUID,
            kAudioAggregateDeviceIsPrivateKey: true,
            kAudioAggregateDeviceIsStackedKey: false,
            kAudioAggregateDeviceTapAutoStartKey: true,
            kAudioAggregateDeviceSubDeviceListKey: [
                [
                    kAudioSubDeviceUIDKey: outputUID
                ]
            ],
            kAudioAggregateDeviceTapListKey: [
                [
                    kAudioSubTapDriftCompensationKey: true,
                    kAudioSubTapUIDKey: tapDescription.uuid.uuidString
                ]
            ]
        ]
        
        // 获取捕获流格式描述
        address.mSelector = kAudioTapPropertyFormat
        var streamDescription = AudioStreamBasicDescription()
        dataSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        err = AudioObjectGetPropertyData(tapID, &address, 0, nil, &dataSize, &streamDescription)
        guard err == noErr else { throw "获取捕获流格式失败: \(err)" }
        
        self.tapStreamDescription = streamDescription
        
        var aggDeviceID = AudioObjectID.unknown
        err = AudioHardwareCreateAggregateDevice(description as CFDictionary, &aggDeviceID)
        guard err == noErr else { throw "创建聚合设备失败: \(err)" }
        
        self.aggregateDeviceID = aggDeviceID
        self.deviceProcID = nil
    }
    
    func start(bufferHandler: @escaping (UnsafePointer<AudioBufferList>, AVAudioFormat) -> Void) throws {
        guard !isRunning else { return }
        
        let format = AVAudioFormat(streamDescription: &tapStreamDescription)
        guard let audioFormat = format else { throw "创建音频格式失败" }
        
        logger.info("使用音频格式: \(audioFormat.sampleRate)Hz, \(audioFormat.channelCount)通道")
        
        let captureQueue = DispatchQueue(label: "com.lazyaudio.captureQueue", qos: .userInitiated)
        
        var deviceProcIDCopy: AudioDeviceIOProcID?
        let err = AudioDeviceCreateIOProcIDWithBlock(&deviceProcIDCopy, aggregateDeviceID, captureQueue) { inNow, inInputData, inInputTime, outOutputData, inOutputTime in
            if let format = format {
                bufferHandler(inInputData, format)
            }
        }
        
        guard err == noErr else { throw "创建IO处理失败: \(err)" }
        
        self.deviceProcID = deviceProcIDCopy
        
        let startErr = AudioDeviceStart(aggregateDeviceID, deviceProcID)
        guard startErr == noErr else { throw "启动音频设备失败: \(startErr)" }
        
        isRunning = true
    }
    
    func stop() {
        guard isRunning, let deviceProcID = deviceProcID else { return }
        
        let err = AudioDeviceStop(aggregateDeviceID, deviceProcID)
        if err != noErr {
            logger.warning("停止音频设备失败: \(err)")
        }
        
        isRunning = false
    }
    
    deinit {
        if let deviceProcID = deviceProcID {
            if isRunning {
                AudioDeviceStop(aggregateDeviceID, deviceProcID)
            }
            AudioDeviceDestroyIOProcID(aggregateDeviceID, deviceProcID)
        }
        
        let _ = AudioHardwareDestroyAggregateDevice(aggregateDeviceID)
        let _ = AudioHardwareDestroyProcessTap(processTapID)
    }
}

/// 音频服务实现
class AudioService: AudioServiceProtocol {
    private let logger = Logger(subsystem: "com.lazyaudio", category: "AudioService")
    private var audioCapture: AudioCaptureController?
    private var currentRecordingFile: AVAudioFile?
    private var recordingStatusSubject = PassthroughSubject<AudioStatus, Error>()
    private var playbackStatusSubject = PassthroughSubject<AudioPlaybackStatus, Error>()
    private var cancellables = Set<AnyCancellable>()
    private var recordingTimer: AnyCancellable?
    private var recordingStartTime: Date?
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: AnyCancellable?
    private var processingPlugins: [AudioProcessingPlugin] = []
    
    // 添加进程控制器
    private let processController: AudioProcessController
    
    init() {
        self.processController = AudioProcessController()
        processController.startObserving()
    }
    
    func addProcessingPlugin(_ plugin: AudioProcessingPlugin) {
        processingPlugins.append(plugin)
    }
    
    func removeAllProcessingPlugins() {
        processingPlugins.removeAll()
    }
    
    func startRecording(sourceType: AudioSourceType, appBundleId: String?, useMicrophone: Bool) -> AnyPublisher<AudioStatus, Error> {
        // 重置之前的状态
        stopRecording().sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &cancellables)
        
        recordingStatusSubject = PassthroughSubject<AudioStatus, Error>()
        recordingStartTime = Date()
        
        // 准备阶段
        recordingStatusSubject.send(.preparing)
        
        do {
            switch sourceType {
            case .systemAudio:
                try startSystemAudioRecording()
            case .appAudio:
                guard let bundleId = appBundleId else {
                    throw "应用音频录制需要提供bundleID"
                }
                try startAppAudioRecording(bundleId: bundleId)
            case .microphone:
                // 实现预留
                recordingStatusSubject.send(.error(message: "麦克风录制功能暂未实现"))
                recordingStatusSubject.send(completion: .failure("麦克风录制功能暂未实现"))
            }
            
            // 启动录制计时器
            startRecordingTimer()
            
        } catch {
            recordingStatusSubject.send(.error(message: error.localizedDescription))
            recordingStatusSubject.send(completion: .failure(error))
        }
        
        return recordingStatusSubject.eraseToAnyPublisher()
    }
    
    func stopRecording() -> AnyPublisher<URL, Error> {
        let resultSubject = PassthroughSubject<URL, Error>()
        
        // 停止计时器
        recordingTimer?.cancel()
        recordingTimer = nil
        
        // 停止录制
        audioCapture?.stop()
        audioCapture = nil
        
        // 关闭文件
        let fileURL = currentRecordingFile?.url ?? URL(fileURLWithPath: "")
        currentRecordingFile = nil
        
        if fileURL.path.isEmpty {
            resultSubject.send(completion: .failure("没有录制文件"))
        } else {
            resultSubject.send(fileURL)
            resultSubject.send(completion: .finished)
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
    
    func playAudio(url: URL) -> AnyPublisher<AudioPlaybackStatus, Error> {
        // 停止之前的播放
        stopAudio()
        
        playbackStatusSubject = PassthroughSubject<AudioPlaybackStatus, Error>()
        
        // 加载状态
        playbackStatusSubject.send(.loading)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            
            guard let player = audioPlayer else {
                throw "创建音频播放器失败"
            }
            
            let totalDuration = player.duration
            
            player.play()
            
            // 启动播放计时器
            playbackTimer = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self, let player = self.audioPlayer else { return }
                    
                    let progress = player.currentTime / totalDuration
                    
                    if !player.isPlaying && player.currentTime >= totalDuration - 0.1 {
                        self.playbackStatusSubject.send(.finished)
                        self.playbackStatusSubject.send(completion: .finished)
                        self.playbackTimer?.cancel()
                    } else {
                        self.playbackStatusSubject.send(.playing(progress: progress, duration: player.currentTime))
                    }
                }
            
        } catch {
            playbackStatusSubject.send(.error(message: error.localizedDescription))
            playbackStatusSubject.send(completion: .failure(error))
        }
        
        return playbackStatusSubject.eraseToAnyPublisher()
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        
        if let player = audioPlayer {
            let progress = player.currentTime / player.duration
            playbackStatusSubject.send(.paused(progress: progress))
        }
        
        playbackTimer?.cancel()
        playbackTimer = nil
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        
        playbackStatusSubject.send(.stopped)
        
        playbackTimer?.cancel()
        playbackTimer = nil
    }
    
    // MARK: - 私有方法
    
    private func startSystemAudioRecording() throws {
        logger.info("开始录制系统音频")
        
        // 尝试从进程控制器获取系统音频进程
        guard let systemProcess = processController.systemAudioProcess else {
            // 如果找不到，刷新一次再尝试
            processController.refreshAudioProcesses()
            
            if let process = processController.systemAudioProcess {
                try setupAudioCapture(audioObjectID: process.objectID, isSystem: true)
            } else {
                throw "无法找到系统音频对象，请检查系统音频是否正常"
            }
            return
        }
        
        try setupAudioCapture(audioObjectID: systemProcess.objectID, isSystem: true)
    }
    
    private func startAppAudioRecording(bundleId: String) throws {
        logger.info("开始录制应用音频，bundleID: \(bundleId)")
        
        do {
            // 使用进程控制器获取应用的音频对象ID
            let audioObjectID = try processController.getAudioObjectIDForApp(bundleID: bundleId)
            try setupAudioCapture(audioObjectID: audioObjectID, isSystem: false)
        } catch {
            logger.error("获取应用音频对象失败: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func setupAudioCapture(audioObjectID: AudioObjectID, isSystem: Bool) throws {
        // 创建录制文件
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "recording_\(Date().timeIntervalSince1970).m4a"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        // 创建音频捕获控制器
        audioCapture = try AudioCaptureController(audioObjectID: audioObjectID)
        
        // 启动音频捕获
        try audioCapture?.start { [weak self] bufferList, format in
            guard let self = self else { return }
            
            do {
                // 如果还没有创建录制文件，创建它
                if self.currentRecordingFile == nil {
                    let settings: [String: Any] = [
                        AVFormatIDKey: kAudioFormatMPEG4AAC,
                        AVSampleRateKey: format.sampleRate,
                        AVNumberOfChannelsKey: format.channelCount,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]
                    
                    self.currentRecordingFile = try AVAudioFile(forWriting: fileURL, settings: settings)
                }
                
                // 转换缓冲区
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, bufferListNoCopy: bufferList, deallocator: nil) else {
                    self.logger.error("创建PCM缓冲区失败")
                    return
                }
                
                // 应用处理插件
                var processedBuffer = buffer
                for plugin in self.processingPlugins {
                    processedBuffer = plugin.process(buffer: processedBuffer, format: format)
                }
                
                // 写入文件
                try self.currentRecordingFile?.write(from: processedBuffer)
                
            } catch {
                self.logger.error("录制过程中出错: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.recordingStatusSubject.send(.error(message: error.localizedDescription))
                }
            }
        }
    }
    
    private func startRecordingTimer() {
        recordingTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let startTime = self.recordingStartTime else { return }
                
                let duration = Date().timeIntervalSince(startTime)
                self.recordingStatusSubject.send(.recording(duration: duration))
            }
    }
    
    func getRunningApps() -> [AppModels.RunningApp] {
        processController.runningApps
    }
    
    func refreshAudioProcesses() {
        processController.refreshAudioProcesses()
    }
    
    var audioProcesses: [AudioProcess] {
        processController.processes
    }
}

// MARK: - 辅助结构体

/// CoreAudio捕获描述类
class CATapDescription {
    var uuid = UUID()
    var processes: [AudioObjectID]
    var muteBehavior: MuteBehavior = .unmuted
    
    enum MuteBehavior {
        case unmuted
        case mutedWhenTapped
    }
    
    init(stereoMixdownOfProcesses processes: [AudioObjectID]) {
        self.processes = processes
    }
}

/// AudioHardwareCreateProcessTap 函数封装
func AudioHardwareCreateProcessTap(_ description: CATapDescription, _ tapID: UnsafeMutablePointer<AudioObjectID>) -> OSStatus {
    // 这里是对私有API的封装调用
    let tapDescription: [String: Any] = [
        "uuid": description.uuid.uuidString,
        "processes": description.processes,
        "stereoMixdown": true,
        "muteWhenTapped": description.muteBehavior == .mutedWhenTapped
    ]
    
    return AudioHardwareCreateProcessTapImpl(tapDescription as CFDictionary, tapID)
}

/// 私有API调用函数声明
@_silgen_name("AudioHardwareCreateProcessTap")
func AudioHardwareCreateProcessTapImpl(_ description: CFDictionary, _ tapID: UnsafeMutablePointer<AudioObjectID>) -> OSStatus

@_silgen_name("AudioHardwareDestroyProcessTap")
func AudioHardwareDestroyProcessTap(_ tapID: AudioObjectID) -> OSStatus

/// 应用音频进程控制器
class AudioProcessController {
    private let logger = Logger(subsystem: "com.lazyaudio", category: "AudioProcessController")
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    
    private(set) var processes = [AudioProcess]()
    private(set) var runningApps = [AppModels.RunningApp]()
    private(set) var isObserving = false
    
    // 过滤后的进程
    var appProcesses: [AudioProcess] {
        processes.filter { $0.isApp }
    }
    
    var systemAudioProcess: AudioProcess? {
        processes.first { process in
            process.bundleID == "com.apple.audio.coreaudio"
        }
    }
    
    func startObserving() {
        guard !isObserving else { return }
        isObserving = true
        
        // 设置进程刷新计时器，每3秒刷新一次
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.refreshAudioProcesses()
        }
        
        // 监听应用程序启动和退出
        NSWorkspace.shared
            .publisher(for: \.runningApplications, options: [.initial, .new])
            .map { $0.filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier } }
            .sink { [weak self] apps in
                self?.updateRunningApps(apps)
            }
            .store(in: &cancellables)
        
        // 立即刷新一次
        refreshAudioProcesses()
    }
    
    func stopObserving() {
        isObserving = false
        refreshTimer?.invalidate()
        refreshTimer = nil
        cancellables.removeAll()
    }
    
    func refreshAudioProcesses() {
        do {
            // 尝试获取当前运行的有音频功能的进程
            let audioObjectIDs = try AudioObjectID.readAudioProcessesFromCurrentlyRunningProcesses()
            logger.debug("找到 \(audioObjectIDs.count) 个音频进程")
            
            let updatedProcesses = audioObjectIDs.compactMap { objectID -> AudioProcess? in
                do {
                    return try AudioProcess(objectID: objectID)
                } catch {
                    logger.warning("初始化音频进程失败: \(error.localizedDescription)")
                    return nil
                }
            }
            
            // 按名称排序，并将有音频活动的进程排在前面
            processes = updatedProcesses.sorted { p1, p2 in
                if p1.audioActive && !p2.audioActive {
                    return true
                } else if !p1.audioActive && p2.audioActive {
                    return false
                }
                return p1.name.localizedStandardCompare(p2.name) == .orderedAscending
            }
            
            logger.debug("已更新音频进程列表，共 \(self.processes.count) 个进程")
        } catch {
            logger.error("刷新音频进程列表失败: \(error.localizedDescription)")
        }
    }
    
    private func updateRunningApps(_ apps: [NSRunningApplication]) {
        let runningAppModels = apps.map { app in
            AppModels.RunningApp(
                processIdentifier: app.processIdentifier,
                bundleIdentifier: app.bundleIdentifier ?? "unknown",
                name: app.localizedName ?? app.bundleIdentifier?.components(separatedBy: ".").last ?? "未知应用",
                icon: app.icon?.copy() as? NSImage ?? NSWorkspace.shared.icon(for: UTType.application)
            )
        }
        
        runningApps = runningAppModels.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        logger.debug("已更新运行应用列表，共 \(self.runningApps.count) 个应用")
    }
    
    func getAudioObjectIDForApp(bundleID: String) throws -> AudioObjectID {
        // 首先检查已知的进程
        if let process = processes.first(where: { $0.bundleID == bundleID }) {
            logger.debug("从进程列表中找到应用的音频对象: \(process.name)")
            return process.objectID
        }
        
        // 如果找不到，尝试通过PID获取
        if let app = runningApps.first(where: { $0.bundleIdentifier == bundleID }),
           let nsApp = NSWorkspace.shared.runningApplications.first(where: { $0.processIdentifier == app.processIdentifier }) {
            
            let pid = nsApp.processIdentifier
            
            do {
                let audioObjectID = try AudioObjectID.translatePIDToAudioObjectID(pid: pid)
                logger.debug("通过PID获取应用的音频对象: \(nsApp.localizedName ?? bundleID)")
                return audioObjectID
            } catch {
                logger.warning("通过PID获取音频对象失败: \(error.localizedDescription)")
                throw error
            }
        }
        
        // 刷新一次再尝试
        refreshAudioProcesses()
        
        if let process = processes.first(where: { $0.bundleID == bundleID }) {
            logger.debug("刷新后从进程列表中找到应用的音频对象: \(process.name)")
            return process.objectID
        }
        
        throw "无法找到应用 \(bundleID) 的音频对象，该应用可能不产生音频或需要重启"
    }
    
    deinit {
        stopObserving()
    }
}
enum AppModels {
    /// 运行中的应用模型
    struct RunningApp: Identifiable, Hashable {
        let id = UUID()
        let processIdentifier: pid_t
        let bundleIdentifier: String
        let name: String
        let icon: NSImage?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(processIdentifier)
            hasher.combine(bundleIdentifier)
        }
        
        static func == (lhs: RunningApp, rhs: RunningApp) -> Bool {
            lhs.processIdentifier == rhs.processIdentifier && 
            lhs.bundleIdentifier == rhs.bundleIdentifier
        }
    }
    
    /// 获取系统中运行的应用列表
    static func getRunningApps() -> [RunningApp] {
        let runningApps = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular } // 只保留常规应用程序
            .map { app in
                RunningApp(
                    processIdentifier: app.processIdentifier,
                    bundleIdentifier: app.bundleIdentifier ?? "unknown",
                    name: app.localizedName ?? app.bundleIdentifier?.components(separatedBy: ".").last ?? "未知应用",
                    icon: app.icon?.copy() as? NSImage ?? NSWorkspace.shared.icon(for: UTType.application)
                )
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        
        return runningApps
    }
} 
