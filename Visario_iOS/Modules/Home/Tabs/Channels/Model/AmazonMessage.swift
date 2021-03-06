//
//  AmazonMessage.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 30.08.2021.
//

import Foundation

struct AmazonMessage: Decodable {
    let headers: Headers
    let payload: Payload

    enum CodingKeys: String, CodingKey {
        case headers = "Headers"
        case payload = "Payload"
    }
}

struct Headers: Decodable {
    let xAmzChimeEventType, xAmzChimeMessageType: String

    enum CodingKeys: String, CodingKey {
        case xAmzChimeEventType = "x-amz-chime-event-type"
        case xAmzChimeMessageType = "x-amz-chime-message-type"
    }
}

// MARK: - Welcome
struct Payload: Decodable {
    let content, persistence: String
    let redacted: Bool
    let lastUpdatedTimestamp: String
    let sender: Sender
    let type, messageID, createdTimestamp, channelArn: String
    let metadata: Metadata

    enum CodingKeys: String, CodingKey {
        case content = "Content"
        case persistence = "Persistence"
        case redacted = "Redacted"
        case lastUpdatedTimestamp = "LastUpdatedTimestamp"
        case sender = "Sender"
        case type = "Type"
        case messageID = "MessageId"
        case createdTimestamp = "CreatedTimestamp"
        case channelArn = "ChannelArn"
        case metadata = "Metadata"
    }
    
    struct Sender: Decodable {
        let name, arn: String

        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case arn = "Arn"
        }
    }
}

struct Metadata: Decodable {
    let fileName, fileType, messageID: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case fileName, fileType
        case messageID = "messageId"
        case url
    }
}
