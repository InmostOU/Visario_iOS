//
//  ChannelModel.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 12.08.2021.
//

import Foundation

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

struct ChannelModel: Decodable {
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
