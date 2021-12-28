//
//  Message+CoreDataProperties.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 01.12.2021.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var audioDuration: Float
    @NSManaged public var channelArn: String
    @NSManaged public var content: String
    @NSManaged public var createdTimestamp: Int64
    @NSManaged public var delivered: Bool
    @NSManaged public var file: Data?
    @NSManaged public var fileName: String?
    @NSManaged public var fileURL: String?
    @NSManaged public var fromCurrentUser: Bool
    @NSManaged public var image: Data?
    @NSManaged public var imageURL: String?
    @NSManaged public var lastEditedTimestamp: Int64
    @NSManaged public var messageID: String
    @NSManaged public var metadata: String
    @NSManaged public var redacted: Bool
    @NSManaged public var senderArn: String
    @NSManaged public var senderName: String
    @NSManaged public var type: String
    @NSManaged public var channel: Channel

}

extension Message : Identifiable {

}
