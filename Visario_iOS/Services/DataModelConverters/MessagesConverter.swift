//
//  MessagesConverter.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 14.09.2021.
//

import Foundation
import UIKit
import MessageKit

final class MessagesConverter {
    
    private let supportedImageTypes = SupportedImageFileType.allCases.map(\.rawValue)
    private let supportedTextFileTypes = SupportedTextFileType.allCases.map(\.rawValue)
    private let supportedAudioTypes = SupportedAudioFileType.allCases.map(\.rawValue)
    
    // [Message] -> [ServerMessage]
    func serverMessages(from coreDataMessages: [Message]) -> [ServerMessage] {
        var serverMessages: [ServerMessage] = []
        
        for coreDataMessage in coreDataMessages {
            let newServerMessage = ServerMessage(content: coreDataMessage.content,
                                                 createdTimestamp: Int(coreDataMessage.createdTimestamp),
                                                 lastEditedTimestamp: Int(coreDataMessage.lastEditedTimestamp),
                                                 messageId: coreDataMessage.messageID,
                                                 metadata: coreDataMessage.metadata,
                                                 redacted: coreDataMessage.redacted,
                                                 senderArn: coreDataMessage.senderArn,
                                                 senderName: coreDataMessage.senderName,
                                                 type: coreDataMessage.type == "STANDARD" ? .standard : .system,
                                                 channelArn: coreDataMessage.channelArn,
                                                 fromCurrentUser: coreDataMessage.fromCurrentUser,
                                                 delivered: coreDataMessage.delivered)
            
            serverMessages.append(newServerMessage)
        }
        return serverMessages
    }
    
    // AmazonMessageModel -> ServerMessage
    func serverMessage(from amazonMessage: AmazonMessage) -> ServerMessage? {
        guard let profile = KeyChainStorage.shared.getProfile() else { return nil }
        return ServerMessage(content: amazonMessage.payload.content,
                      createdTimestamp: Int(amazonMessage.payload.createdTimestamp) ?? 0,
                      lastEditedTimestamp: Int(amazonMessage.payload.lastUpdatedTimestamp) ?? 0,
                      messageId: amazonMessage.payload.messageID,
                      metadata: amazonMessage.payload.metadata.messageID,
                      redacted: amazonMessage.payload.redacted,
                      senderArn: amazonMessage.payload.sender.arn,
                      senderName: amazonMessage.payload.sender.name,
                      type: .standard,
                      channelArn: amazonMessage.payload.channelArn,
                      fromCurrentUser: amazonMessage.payload.sender.name == profile.username ? true : false,
                      delivered: false,
                      imgData: nil)
    }
    
    // AmazonMessage -> KitMessage
    func kitMessage(from message: AmazonMessage) -> KitMessage? {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return nil }
        let sender = Sender(senderId: message.payload.sender.arn, displayName: message.payload.sender.name)
        
        let date = message.payload.createdTimestamp.format(dateFormat: .ddMMYYYY)
        let timeInterval = TimeInterval(date.timeIntervalSince1970 * 1000)
        let createdTimeStamp = Date(timeIntervalSince1970: timeInterval)
        
        var imageURL: String?
        var fileURL: String?
        
        if supportedImageTypes.contains(message.payload.metadata.fileType) {
            imageURL = message.payload.metadata.url
        } else if supportedTextFileTypes.contains(message.payload.metadata.fileType) {
            fileURL = message.payload.metadata.url
        } else if supportedAudioTypes.contains(message.payload.metadata.fileType) {
            fileURL = message.payload.metadata.url
        }
        
        return KitMessage(sender: sender,
                          messageId: message.payload.messageID,
                          sentDate: createdTimeStamp,
                          content: message.payload.content,
                          createdTimestamp: Int(createdTimeStamp.timeIntervalSince1970),
                          lastEditedTimestamp: Int(createdTimeStamp.timeIntervalSince1970),
                          metadata: message.payload.metadata.messageID,
                          redacted: message.payload.redacted,
                          senderArn: message.payload.sender.arn,
                          senderName: message.payload.sender.name,
                          type: message.payload.type == "STANDARD" ? .standard : .system,
                          channelArn: message.payload.channelArn,
                          fromCurrentUser: userProfile.username == message.payload.sender.name ? true : false,
                          delivered: false,
                          image: nil,
                          imageURL: imageURL,
                          fileURL: fileURL,
                          fileName: message.payload.metadata.fileName + "." + message.payload.metadata.fileType)
    }
    
    // [ServerMessage] -> [KitMessage]
    func kitMessages(from netMessages: [ServerMessage]) -> [KitMessage] {
        netMessages.map { kitMessage(from: $0) }
    }
    
    // ServerMessage -> KitMessage
    func kitMessage(from serverMessage: ServerMessage) -> KitMessage {
        let sender = Sender(senderId: serverMessage.senderArn, displayName: serverMessage.senderName)
        let createdTimeStamp = Date(timeIntervalSince1970: TimeInterval(serverMessage.createdTimestamp))
        
        var imageURL: String?
        var fileURL: String?
        var fileName = ""
        
        if serverMessage.metadata.contains("url") {
            do {
                let data = serverMessage.metadata.data(using: .utf8) ?? Data()
                let metadata = try JSONDecoder().decode(Metadata.self, from: data)
                
                if supportedImageTypes.contains(metadata.fileType) {
                    imageURL = metadata.url
                } else if supportedTextFileTypes.contains(metadata.fileType) {
                    fileURL = metadata.url
                } else if supportedAudioTypes.contains(metadata.fileType) {
                    fileURL = metadata.url
                    fileName = metadata.fileName
                }
            } catch {
                print(error)
            }
        } else {
            imageURL = serverMessage.imageURL
            fileURL = serverMessage.fileURL
        }
        
        let kitMessage = KitMessage(sender: sender,
                                    messageId: serverMessage.messageId,
                                    sentDate: createdTimeStamp,
                                    content: serverMessage.content,
                                    createdTimestamp: serverMessage.createdTimestamp,
                                    lastEditedTimestamp: serverMessage.lastEditedTimestamp,
                                    metadata: serverMessage.metadata,
                                    redacted: serverMessage.redacted,
                                    senderArn: serverMessage.senderArn,
                                    senderName: serverMessage.senderName,
                                    type: serverMessage.type,
                                    channelArn: serverMessage.channelArn,
                                    fromCurrentUser: serverMessage.fromCurrentUser,
                                    delivered: serverMessage.delivered,
                                    image: serverMessage.imgData != nil ? UIImage(data: serverMessage.imgData!) : nil,
                                    imageURL: imageURL,
                                    fileURL: fileURL,
                                    fileName: fileName)
        return kitMessage
    }
    
    // KitMessage -> ServerMessage
    func serverMessage(from kitMessage: KitMessage) -> ServerMessage {
        var newMessage: ServerMessage!
        
        switch kitMessage.kind {
        case .text(let text):
            newMessage = ServerMessage(content: text,
                                       createdTimestamp: Int(kitMessage.sentDate.timeIntervalSince1970 * 1000),
                                       lastEditedTimestamp: 0,
                                       messageId: kitMessage.messageId,
                                       metadata: kitMessage.metadata,
                                       redacted: true,
                                       senderArn: kitMessage.sender.senderId,
                                       senderName: kitMessage.sender.displayName,
                                       type: .standard,
                                       channelArn: kitMessage.channelArn,
                                       fromCurrentUser: true,
                                       delivered: false,
                                       imgData: nil)
        case .photo(let photoItem):
            newMessage = ServerMessage(content: photoItem.url?.absoluteString ?? "",
                                       createdTimestamp: Int(kitMessage.sentDate.timeIntervalSince1970 * 1000),
                                       lastEditedTimestamp: 0,
                                       messageId: kitMessage.messageId,
                                       metadata: kitMessage.metadata,
                                       redacted: true,
                                       senderArn: kitMessage.sender.senderId,
                                       senderName: kitMessage.sender.displayName,
                                       type: .standard,
                                       channelArn: kitMessage.channelArn,
                                       fromCurrentUser: true,
                                       delivered: false,
                                       imgData: photoItem.image?.pngData())
        default:
            break
        }
        return newMessage
    }
}
