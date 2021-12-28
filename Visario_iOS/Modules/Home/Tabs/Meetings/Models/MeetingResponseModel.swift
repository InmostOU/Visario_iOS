//
//  MeetingResponseModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 30.08.2021.
//

import Foundation
import AmazonChimeSDK

struct CreateMeetingResponseModel: Decodable {
    let meetingObject: MeetingResponseModel
    let attendeeObject: AttendeeResponseModel
}

struct MeetingResponseModel: Decodable {
    let meetingId: String
    let externalMeetingId: String
    let mediaPlacement: MediaPlacementModel
    let mediaRegion: String
}

struct MediaPlacementModel: Decodable {
    let audioHostUrl: String
    let audioFallbackUrl: String
    let screenDataUrl: String
    let screenSharingUrl: String
    let screenViewingUrl: String
    let signalingUrl: String
    let turnControlUrl: String
    
    func toMediaPlacement() -> MediaPlacement {
        return MediaPlacement(audioFallbackUrl: audioFallbackUrl, audioHostUrl: audioHostUrl, signalingUrl: signalingUrl, turnControlUrl: turnControlUrl)
    }
}
