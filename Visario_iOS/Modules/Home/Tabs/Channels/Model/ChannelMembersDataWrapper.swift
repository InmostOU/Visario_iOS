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
    let id: Int
    let userArn: String
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    let phoneNumber: String
    let image: String
    let about: String
    var online: Bool
    let inMyContacts: Bool
    let isAdmin: Bool
    let isMod: Bool
    var lastSeen: Int?
}
