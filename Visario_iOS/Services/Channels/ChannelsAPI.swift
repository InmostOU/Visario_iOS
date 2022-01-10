//
//  ChannelsAPI.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 12.08.2021.
//

import Moya
import MessageKit
import MobileCoreServices

enum ChannelsAPI {
    case getAllChannels
    case createChannel(channel: ChannelModel)
    case leaveChannel(channelArn: String)
    case addMemberToChannel(channelArn: String, memberArn: String)
    case getChannelMembers(channelArn: String)
    case getChannelMembersActivityStatus(channelArn: String)
    case findChannels(name: String)
    case getMessagesList(channelArn: String)
    case sendTextMessage(message: KitMessage)
    case sendAttachmentMessage(message: KitMessage)
    case editMessage(message: KitMessage)
    case deleteMessage(id: String)
    case getWebSocketSignedURL
    case sendChatBotMessage(message: ChatBotMessageModel)
}

// MARK: - TargetType

extension ChannelsAPI: TargetType {
    
    static private var authToken: String {
        KeyChainStorage.shared.getAccessToken() ?? ""
    }
    
    var baseURL: URL {
        switch self {
        case .getChannelMembersActivityStatus:
            return URL(string: Constants.usersActivityBaseURL)!
        default:
            return URL(string: Constants.baseURL)!
        }
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
        case .getChannelMembers:
            return "/channels/fetchUsersFromChannel"
        case .findChannels:
            return "/channels/findByName"
        case .getChannelMembersActivityStatus:
            return "/channel/status"
        case .getMessagesList:
            return "/messages/list"
        case .sendTextMessage:
            return "/messages/send"
        case .sendAttachmentMessage:
            return "/messages/sendWithAttachment"
        case .sendChatBotMessage:
            return "/chat-bot/message"
        case .editMessage:
            return "/messages/edit"
        case .deleteMessage:
            return "/messages/delete"
        case .getWebSocketSignedURL:
            return "/websocket/getPresignedUrl"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAllChannels, .getMessagesList, .leaveChannel, .findChannels, .getWebSocketSignedURL, .getChannelMembers, .getChannelMembersActivityStatus:
            return .get
        case .sendTextMessage, .sendAttachmentMessage, .sendChatBotMessage, .createChannel, .addMemberToChannel, .editMessage:
            return .post
        case .deleteMessage:
            return .delete
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getAllChannels, .getMessagesList, .leaveChannel, .findChannels, .getWebSocketSignedURL, .getChannelMembers, .deleteMessage, .sendAttachmentMessage, .getChannelMembersActivityStatus:
            return Data()
        case .createChannel(let channel):
            return "{\"mode\":\"\(channel.mode.rawValue)\", \"name\":\"\(channel.name)\", \"privacy\":\"\(channel.privacy.rawValue)\", \"metadata\":\"\(channel.metadata ?? "")\", \"description\":\"\(channel.description ?? "")\"}".data(using: .utf8) ?? Data()
        case .addMemberToChannel(let channelArn, let memberArn):
            return "{\"channelArn\":\"\(channelArn)\", \"memberArn\":\"\(memberArn)\"}".data(using: .utf8) ?? Data()
        case .editMessage(let message):
            return "{\"messageId\":\"\(message.messageId)\", \"content\":\"\(message.content)\", \"channelArn\":\"\(message.channelArn)\"}".data(using: .utf8) ?? Data()
        case .sendTextMessage(let message):
            return messageJSONData(from: message)
        case .sendChatBotMessage(let botMessage):
            return "{\"message\":\"\(botMessage.message)\", \"lat\":\"\(botMessage.lat)\", \"lng\":\"\(botMessage.lng)\"}".data(using: .utf8) ?? Data()
        }
    }
    
    var task: Task {
        switch self {
        case .getAllChannels, .getWebSocketSignedURL:
            return .requestPlain
        case .getMessagesList(let channelArn),
             .leaveChannel(let channelArn),
             .getChannelMembers(let channelArn),
             .getChannelMembersActivityStatus(let channelArn):
            return .requestParameters(parameters: ["channelArn" : channelArn], encoding: URLEncoding.default)
        case .createChannel, .addMemberToChannel, .editMessage, .sendTextMessage, .sendChatBotMessage:
            return .requestData(sampleData)
        case .deleteMessage(let messageId):
            return .requestParameters(parameters: ["messageId" : messageId], encoding: URLEncoding.default)
        case .findChannels(let channelName):
            return .requestParameters(parameters: ["channelName" : channelName], encoding: URLEncoding.default)
        case .sendAttachmentMessage(let message):
            return multipartsTask(message: message)
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization" : ChannelsAPI.authToken,
                "Content-Type" : "application/json"]
    }
    
    private func messageJSONData(from message: KitMessage) -> Data {
        let json =
        """
            {
                "channelArn" : "\(message.channelArn)",
                "content" : "\(message.content)",
                "metadata" : {
                    "fileName" : "",
                    "fileType" : "",
                    "messageId" : "\(message.messageId)",
                    "url" : ""
                }
            }
        """
        return json.data(using: .utf8) ?? Data()
    }
    
    private func multipartsTask(message: KitMessage) -> Task {
        let fileType = message.fileName?.components(separatedBy: ".").last ?? ""
        let mimeType = mimeTypeForPath(path: message.content)
        
        let json =
        """
            {
                "channelArn" : "\(message.channelArn)",
                "content" : " ",
                "metadata" : {
                    "fileName" : "\(message.fileName ?? "")",
                    "fileType" : "\(fileType)",
                    "messageId" : "\(message.messageId)",
                    "url" : " "
                }
            }
        """
        
        var data = Data()
        
        if let file = message.file {
            data = file
        } else if let image = message.image {
            data = image.pngData() ?? Data()
        }
        
        var multiparts: [MultipartFormData] = []
        multiparts.append(MultipartFormData(provider: .data(data), name: "file", fileName: message.fileName, mimeType: mimeType))
        multiparts.append(MultipartFormData(provider: .data(json.data(using: .utf8) ?? Data()), name: "message"))
        return .uploadMultipart(multiparts)
    }
    
    private func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
}
