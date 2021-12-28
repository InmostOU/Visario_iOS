//
//  MeetingService.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 30.08.2021.
//

import Foundation
import AmazonChimeSDK
import AmazonChimeSDKMedia
import AVFoundation

final class MeetingService {
    
    static let shared = MeetingService()
    let logger = ConsoleLogger(name: "MeetingConsoleLogger")
    var meetingSession: DefaultMeetingSession?
    
    func createMeetingSession(meetingUrlData: MeetingResponseModel, attendeeData: AttendeeResponseModel) {
        
        let meeting = Meeting(externalMeetingId: meetingUrlData.externalMeetingId,
                              mediaPlacement: meetingUrlData.mediaPlacement.toMediaPlacement(),
                              mediaRegion: meetingUrlData.mediaRegion,
                              meetingId: meetingUrlData.meetingId)
        
        let attendee = Attendee(attendeeId: attendeeData.attendeeId,
                                externalUserId: attendeeData.externalUserId,
                                joinToken: attendeeData.joinToken)
        
        // Construct CreatMeetingResponse and CreateAttendeeResponse.
        let meetingResponse = CreateMeetingResponse(meeting: meeting)
        let attendeeResponse = CreateAttendeeResponse(attendee: attendee)

        // Construct MeetingSessionConfiguration.
        let meetingSessionConfig = MeetingSessionConfiguration(createMeetingResponse: meetingResponse,
                                                               createAttendeeResponse: attendeeResponse)
        
        self.meetingSession = DefaultMeetingSession(configuration: meetingSessionConfig, logger: logger)
    }
    
    func startAudioVideo() {
        
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if audioSession.category != .playAndRecord {
                try audioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                             options: AVAudioSession.CategoryOptions.allowBluetooth)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            }
            if audioSession.mode != .voiceChat {
                try audioSession.setMode(.voiceChat)
            }
        } catch {
            logger.error(msg: "Error configuring AVAudioSession: \(error.localizedDescription)")
        }
    }
}
