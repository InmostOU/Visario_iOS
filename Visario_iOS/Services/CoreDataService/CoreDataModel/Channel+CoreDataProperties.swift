//
//  Channel+CoreDataProperties.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 30.11.2021.
//
//

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }

    @NSManaged public var channelArn: String?
    @NSManaged public var channelDescription: String?
    @NSManaged public var channelMode: String?
    @NSManaged public var isAdmin: Bool
    @NSManaged public var isMember: Bool
    @NSManaged public var isModerator: Bool
    @NSManaged public var metadata: String?
    @NSManaged public var name: String?
    @NSManaged public var privacy: String?
    @NSManaged public var messages: NSSet
    
    public var messagesArray: [Message] {
        let set = messages as? Set<Message> ?? []
        return Array(set).sorted(by: { $0.createdTimestamp < $1.createdTimestamp })
    }

}

// MARK: Generated accessors for messages
extension Channel {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

extension Channel : Identifiable {

}
