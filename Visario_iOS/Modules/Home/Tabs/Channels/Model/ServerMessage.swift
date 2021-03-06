//
//  ServerMessage.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 13.08.2021.
//

import UIKit

enum TypeOfMessage: String, Decodable {
    case standard = "STANDARD"
    case system = "SYSTEM"
}

struct MessagesDataWrapper: Decodable {
    let status: Int
    let message: String
    let data: [ServerMessage]
}

struct ServerMessage: Decodable {
    let content: String
    let createdTimestamp: Int
    let lastEditedTimestamp: Int
    let messageId: String
    let metadata: String
    let redacted: Bool
    let senderArn: String
    let senderName: String
    let type: TypeOfMessage
    let channelArn: String
    let fromCurrentUser: Bool
    let delivered: Bool
    var imgData: Data?
    var imageURL: String?
    //var file: Data?
    var fileURL: String?
    var fileName: String?
    var audioDuration: Float?
}
