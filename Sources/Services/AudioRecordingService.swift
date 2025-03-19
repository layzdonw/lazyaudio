import Foundation
import AVFoundation
import AudioToolbox
import OSLog

enum AudioSourceType {
    case microphone
    case systemAudio
    case appAudio(pid: pid_t)
}

struct AudioProcess {
    let id: pid_t
    let name: String
    let objectID: AudioObjectID
}

@Observable
final class AudioRecordingService {
    private let logger = Logger(subsystem: "com.lazyaudio", category: "AudioRecording")
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var audioFormat: AVAudioFormat?
    private var processTap: ProcessTap?
    private var processTapRecorder: ProcessTapRecorder?
    
    private(set) var isRecording = false
    private(set) var errorMessage: String?
    
    func startRecording(sourceType: AudioSourceType) throws {
        guard !isRecording else { return }
        
        do {
            // 设置音频会话
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            switch sourceType {
            case .microphone:
                try startMicrophoneRecording()
            case .systemAudio:
                try startSystemAudioRecording()
            case .appAudio(let pid):
                try startAppAudioRecording(pid: pid)
            }
            
            isRecording = true
            
        } catch {
            logger.error("开始录制失败: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    private func startMicrophoneRecording() throws {
        // 创建音频引擎
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        // 获取输入节点
        let inputNode = audioEngine.inputNode
        audioFormat = inputNode.outputFormat(forBus: 0)
        
        guard let audioFormat = audioFormat else {
            throw "无法获取音频格式"
        }
        
        // 创建临时文件URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(Date().timeIntervalSince1970).m4a")
        
        // 创建音频文件
        audioFile = try AVAudioFile(forWriting: audioFilename, settings: audioFormat.settings)
        
        // 安装tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: audioFormat) { [weak self] buffer, time in
            do {
                try self?.audioFile?.write(from: buffer)
            } catch {
                self?.logger.error("写入音频数据失败: \(error.localizedDescription)")
            }
        }
        
        // 启动引擎
        try audioEngine.start()
    }
    
    private func startSystemAudioRecording() throws {
        let systemOutputID = try AudioDeviceID.readDefaultSystemOutputDevice()
        let process = AudioProcess(id: 0, name: "System Audio", objectID: systemOutputID)
        let tap = ProcessTap(process: process, muteWhenRunning: false)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(Date().timeIntervalSince1970).m4a")
        
        processTapRecorder = ProcessTapRecorder(fileURL: audioFilename, tap: tap)
        try processTapRecorder?.start()
    }
    
    private func startAppAudioRecording(pid: pid_t) throws {
        let objectID = try AudioObjectID.readProcessObjectID(for: pid)
        let process = AudioProcess(id: pid, name: "App Audio", objectID: objectID)
        let tap = ProcessTap(process: process, muteWhenRunning: false)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(Date().timeIntervalSince1970).m4a")
        
        processTapRecorder = ProcessTapRecorder(fileURL: audioFilename, tap: tap)
        try processTapRecorder?.start()
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioFile = nil
        processTap?.invalidate()
        processTap = nil
        processTapRecorder?.stop()
        processTapRecorder = nil
        isRecording = false
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            logger.error("停止音频会话失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - ProcessTap
@Observable
final class ProcessTap {
    typealias InvalidationHandler = (ProcessTap) -> Void
    
    let process: AudioProcess
    let muteWhenRunning: Bool
    private let logger: Logger
    
    private(set) var errorMessage: String? = nil
    
    init(process: AudioProcess, muteWhenRunning: Bool = false) {
        self.process = process
        self.muteWhenRunning = muteWhenRunning
        self.logger = Logger(subsystem: "com.lazyaudio", category: "\(String(describing: ProcessTap.self))(\(process.name))")
    }
    
    @ObservationIgnored
    private var processTapID: AudioObjectID = .unknown
    @ObservationIgnored
    private var aggregateDeviceID = AudioObjectID.unknown
    @ObservationIgnored
    private var deviceProcID: AudioDeviceIOProcID?
    @ObservationIgnored
    private(set) var tapStreamDescription: AudioStreamBasicDescription?
    @ObservationIgnored
    private var invalidationHandler: InvalidationHandler?
    
    @ObservationIgnored
    private(set) var activated = false
    
    @MainActor
    func activate() {
        guard !activated else { return }
        activated = true
        
        logger.debug(#function)
        
        self.errorMessage = nil
        
        do {
            try prepare(for: process.objectID)
        } catch {
            logger.error("\(error, privacy: .public)")
            self.errorMessage = error.localizedDescription
        }
    }
    
    func invalidate() {
        guard activated else { return }
        defer { activated = false }
        
        logger.debug(#function)
        
        invalidationHandler?(self)
        self.invalidationHandler = nil
        
        if aggregateDeviceID.isValid {
            var err = AudioDeviceStop(aggregateDeviceID, deviceProcID)
            if err != noErr { logger.warning("Failed to stop aggregate device: \(err, privacy: .public)") }
            
            if let deviceProcID {
                err = AudioDeviceDestroyIOProcID(aggregateDeviceID, deviceProcID)
                if err != noErr { logger.warning("Failed to destroy device I/O proc: \(err, privacy: .public)") }
                self.deviceProcID = nil
            }
            
            err = AudioHardwareDestroyAggregateDevice(aggregateDeviceID)
            if err != noErr {
                logger.warning("Failed to destroy aggregate device: \(err, privacy: .public)")
            }
            aggregateDeviceID = .unknown
        }
        
        if processTapID.isValid {
            let err = AudioHardwareDestroyProcessTap(processTapID)
            if err != noErr {
                logger.warning("Failed to destroy audio tap: \(err, privacy: .public)")
            }
            self.processTapID = .unknown
        }
    }
    
    private func prepare(for objectID: AudioObjectID) throws {
        errorMessage = nil
        
        let tapDescription = CATapDescription(stereoMixdownOfProcesses: [objectID])
        tapDescription.uuid = UUID()
        tapDescription.muteBehavior = muteWhenRunning ? .mutedWhenTapped : .unmuted
        var tapID: AUAudioObjectID = .unknown
        var err = AudioHardwareCreateProcessTap(tapDescription, &tapID)
        
        guard err == noErr else {
            errorMessage = "Process tap creation failed with error \(err)"
            return
        }
        
        logger.debug("Created process tap #\(tapID, privacy: .public)")
        
        self.processTapID = tapID
        
        let systemOutputID = try AudioDeviceID.readDefaultSystemOutputDevice()
        let outputUID = try systemOutputID.readDeviceUID()
        let aggregateUID = UUID().uuidString
        
        let description: [String: Any] = [
            kAudioAggregateDeviceNameKey: "Tap-\(process.id)",
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
        
        self.tapStreamDescription = try tapID.readAudioTapStreamBasicDescription()
        
        aggregateDeviceID = AudioObjectID.unknown
        err = AudioHardwareCreateAggregateDevice(description as CFDictionary, &aggregateDeviceID)
        guard err == noErr else {
            throw "Failed to create aggregate device: \(err)"
        }
        
        logger.debug("Created aggregate device #\(self.aggregateDeviceID, privacy: .public)")
    }
    
    func run(on queue: DispatchQueue, ioBlock: @escaping AudioDeviceIOBlock, invalidationHandler: @escaping InvalidationHandler) throws {
        assert(activated, "\(#function) called with inactive tap!")
        assert(self.invalidationHandler == nil, "\(#function) called with tap already active!")
        
        errorMessage = nil
        
        logger.debug("Run tap!")
        
        self.invalidationHandler = invalidationHandler
        
        var err = AudioDeviceCreateIOProcIDWithBlock(&deviceProcID, aggregateDeviceID, queue, ioBlock)
        guard err == noErr else { throw "Failed to create device I/O proc: \(err)" }
        
        err = AudioDeviceStart(aggregateDeviceID, deviceProcID)
        guard err == noErr else { throw "Failed to start audio device: \(err)" }
    }
    
    deinit { invalidate() }
}

// MARK: - ProcessTapRecorder
@Observable
final class ProcessTapRecorder {
    let fileURL: URL
    let process: AudioProcess
    private let queue = DispatchQueue(label: "ProcessTapRecorder", qos: .userInitiated)
    private let logger: Logger
    
    @ObservationIgnored
    private weak var _tap: ProcessTap?
    
    private(set) var isRecording = false
    
    init(fileURL: URL, tap: ProcessTap) {
        self.process = tap.process
        self.fileURL = fileURL
        self._tap = tap
        self.logger = Logger(subsystem: "com.lazyaudio", category: "\(String(describing: ProcessTapRecorder.self))(\(fileURL.lastPathComponent))")
    }
    
    private var tap: ProcessTap {
        get throws {
            guard let _tap else { throw "Process tab unavailable" }
            return _tap
        }
    }
    
    @ObservationIgnored
    private var currentFile: AVAudioFile?
    
    @MainActor
    func start() throws {
        logger.debug(#function)
        
        guard !isRecording else {
            logger.warning("\(#function, privacy: .public) while already recording")
            return
        }
        
        let tap = try tap
        
        if !tap.activated { tap.activate() }
        
        guard var streamDescription = tap.tapStreamDescription else {
            throw "Tap stream description not available."
        }
        
        guard let format = AVAudioFormat(streamDescription: &streamDescription) else {
            throw "Failed to create AVAudioFormat."
        }
        
        logger.info("Using audio format: \(format, privacy: .public)")
        
        let settings: [String: Any] = [
            AVFormatIDKey: streamDescription.mFormatID,
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount
        ]
        let file = try AVAudioFile(forWriting: fileURL, settings: settings, commonFormat: .pcmFormatFloat32, interleaved: format.isInterleaved)
        
        self.currentFile = file
        
        try tap.run(on: queue) { [weak self] inNow, inInputData, inInputTime, outOutputData, inOutputTime in
            guard let self, let currentFile = self.currentFile else { return }
            do {
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, bufferListNoCopy: inInputData, deallocator: nil) else {
                    throw "Failed to create PCM buffer"
                }
                
                try currentFile.write(from: buffer)
            } catch {
                logger.error("\(error, privacy: .public)")
            }
        } invalidationHandler: { [weak self] tap in
            guard let self else { return }
            self.handleInvalidation()
        }
        
        isRecording = true
    }
    
    func stop() {
        do {
            logger.debug(#function)
            
            guard isRecording else { return }
            
            currentFile = nil
            isRecording = false
        } catch {
            logger.error("\(error, privacy: .public)")
        }
    }
    
    private func handleInvalidation() {
        stop()
    }
} 