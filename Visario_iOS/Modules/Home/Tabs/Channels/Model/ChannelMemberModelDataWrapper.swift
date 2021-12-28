//
//  ChannelMemberModelDataWrapper.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 31.08.2021.
//

import Foundation

struct ChannelMembersDataWrapper: Decodable {
    let status: Int
    let message: String
    let data: [ChannelMember]
}

struct ChannelMember: Decodable {
    let userId: Int
    let fullName: String
    let username: String
    let mod: Bool
    let admin: Bool
}
