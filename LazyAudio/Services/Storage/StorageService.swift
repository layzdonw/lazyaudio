import Foundation
import Combine

/// 存储服务协议
/// 定义数据持久化的接口
protocol StorageServiceProtocol {
    /// 保存录音会话
    /// - Parameter session: 录音会话
    func saveRecordingSession(_ session: RecordingSession) -> AnyPublisher<Void, Error>
    
    /// 获取所有录音会话
    func getAllRecordingSessions() -> AnyPublisher<[RecordingSession], Error>
    
    /// 获取录音会话
    /// - Parameter id: 会话ID
    func getRecordingSession(id: String) -> AnyPublisher<RecordingSession?, Error>
    
    /// 删除录音会话
    /// - Parameter id: 会话ID
    func deleteRecordingSession(id: String) -> AnyPublisher<Void, Error>
    
    /// 更新录音会话
    /// - Parameter session: 录音会话
    func updateRecordingSession(_ session: RecordingSession) -> AnyPublisher<Void, Error>
    
    /// 获取录音文件存储目录
    var recordingsDirectory: URL { get }
}

/// 录音会话
struct RecordingSession: Identifiable, Codable {
    let id: String
    var title: String
    var date: Date
    var duration: TimeInterval
    var audioURL: URL
    var transcription: [TranscriptionSegment]
    var tags: [String]
    var isFavorite: Bool
    
    init(id: String = UUID().uuidString,
         title: String,
         date: Date = Date(),
         duration: TimeInterval = 0,
         audioURL: URL,
         transcription: [TranscriptionSegment] = [],
         tags: [String] = [],
         isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.duration = duration
        self.audioURL = audioURL
        self.transcription = transcription
        self.tags = tags
        self.isFavorite = isFavorite
    }
}

/// 转录片段
struct TranscriptionSegment: Identifiable, Codable {
    let id: String
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
    let confidence: Double
    
    init(id: String = UUID().uuidString,
         startTime: TimeInterval,
         endTime: TimeInterval,
         text: String,
         confidence: Double = 1.0) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
        self.confidence = confidence
    }
}

/// 存储服务实现
class StorageService: StorageServiceProtocol {
    private let fileManager = FileManager.default
    private let settingsService: SettingsServiceProtocol
    
    /// 获取录音文件存储目录
    var recordingsDirectory: URL {
        return settingsService.recordingsDirectory
    }
    
    init(settingsService: SettingsServiceProtocol = SettingsService()) {
        self.settingsService = settingsService
    }
    
    func saveRecordingSession(_ session: RecordingSession) -> AnyPublisher<Void, Error> {
        let resultSubject = PassthroughSubject<Void, Error>()
        
        do {
            // 创建会话目录
            let sessionDirectoryURL = recordingsDirectory.appendingPathComponent(session.id)
            try fileManager.createDirectory(at: sessionDirectoryURL, withIntermediateDirectories: true)
            
            // 保存会话元数据
            let metadataURL = sessionDirectoryURL.appendingPathComponent("metadata.json")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(session)
            try data.write(to: metadataURL)
            
            // 复制音频文件
            let audioDestinationURL = sessionDirectoryURL.appendingPathComponent("audio.m4a")
            if fileManager.fileExists(atPath: audioDestinationURL.path) {
                try fileManager.removeItem(at: audioDestinationURL)
            }
            try fileManager.copyItem(at: session.audioURL, to: audioDestinationURL)
            
            resultSubject.send(())
            resultSubject.send(completion: .finished)
        } catch {
            resultSubject.send(completion: .failure(error))
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
    
    func getAllRecordingSessions() -> AnyPublisher<[RecordingSession], Error> {
        let resultSubject = PassthroughSubject<[RecordingSession], Error>()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // 如果目录不存在，创建它并返回空数组
                if !self.fileManager.fileExists(atPath: self.recordingsDirectory.path) {
                    try self.fileManager.createDirectory(at: self.recordingsDirectory, withIntermediateDirectories: true)
                    DispatchQueue.main.async {
                        resultSubject.send([])
                        resultSubject.send(completion: .finished)
                    }
                    return
                }
                
                // 获取所有会话目录
                let sessionDirectories = try self.fileManager.contentsOfDirectory(at: self.recordingsDirectory, includingPropertiesForKeys: nil)
                
                var sessions: [RecordingSession] = []
                
                for sessionDirectory in sessionDirectories {
                    let metadataURL = sessionDirectory.appendingPathComponent("metadata.json")
                    
                    if self.fileManager.fileExists(atPath: metadataURL.path) {
                        let data = try Data(contentsOf: metadataURL)
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let session = try decoder.decode(RecordingSession.self, from: data)
                        sessions.append(session)
                    }
                }
                
                // 按日期排序，最新的在前
                sessions.sort { $0.date > $1.date }
                
                DispatchQueue.main.async {
                    resultSubject.send(sessions)
                    resultSubject.send(completion: .finished)
                }
            } catch {
                DispatchQueue.main.async {
                    resultSubject.send(completion: .failure(error))
                }
            }
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
    
    func getRecordingSession(id: String) -> AnyPublisher<RecordingSession?, Error> {
        let resultSubject = PassthroughSubject<RecordingSession?, Error>()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let sessionDirectoryURL = self.recordingsDirectory.appendingPathComponent(id)
                let metadataURL = sessionDirectoryURL.appendingPathComponent("metadata.json")
                
                if self.fileManager.fileExists(atPath: metadataURL.path) {
                    let data = try Data(contentsOf: metadataURL)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let session = try decoder.decode(RecordingSession.self, from: data)
                    
                    DispatchQueue.main.async {
                        resultSubject.send(session)
                        resultSubject.send(completion: .finished)
                    }
                } else {
                    DispatchQueue.main.async {
                        resultSubject.send(nil)
                        resultSubject.send(completion: .finished)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    resultSubject.send(completion: .failure(error))
                }
            }
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
    
    func deleteRecordingSession(id: String) -> AnyPublisher<Void, Error> {
        let resultSubject = PassthroughSubject<Void, Error>()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let sessionDirectoryURL = self.recordingsDirectory.appendingPathComponent(id)
                
                if self.fileManager.fileExists(atPath: sessionDirectoryURL.path) {
                    try self.fileManager.removeItem(at: sessionDirectoryURL)
                }
                
                DispatchQueue.main.async {
                    resultSubject.send(())
                    resultSubject.send(completion: .finished)
                }
            } catch {
                DispatchQueue.main.async {
                    resultSubject.send(completion: .failure(error))
                }
            }
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
    
    func updateRecordingSession(_ session: RecordingSession) -> AnyPublisher<Void, Error> {
        let resultSubject = PassthroughSubject<Void, Error>()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let sessionDirectoryURL = self.recordingsDirectory.appendingPathComponent(session.id)
                let metadataURL = sessionDirectoryURL.appendingPathComponent("metadata.json")
                
                if self.fileManager.fileExists(atPath: metadataURL.path) {
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    let data = try encoder.encode(session)
                    try data.write(to: metadataURL)
                    
                    DispatchQueue.main.async {
                        resultSubject.send(())
                        resultSubject.send(completion: .finished)
                    }
                } else {
                    DispatchQueue.main.async {
                        resultSubject.send(completion: .failure(NSError(domain: "StorageService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Session not found"])))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    resultSubject.send(completion: .failure(error))
                }
            }
        }
        
        return resultSubject.eraseToAnyPublisher()
    }
} 