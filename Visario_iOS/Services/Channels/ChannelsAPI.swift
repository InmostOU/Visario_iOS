//
//  ChannelsAPI.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 12.08.2021.
//

import Moya

enum ChannelsAPI {
    case getAllChannels
    case createChannel(channel: ChannelModel)
    case leaveChannel(channelArn: String)
    case addMemberToChannel(channelArn: String, memberArn: String)
    case findChannels(name: String)
    case getMessagesList(channelArn: String)
    case sendMessage(message: ServerMessage)
    case getWebSocketSignedURL
}

// MARK: - TargetType

extension ChannelsAPI: TargetType {
    
    static private var authToken: String {
        KeyChainStorage.shared.getAccessToken() ?? ""
    }
    
    var baseURL: URL {
        return URL(string: Constants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getAllChannels:
            return "/channels/getChannelsMemberships"
        case .createChannel:
            return "/channels/create"
        case .leaveChannel:
            return "/channels/leaveChannel"
        case .addMemberToChannel:
            return "/channels/addMemberToChannel"
        case .findChannels:
            return "/channels/findByName"
        case .getMessagesList:
            return "/messages/list"
        case .sendMessage:
            return "/messages/send"
        case .getWebSocketSignedURL:
            return "/websocket/getPresignedUrl"
        }
    }
    
    var method: Method {
        switch self {
        case .getAllChannels, .getMessagesList, .leaveChannel, .findChannels, .getWebSocketSignedURL:
            return .get
        case .sendMessage, .createChannel, .addMemberToChannel:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getAllChannels, .getMessagesList, .leaveChannel, .findChannels, .getWebSocketSignedURL:
            return Data()
        case .createChannel(let channel):
            return "{\"mode\":\"\(channel.mode.rawValue)\", \"name\":\"\(channel.name)\", \"privacy\":\"\(channel.privacy.rawValue)\", \"metadata\":\"\(channel.metadata ?? "")\", \"description\":\"\(channel.description ?? "")\"}".data(using: .utf8) ?? Data()
        case .addMemberToChannel(let channelArn, let memberArn):
            return "{\"channelArn\":\"\(channelArn)\", \"memberArn\":\"\(memberArn)\"}".data(using: .utf8) ?? Data()
        case .sendMessage(let message):
            return "{\"channelArn\":\"\(message.channelArn)\", \"content\":\"\(message.content)\", \"metadata\":\"\(message.metadata)\"}".data(using: .utf8) ?? Data()
        }
    }
    
    var task: Task {
        switch self {
        case .getAllChannels, .getWebSocketSignedURL:
            return .requestPlain
        case .getMessagesList(let channelArn), .leaveChannel(let channelArn):
            return .requestParameters(parameters: ["channelArn" : channelArn], encoding: URLEncoding.default)
        case .sendMessage, .createChannel, .addMemberToChannel:
            return .requestData(sampleData)
        case .findChannels(let channelName):
            return .requestParameters(parameters: ["channelName" : channelName], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization" : ChannelsAPI.authToken,
                "Content-Type" : "application/json"]
    }
    
}
