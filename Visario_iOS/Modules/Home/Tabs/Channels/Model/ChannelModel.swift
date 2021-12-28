//
//  ChannelModel.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 12.08.2021.
//

import Foundation

protocol ChannelModelInterface {
    var channelArn: String { get set }
    var metadata: String? { get set }
    var privacy: ChannelPrivacy { get set }
    var name: String { get set }
    var mode: ChannelMode { get set }
    var isMember: Bool? { get set }
    var isModerator: Bool? { get set }
    var isAdmin: Bool? { get set }
    var description: String? { get set }
}

enum ChannelPrivacy: String, Decodable {
    case `public` = "PUBLIC"
    case `private` = "PRIVATE"
}

enum ChannelMode: String, Decodable {
    case restricted = "RESTRICTED"
    case unrestricted = "UNRESTRICTED"
}

struct ChannelsDataWrapper: Decodable {
    let status: Int
    let message: String
    let data: [ChannelModel]
}

struct ChannelModel: ChannelModelInterface, Decodable, Hashable {
    var channelArn: String
    var metadata: String?
    var privacy: ChannelPrivacy
    var name: String
    var mode: ChannelMode
    var isMember: Bool?
    var isModerator: Bool?
    var isAdmin: Bool?
    var description: String?
    
    static var placeholder: ChannelModel {
        ChannelModel(channelArn: "", metadata: "", privacy: .public, name: "", mode: .restricted, isMember: true, isModerator: true, isAdmin: true, description: "")
    }
}

struct ChannelWithMessagesModel: ChannelModelInterface {
    var channelArn: String
    var metadata: String?
    var privacy: ChannelPrivacy
    var name: String
    var mode: ChannelMode
    var isMember: Bool?
    var isModerator: Bool?
    var isAdmin: Bool?
    var description: String?
    var messages: [KitMessage]
    var newMessages: [KitMessage]
}

// MARK: - Equatable

extension ChannelWithMessagesModel: Equatable {
    
    static func == (lhs: ChannelWithMessagesModel, rhs: ChannelWithMessagesModel) -> Bool {
        return lhs.channelArn == rhs.channelArn && lhs.name == rhs.name
    }
    
}
