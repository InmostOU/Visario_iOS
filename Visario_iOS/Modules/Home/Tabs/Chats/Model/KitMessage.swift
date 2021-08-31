//
//  KitMessage.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 15.08.2021.
//

import MessageKit

struct KitMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    // extended
    let channelArn: String
    let metadata: String
}

