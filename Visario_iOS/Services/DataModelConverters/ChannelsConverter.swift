//
//  ChannelsConverter.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 14.09.2021.
//

import Foundation

final class ChannelsConverter {
    
    private let messagesConverter = MessagesConverter()
    
    // [ChannelModel] -> [ChannelWithMessages]
    func channelsWithMessages(from channelModels: [ChannelModel]) -> [ChannelWithMessagesModel] {
        var resultChannels: [ChannelWithMessagesModel] = []
        
        for channelModel in channelModels {
            let newChannelWithMessagesModel = ChannelWithMessagesModel(
                channelArn: channelModel.channelArn,
                metadata: channelModel.metadata,
                privacy: channelModel.privacy,
                name: channelModel.name,
                mode: channelModel.mode,
                isMember: channelModel.isMember,
                isModerator: channelModel.isModerator,
                isAdmin: channelModel.isAdmin,
                description: channelModel.description,
                messages: [],
                newMessages: []
            )
            resultChannels.append(newChannelWithMessagesModel)
        }
        return resultChannels
    }
    
    // [Channel] -> [ChannelWithMessagesModel]
    func channelsWithMessages(from coreDataChannels: [Channel]) -> [ChannelWithMessagesModel] {
        var channelsWithMessages: [ChannelWithMessagesModel] = []
        
        for channel in coreDataChannels {
            var messages: [ServerMessage] = []
            for message in channel.messagesArray {
                let newMessage = ServerMessage(content: message.content ?? "",
                                               createdTimestamp: Int(message.createdTimestamp),
                                               lastEditedTimestamp: Int(message.lastEditedTimestamp),
                                               messageId: message.messageID ?? "",
                                               metadata: message.metadata ?? "",
                                               redacted: message.redacted,
                                               senderArn: message.senderArn ?? "",
                                               senderName: message.senderName ?? "",
                                               type: message.type == "STANDARD" ? .standard: .system,
                                               channelArn: message.channelArn ?? "",
                                               fromCurrentUser: message.fromCurrentUser,
                                               delivered: message.delivered,
                                               imgData: message.image,
                                               fileURL: message.fileURL,
                                               fileName: message.fileName,
                                               audioDuration: message.audioDuration)
                messages.append(newMessage)
            }
            
            let newChannelWithMessages = ChannelWithMessagesModel(channelArn: channel.channelArn ?? "",
                                                                  metadata: channel.metadata ?? "",
                                                                  privacy: channel.privacy == "PUBLIC" ? .public: .private,
                                                                  name: channel.name ?? "",
                                                                  mode: channel.channelMode == "RESTRICTED" ? .restricted : .unrestricted,
                                                                  isMember: channel.isMember,
                                                                  isModerator: channel.isModerator,
                                                                  isAdmin: channel.isAdmin,
                                                                  description: channel.channelDescription,
                                                                  messages: messagesConverter.kitMessages(from: messages),
                                                                  newMessages: [])
            channelsWithMessages.append(newChannelWithMessages)
        }
        
        return channelsWithMessages
    }
}
