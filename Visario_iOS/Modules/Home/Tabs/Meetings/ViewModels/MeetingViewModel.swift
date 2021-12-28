//
//  MeetingViewModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 30.08.2021.
//

import UIKit
import AVFoundation
import AmazonChimeSDK
import MessageKit

final class MeetingViewModel {
    
    private let userDefaultsKeyMeetingId = "demoMeetingId"
    private let userDefaultsKeyCredentials = "demoMeetingCredentials"
    private let userDefaultsKeyUrls = "demoMeetingUrls"
    
    private var meetingUrlData: CreateMeetingResponseModel?
    private let meetingsService = MeetingAPIService()
    
    private(set) var isMuted = false
    private(set) var videoEnabled = false
    private var isBackCameraActive = false
    private var myAttendeeId = ""
    
    private var participantsToRemove: [UserInfoResponseModel] = []
    private(set) var participants: [UserInfoResponseModel] = []
    private(set) var messages: [KitMessage] = []
    
    weak var view: (MeetingView & UIViewController)?
    var messageDidReceivedHandler: ((Result<Void, Error>) -> Void)?
    
    init() {
        createMeeting()
    }
    
    init(meetingId: String) {
        meetingsService.getMeeting(meetingId: meetingId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.meetingUrlData = response
                self.getMeeting(meetingUrlData: response)
            case .failure(let error):
                self.view?.showError(error: error)
            }
        }
    }
    
    func muteAudio() {
        if isMuted {
            _ = MeetingService.shared.meetingSession?.audioVideo.realtimeLocalUnmute()
            isMuted.toggle()
        } else {
            _ = MeetingService.shared.meetingSession?.audioVideo.realtimeLocalMute()
            isMuted.toggle()
        }
    }
    
    func enableVideo() {
        do {
            try MeetingService.shared.meetingSession?.audioVideo.startLocalVideo()
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoChat)
        } catch PermissionError.videoPermissionError {
            self.view?.showAlert(title: "Failed", message: "You cant enable video without video permission.")
            return
        } catch(let error) {
            view?.showError(error: error)
            return
        }
        
        videoEnabled = true
    }
    
    func disableVideo() {
        if isBackCameraActive {
            switchCamera()
        }
        MeetingService.shared.meetingSession?.audioVideo.stopLocalVideo()
        videoEnabled = false
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .voiceChat)
        } catch(let error) {
            view?.showError(error: error)
            return
        }
    }
    
    func exitMeeting() {
        if videoEnabled {
            disableVideo()
        }
        guard let meetingUrlData = meetingUrlData else { return }
        
        guard let appGroupUserDefaults = UserDefaults(suiteName: "group.com.Visario-iOS") else {
            print("App Group User Defaults not found")
            return
        }
        appGroupUserDefaults.removeObject(forKey: userDefaultsKeyMeetingId)
        appGroupUserDefaults.removeObject(forKey: userDefaultsKeyCredentials)
        appGroupUserDefaults.removeObject(forKey: userDefaultsKeyUrls)
        
        meetingsService.deleteAttendee(meetingId: meetingUrlData.meetingObject.meetingId, userId: meetingUrlData.attendeeObject.externalUserId) { result in
            switch result {
            case .success:
                print("attendee deleted successfully")
                
            case .failure(let error):
                print("failed to delete attendee - \(error.localizedDescription)")
            }
        }
        MeetingService.shared.meetingSession?.audioVideo.stopContentShare()
        MeetingService.shared.meetingSession?.audioVideo.stopRemoteVideo()
        MeetingService.shared.meetingSession?.audioVideo.stop()
        removeAudioVideoFacadeObservers()
    }
    
    private func removeAudioVideoFacadeObservers() {
        guard let meetingSession = MeetingService.shared.meetingSession else { return }
        meetingSession.audioVideo.removeVideoTileObserver(observer: self)
        meetingSession.audioVideo.removeRealtimeObserver(observer: self)
        meetingSession.audioVideo.removeAudioVideoObserver(observer: self)
        meetingSession.audioVideo.removeActiveSpeakerObserver(observer: self)
        meetingSession.audioVideo.removeRealtimeDataMessageObserverFromTopic(topic: "chat")
    }
    
    private func newMessage(with text: String, from sender: SenderType) -> KitMessage {
        KitMessage(sender: sender,
                   messageId: UUID().uuidString,
                   sentDate: Date(),
                   content: text,
                   createdTimestamp: 0,
                   lastEditedTimestamp: 0,
                   metadata: "",
                   redacted: false,
                   senderArn: sender.senderId,
                   senderName: sender.displayName,
                   type: .standard,
                   channelArn: "",
                   fromCurrentUser: true,
                   delivered: false)
    }
    
    func sendMessage(message: KitMessage) {
        if case MessageKind.text(let text) = message.kind {
            do {
                guard let currentMeetingSession = MeetingService.shared.meetingSession else { return }
                try currentMeetingSession.audioVideo.realtimeSendDataMessage(topic: "chat", data: text, lifetimeMs: 10000)
                
                let newMessage = newMessage(with: text, from: message.sender)
                messages.append(newMessage)
                messageDidReceivedHandler?(.success(()))
            } catch let err as SendDataMessageError {
                print("Failed to send message! \(err)")
                messageDidReceivedHandler?(.failure(err))
            } catch {
                print("Unknown error \(error.localizedDescription)")
                messageDidReceivedHandler?(.failure(error))
            }
        }
    }
    
    private func switchCamera() {
        guard let cell = view?.getCell(by: myAttendeeId) else { return }
        if cell.isLocalCell {
            cell.videoRenderView.mirror.toggle()
        }
        MeetingService.shared.meetingSession?.audioVideo.switchCamera()
        isBackCameraActive.toggle()
    }
    
    private func configureObservers() {
        guard let meetingSession = MeetingService.shared.meetingSession else { return }
        meetingSession.audioVideo.addAudioVideoObserver(observer: self)
        meetingSession.audioVideo.addRealtimeObserver(observer: self)
        meetingSession.audioVideo.addVideoTileObserver(observer: self)
        meetingSession.audioVideo.addActiveSpeakerObserver(policy: DefaultActiveSpeakerPolicy(), observer: self)
        meetingSession.audioVideo.addRealtimeDataMessageObserver(topic: "chat", observer: self)
    }
    
    private func requestAudioVideoPermisson() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            self.audioVideoStart()
            print("audio access granted")
        case AVAudioSession.RecordPermission.denied:
            self.view?.showAlert(title: "Failed", message: "You cant join voice meeting without microphone permission.")
            fallthrough
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.audioVideoStart()
                } else {
                    self.view?.showAlert(title: "Failed", message: "You cant join voice meeting without microphone permission.")
                }
            }
        @unknown default:
            fatalError()
        }
        
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self]  granted in
            guard let self = self else { return }
            if granted {
                print("video access granted")
            } else {
                self.view?.showAlert(title: "Failed", message: "Video permission not granted")
            }
        })
    }
    
    func createMeeting(withMicrophonePermission: Bool = true, completionHandler: ((String) -> ())? = nil) {
        meetingsService.createMeeting { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.meetingUrlData = response
                guard let meetingUrlData = self.meetingUrlData else { return }
                completionHandler?(meetingUrlData.meetingObject.meetingId)
                
                if withMicrophonePermission {
                    self.requestAudioVideoPermisson()
                }
            case .failure(let error):
                self.view?.showError(error: error)
            }
        }
    }
    
    private func getMeeting(meetingUrlData: CreateMeetingResponseModel) {
        MeetingService.shared.createMeetingSession(meetingUrlData: meetingUrlData.meetingObject,
                                                   attendeeData: meetingUrlData.attendeeObject)
        configureObservers()
        requestAudioVideoPermisson()
        
        guard let meetingSessionConfig = MeetingService.shared.meetingSession?.configuration else { return }

        if let appGroupUserDefaults = UserDefaults(suiteName: "group.com.Visario-iOS") {
            appGroupUserDefaults.set(meetingSessionConfig.meetingId, forKey: userDefaultsKeyMeetingId)
            let encoder = JSONEncoder()
            if let credentials = try? encoder.encode(meetingSessionConfig.credentials) {
                appGroupUserDefaults.set(credentials, forKey: userDefaultsKeyCredentials)
            }
            if let urls = try? encoder.encode(meetingSessionConfig.urls) {
                appGroupUserDefaults.set(urls, forKey: userDefaultsKeyUrls)
            }
        }
    }
    
    private func audioVideoStart() {
        do {
            try MeetingService.shared.meetingSession?.audioVideo.start()
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .voiceChat)
            print("audio video started")
            
        } catch PermissionError.audioPermissionError {
            self.view?.showAlert(title: "Failed", message: "You cant join voice meeting without microphone permission.")
        } catch let error {
            self.view?.showAlert(title: "Failed", message: error.localizedDescription)
        }
        MeetingService.shared.meetingSession?.audioVideo.startRemoteVideo()
    }
    
    private func chooseAudioInput() {
        let optionMenu = UIAlertController(title: nil, message: "Choose Audio Device", preferredStyle: .actionSheet)
        for inputDevice in MeetingService.shared.meetingSession!.audioVideo.listAudioDevices() {
            let deviceAction = UIAlertAction(
                title: inputDevice.label,
                style: .default,
                handler: { _ in MeetingService.shared.meetingSession?.audioVideo.chooseAudioDevice(mediaDevice: inputDevice)
            })
            optionMenu.addAction(deviceAction)
            optionMenu.modalPresentationStyle = .automatic
            view?.present(optionMenu, animated: true)
        }
    }
}

// MARK: - AudioVideoObserver

extension MeetingViewModel: AudioVideoObserver {
    
    func audioSessionDidDrop() {
        print("audio session did drop")
    }
    
    func audioSessionDidStartConnecting(reconnecting: Bool) { print("audio session did start connecting") }
    func audioSessionDidStart(reconnecting: Bool) {print("audio session did start")}
    func audioSessionDidStopWithStatus(sessionStatus: MeetingSessionStatus) {print("audio session did stop with status: " + sessionStatus.debugDescription)}
    func audioSessionDidCancelReconnect() {print("audio session did cancel reconnect")}
    func videoSessionDidStartConnecting() {}
    func videoSessionDidStartWithStatus(sessionStatus: MeetingSessionStatus) {}
    func videoSessionDidStopWithStatus(sessionStatus: MeetingSessionStatus) {}
    func connectionDidRecover() {print("connection did recover")}
    func connectionDidBecomePoor() {print("connection did become poor")}
}

// MARK: - RealtimeObserver
 
extension MeetingViewModel: RealtimeObserver {
    
    func attendeesDidDrop(attendeeInfo: [AttendeeInfo]) {
        print("attendees did drop")
    }
    
    func volumeDidChange(volumeUpdates: [VolumeUpdate]) {
        volumeUpdates.forEach { volumeUpdate in
            guard let cell = view?.getCell(by: volumeUpdate.attendeeInfo.attendeeId) else { return }
            cell.animate(strength: CGFloat(volumeUpdate.volumeLevel.rawValue))
        }
    }
    
    func signalStrengthDidChange(signalUpdates: [SignalUpdate]) {
        print("signal did change")
    }
    
    func attendeesDidJoin(attendeeInfo: [AttendeeInfo]) {
        attendeeInfo.forEach { attendee in
            meetingsService.getUserInfoByUserId(meetingId: meetingUrlData!.meetingObject.meetingId, userId: attendee.externalUserId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let userInfo):
                    var user = userInfo
                    user.attendeeId = attendee.attendeeId
                    user.isMuted = false
                    self.participants.append(user)
                    self.view?.reloadCollectionAnimated()
                    
                    guard let profile = KeyChainStorage.shared.getProfile() else { return }
                    if profile.id == user.id {
                        self.myAttendeeId = attendee.attendeeId
                    }
                    
                case .failure(let error):
                    print(#function, "ERROR:", error)
                }
            }
        }
    }
    
    func attendeesDidLeave(attendeeInfo: [AttendeeInfo]) {
        for i in participants.indices {
            for j in attendeeInfo.indices {
                if participants[i].attendeeId == attendeeInfo[j].attendeeId {
                    participantsToRemove.append(participants[i])
                }
            }
        }
        participants.removeAll { participant in
            participantsToRemove.contains(where: { $0.attendeeId == participant.attendeeId })
        }
        view?.reloadCollectionAnimated()
    }
    
    func attendeesDidMute(attendeeInfo: [AttendeeInfo]) {
        attendeeInfo.forEach { attendee in
            guard let cell = view?.getCell(by: attendee.attendeeId) else { return }
            cell.toggleMutedMic()
        }
    }
    
    func attendeesDidUnmute(attendeeInfo: [AttendeeInfo]) {
        attendeeInfo.forEach { attendee in
            guard let cell = view?.getCell(by: attendee.attendeeId) else { return }
            cell.toggleMutedMic()
        }
    }
}

// MARK: - VideoTileObserver

extension MeetingViewModel: VideoTileObserver {
    
    func videoTileSizeDidChange(tileState: VideoTileState) { }
    
    func videoTileDidAdd(tileState: VideoTileState) {
        guard let cell = view?.getCell(by: tileState.attendeeId) else { return }
        cell.toggleHiddenVideoView()
        
        if tileState.isLocalTile {
            cell.videoRenderView.mirror = true
            cell.isLocalCell = true
            cell.delegate = self
        }
        MeetingService.shared.meetingSession?.audioVideo.bindVideoView(videoView: cell.videoRenderView, tileId: tileState.tileId)
    }
    
    func videoTileDidRemove(tileState: VideoTileState) {
        guard let cell = view?.getCell(by: tileState.attendeeId) else { return }
        cell.toggleHiddenVideoView()
        
        MeetingService.shared.meetingSession?.audioVideo.unbindVideoView(tileId: tileState.tileId)
    }
    
    func videoTileDidPause(tileState: VideoTileState) { }
    func videoTileDidResume(tileState: VideoTileState) { }
}

// MARK: - ActiveSpeakerObserver

extension MeetingViewModel: ActiveSpeakerObserver {
    
    var observerId: String {
        return UUID().uuidString
    }
    
    func activeSpeakerDidDetect(attendeeInfo: [AttendeeInfo]) { }
    
}

// MARK: - DoubleTapCellDelegate

extension MeetingViewModel: DoubleTapCellDelegate {
    
    func doubleTapped() {
        switchCamera()
    }
    
}

// MARK: - DataMessageObserver

extension MeetingViewModel: DataMessageObserver {
    
    func dataMessageDidReceived(dataMessage: DataMessage) {
        guard let participant = participants.first(where: { $0.attendeeId == dataMessage.senderAttendeeId }) else { return }
        guard let text = dataMessage.text() else { return }
        guard let attendeeID = participant.attendeeId else { return }
        
        let sender = Sender(senderId: attendeeID, displayName: participant.firstName)
        let newMessage = newMessage(with: text, from: sender)
        
        messages.append(newMessage)
        messageDidReceivedHandler?(.success(()))
    }
    
}



