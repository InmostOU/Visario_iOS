//
//  AudioRecorder.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 19.11.2021.
//

import AVFoundation
import SoundWave
import MessageKit
import Alamofire

enum AudioRecodingState {
    case ready
    case recording
    case recorded
    case playing
    case paused

    var buttonImage: UIImage {
        switch self {
        case .ready, .recording:
            return #imageLiteral(resourceName: "Record-Button")
        case .recorded, .paused:
            return #imageLiteral(resourceName: "Play-Button")
        case .playing:
            return #imageLiteral(resourceName: "Pause-Button")
        }
    }

    var audioVisualizationMode: AudioVisualizationView.AudioVisualizationMode {
        switch self {
        case .ready, .recording:
            return .write
        case .paused, .playing, .recorded:
            return .read
        }
    }
}

protocol AudioRecorderDelegate: AnyObject {
    func audioRecorder(didUpdateDecibel decibel: Float)
}

protocol AudioPlayerDelegate: AnyObject {
    func audioPlayer(didFinishPlaying finish: Bool)
}

final class AudioRecorder: NSObject {
    
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    
    private var decibelTimer: Timer?
    private let fileManager = FileManager.default
    
    private weak var messagesCollectionView: MessagesCollectionView?
    private(set) var playingMessage: MessageType?
    private(set) weak var playingCell: AudioMessageCell?
    private var progressTimer: Timer?
    
    private(set) var meteringLevels: [Float] = []
    private(set) var currentState: AudioRecodingState = .ready
    private var numberOfRecords = 0
    private var recordID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    var recordedAudioURL: URL?
    
    weak var delegate: (AudioRecorderDelegate & AudioPlayerDelegate)?
    
    private var averageDecibel: Float? {
        audioRecorder?.averagePower(forChannel: 0)
    }
    
    init(messagesCollectionView: MessagesCollectionView) {
        super.init()
        
        self.messagesCollectionView = messagesCollectionView
        checkMicrophoneAccess()
        setupDecibelTimer()
    }
    
    private func setupDecibelTimer() {
        decibelTimer = .scheduledTimer(timeInterval: 0.07, target: self, selector: #selector(sendDecibelLevelToDelegate), userInfo: nil, repeats: true)
    }
    
    private func normalizeDecibelLevel(from decibel: Float) -> Float {
        if decibel < -60.0 || decibel == 0.0 {
            return 0.0
        }
        // OMG
        return powf((powf(10, 0.05 * decibel) - powf(10, 0.05 * -60)) * (1 / (1 - powf(10, 0.05 * -60))), 1 / 2) * 2
    }
    
    // Microphone Access
    private func checkMicrophoneAccess() {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.overrideOutputAudioPort(.speaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        // self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if playingMessage?.messageId == message.messageId, let collectionView = messagesCollectionView, let player = audioPlayer {
            playingCell = cell
            cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
            cell.playButton.isSelected = player.isPlaying
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
        }
    }
    
    func playAudio(for message: MessageType, in audioCell: AudioMessageCell) {
        switch message.kind {
        case .audio(let item):
            playingCell = audioCell
            playingMessage = message

            var fileName = ""
            
            switch item.url.scheme {
            case "https":
                fileName = item.url.path.components(separatedBy: "?").first?.components(separatedBy: "-").last ?? ""
            case nil:
                fileName = item.url.path.components(separatedBy: "/").last ?? ""
            default:
                print(#function, "wrong url scheme!")
                break
            }
            
            guard let fileURL = searchLocalPath(by: fileName) else { return }
            guard let player = try? AVAudioPlayer(contentsOf: fileURL) else {
                print("Failed to create audio player for URL: \(fileURL)")
                return
            }
            audioPlayer = player
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            audioPlayer?.play()
            currentState = .playing
            audioCell.playButton.isSelected = true  // show pause button on audio cell
            startProgressTimer()
            audioCell.delegate?.didStartAudio(in: audioCell)
        default:
            print("BasicAudioPlayer failed play sound because given message kind is not Audio")
        }
    }
    
    func loadAudio(by message: KitMessage, completion: @escaping (Result<KitMessage, AFError>) -> Void) {
        switch message.kind {
        case .audio(let audioItem):
            AF.request(audioItem.url).response { [weak self] response in
                guard let self = self else { return }
                guard let fileData = response.data, response.error == nil else {
                    print("Response not contains any data!")
                    completion(.failure(response.error!))
                    return
                }
                let fileName = audioItem.url.path
                    .components(separatedBy: "?").first?
                    .components(separatedBy: "-").last?
                    .components(separatedBy: ".").first ?? "NoName!"
                let audioFileURL = self.audioFileURL(name: fileName)
                self.fileManager.createFile(atPath: audioFileURL.path, contents: fileData)
                let audioFileDuration = self.audioFileDuration(by: audioFileURL)
                
                var kitMessage = message
                kitMessage.fileURL = audioFileURL.path
                kitMessage.fileName = fileName
                kitMessage.audioDuration = audioFileDuration
                
                completion(.success(kitMessage))
            }
        default:
            break
        }
    }
    
    private func audioFileDuration(by url: URL) -> Float {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            return Float(audioPlayer.duration)
        } catch {
            print(error)
            return -1.0
        }
    }
    
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressTimer = .scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(didFireProgressTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func didFireProgressTimer(_ timer: Timer) {
        guard let player = audioPlayer, let collectionView = messagesCollectionView, let cell = playingCell else {
            return
        }
        // check if can update playing cell
        if let playingCellIndexPath = collectionView.indexPath(for: cell) {
            let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
            if currentMessage != nil && currentMessage?.messageId == playingMessage?.messageId {
                // messages are the same update cell content
                cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
                guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                    fatalError("MessagesDisplayDelegate has not been set.")
                }
                cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
            } else {
                // if the current message is not the same with playing message stop playing sound
                stopAnyOngoingPlaying()
            }
        }
    }
    
    func stopAnyOngoingPlaying() {
        // If the audio player is nil then we don't need to go through the stopping logic
        guard let player = audioPlayer, let collectionView = messagesCollectionView else { return }
        player.stop()
        currentState = .ready
        if let cell = playingCell {
            cell.progressView.progress = 0.0
            cell.playButton.isSelected = false
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.duration), for: cell, in: collectionView)
            cell.delegate?.didStopAudio(in: cell)
        }
        progressTimer?.invalidate()
        progressTimer = nil
        audioPlayer = nil
        playingMessage = nil
        playingCell = nil
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioFileURL(name: String) -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("\(name).m4a")
        return path
    }
    
    func getAudioFile() -> Data? {
        guard let url = recordedAudioURL else { return nil }
        if fileManager.fileExists(atPath: url.path) {
            return fileManager.contents(atPath: url.path)
        }
        return nil
    }
    
    func isFileExist(with fileName: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileURL = URL(fileURLWithPath: path).appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    private func searchLocalPath(by fileName: String) -> URL? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileURL = URL(fileURLWithPath: path).appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        } else {
            print("ERROR: File with name: \(fileName), not exist!")
            return nil
        }
    }
    
    func fetchImage(with imageName: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let path = paths.first {
            let imageURL = URL(fileURLWithPath: path).appendingPathComponent(imageName)
            let data = try! Data(contentsOf: imageURL)
            if let image = UIImage(data: data) {
                return image
            }
        }
        return nil
    }
    
    func deleteRecordedAudio() {
        guard let audioURL = recordedAudioURL else { return }
        do {
            try fileManager.removeItem(atPath: audioURL.path)
        } catch {
            print(error)
        }
    }
    
    func clearMeteringLevels() {
        meteringLevels = []
    }
    
    func startRecording() {
        currentState = .recording
        recordID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        
        let recorderSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            recordedAudioURL = audioFileURL(name: recordID)
            guard let audioURL = recordedAudioURL else { return }
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: recorderSettings)
            audioRecorder.delegate = self
            audioRecorder.record()
            audioRecorder.isMeteringEnabled = true
        } catch {
            finishRecording()
        }
        
    }
    
    func finishRecording() {
        guard audioRecorder != nil else { return }
        audioRecorder.stop()
        audioRecorder = nil
        currentState = .recorded
    }
    
    func playRecording() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL(name: recordID))
            audioPlayer.delegate = self
            audioPlayer.play()
            currentState = .playing
        } catch {
            print(error)
        }
    }
    
    func pauseSound() {
        audioPlayer.pause()
        currentState = .paused
    }
    
    func pausePlaying(for message: MessageType, in audioCell: AudioMessageCell) {
        audioPlayer?.pause()
        currentState = .paused
        audioCell.playButton.isSelected = false // show play button on audio cell
        progressTimer?.invalidate()
        
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }
    
    func resumeDuration() -> TimeInterval {
        guard audioPlayer != nil else { return 0 }
        currentState = .playing
        return audioPlayer!.duration - audioPlayer!.currentTime
    }
    
    func resumePlaying() {
        guard let player = audioPlayer else {
            stopAnyOngoingPlaying()
            return
        }
        player.prepareToPlay()
        player.play()
        currentState = .playing
        startProgressTimer()
        
        guard let cell = playingCell else { return }
        cell.playButton.isSelected = true // show pause button on audio cell
        cell.delegate?.didStartAudio(in: cell)
    }
    
    func stopPlaying() {
        guard audioPlayer != nil else { return }
        audioPlayer.stop()
        audioPlayer = nil
        currentState = .ready
    }
    
    // MARK: Actions
    
    @objc private func sendDecibelLevelToDelegate() {
        guard audioRecorder != nil, let decibel = averageDecibel else { return }
        meteringLevels.append(decibel)
        audioRecorder.updateMeters()
        delegate?.audioRecorder(didUpdateDecibel: normalizeDecibelLevel(from: decibel))
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorder: AVAudioRecorderDelegate {
    
    // to suddenly stop recording, such as incoming phone call
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishRecording()
    }
    
}

// MARK: - AVAudioPlayerDelegate

extension AudioRecorder: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.audioPlayer(didFinishPlaying: flag)
        stopAnyOngoingPlaying()
        currentState = .ready
    }
    
}
