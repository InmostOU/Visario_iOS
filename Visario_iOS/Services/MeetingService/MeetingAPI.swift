//
//  MeetingAPI.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 23.09.2021.
//

import Moya

enum MeetingAPI {
    case createMeeting
    case getMeeting(meetingId: String)
    case getUserInfoByUserId(meetingId: String, userId: String)
    case deleteAttendee(meetingId: String, userId: String)
}

// MARK: - TargetType

extension MeetingAPI: TargetType {
    
    static private var authToken: String {
        KeyChainStorage.shared.getAccessToken() ?? ""
    }
    
    var baseURL: URL {
        return URL(string: Constants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .createMeeting:
            return "/meeting/create"
        case .getMeeting:
            return "/meeting/getMeeting"
        case .getUserInfoByUserId:
            return "/meeting/getUserInfoByUserId"
        case .deleteAttendee:
            return "/meeting/deleteAttendee"
        }
    }
    
    var method: Method {
        switch self {
        case .getMeeting:
            return .get
        case .createMeeting, .getUserInfoByUserId, .deleteAttendee:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        case .createMeeting, .getMeeting:
            return Data()
        case .getUserInfoByUserId(let meetingId, let userId):
            return "{\"meetingId\":\"\(meetingId)\", \"userId\":\"\(userId)\"}".data(using: .utf8) ?? Data()
        case .deleteAttendee(let meetingId, let userId):
            return "{\"meetingId\":\"\(meetingId)\", \"userId\":\"\(userId)\"}".data(using: .utf8) ?? Data()
        }
    }
    
    var task: Task {
        switch self {
        case .createMeeting, .getUserInfoByUserId, .deleteAttendee:
            return .requestData(sampleData)
        case .getMeeting(let meetingId):
            return .requestParameters(parameters: ["meetingId" : meetingId], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization" : MeetingAPI.authToken,
                "Content-Type" : "application/json"]
    }
    
}

