//
//  CoreDataManager.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.09.2021.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    private let delegate = UIApplication.shared.delegate as! AppDelegate
    static let shared = CoreDataManager()
    
    private init() { }
    
    // read channels
    func readChannels(callback: @escaping ([Channel]) -> Void) {
        delegate.persistentContainer.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<Channel>(entityName: "Channel")
            do {
                let channels = try context.fetch(fetchRequest)
                callback(channels)
            } catch {
                print(error)
                callback([])
            }
        }
    }
    
    // write channel
    func saveChannels(channels: [ChannelWithMessagesModel], callback: @escaping () -> Void) {
        delegate.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            for channel in channels {
                if !self.isExist(channel, in: context) {
                    let channelManagedObject = Channel(context: context)
                    // populate channel
                    channelManagedObject.channelArn = channel.channelArn
                    channelManagedObject.metadata = channel.metadata ?? ""
                    channelManagedObject.privacy = channel.privacy.rawValue
                    channelManagedObject.name = channel.name
                    channelManagedObject.channelMode = channel.mode.rawValue
                    channelManagedObject.isMember = channel.isMember ?? false
                    channelManagedObject.isModerator = channel.isModerator ?? false
                    channelManagedObject.isAdmin = channel.isAdmin ?? false
                    channelManagedObject.channelDescription = channel.description
                    
                    // populate message
                    for message in channel.messages {
                        let messageManagedObject = Message(context: context)
                        
                        messageManagedObject.content = message.content
                        messageManagedObject.createdTimestamp = Int64(message.createdTimestamp)
                        messageManagedObject.lastEditedTimestamp = Int64(message.lastEditedTimestamp)
                        messageManagedObject.messageID = message.messageId
                        messageManagedObject.metadata = message.metadata
                        messageManagedObject.redacted = message.redacted
                        messageManagedObject.senderArn = message.senderArn
                        messageManagedObject.senderName = message.senderName
                        messageManagedObject.type = message.type.rawValue
                        messageManagedObject.channelArn = message.channelArn
                        messageManagedObject.fromCurrentUser = message.fromCurrentUser
                        messageManagedObject.delivered = message.delivered
                        messageManagedObject.channel = channelManagedObject
                        
                        channelManagedObject.messages.adding(messageManagedObject)
                    }
                    
                    self.save(context: context)
                }
            }
            callback()
        }
    }
    
    // write message
    func saveMessage(message: KitMessage, callback: @escaping () -> Void) {
        delegate.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            if self.isExist(message, in: context) {
                self.updateMessage(by: message, callback: callback)
            } else {
                let request = NSFetchRequest<Channel>(entityName: "Channel")
                request.predicate = NSPredicate(format: "channelArn = %@", message.channelArn)
                request.fetchLimit = 1
                var channelManagedObject: Channel!
                
                do {
                    let result = try context.fetch(request)
                    guard let channel = result.first else { return }
                    channelManagedObject = channel
                } catch {
                    print(error.localizedDescription)
                }
                
                let messageManagedObject = Message(context: context)
                // populate message
                messageManagedObject.content = message.content
                messageManagedObject.createdTimestamp = Int64(message.createdTimestamp)
                messageManagedObject.lastEditedTimestamp = Int64(message.lastEditedTimestamp)
                messageManagedObject.messageID = message.messageId
                messageManagedObject.metadata = message.metadata
                messageManagedObject.redacted = message.redacted
                messageManagedObject.senderArn = message.senderArn
                messageManagedObject.senderName = message.senderName
                messageManagedObject.type = message.type.rawValue
                messageManagedObject.channelArn = message.channelArn
                messageManagedObject.fromCurrentUser = message.fromCurrentUser
                messageManagedObject.delivered = message.delivered
                messageManagedObject.image = message.image?.pngData()
                messageManagedObject.file = message.file
                messageManagedObject.imageURL = message.imageURL
                messageManagedObject.fileURL = message.fileURL
                messageManagedObject.fileName = message.fileName
                messageManagedObject.audioDuration = message.audioDuration ?? 0.0
                messageManagedObject.channel = channelManagedObject
                // populate channel
                channelManagedObject.messages.adding(messageManagedObject)
                
                self.save(context: context)
            }
            
            callback()
        }
    }
    
    // update message
    func updateMessage(by message: KitMessage, callback: @escaping () -> Void) {
        delegate.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            let request = NSFetchRequest<Channel>(entityName: "Channel")
            request.predicate = NSPredicate(format: "channelArn = %@", message.channelArn)
            request.fetchLimit = 1
            
            do {
                let result = try context.fetch(request)
                guard let channel = result.first else { return }
                
                (channel.messages.first(where: { ($0 as? Message)?.metadata == message.metadata }) as? Message)?.content = message.content
                (channel.messages.first(where: { ($0 as? Message)?.metadata == message.metadata }) as? Message)?.messageID = message.messageId
                (channel.messages.first(where: { ($0 as? Message)?.metadata == message.metadata }) as? Message)?.delivered = message.delivered
                (channel.messages.first(where: { ($0 as? Message)?.metadata == message.metadata }) as? Message)?.file = message.file
                (channel.messages.first(where: { ($0 as? Message)?.metadata == message.metadata }) as? Message)?.imageURL = message.imageURL
                (channel.messages.first(where: { ($0 as? Message)?.metadata == message.metadata }) as? Message)?.fileURL = message.fileURL
                (channel.messages.first(where: { ($0 as? Message)?.metadata == message.metadata }) as? Message)?.fileName = message.fileName
                (channel.messages.first(where: { ($0 as? Message)?.metadata == message.metadata }) as? Message)?.audioDuration = message.audioDuration ?? 0.0
                
                if let imageData = message.image?.pngData() {
                    (channel.messages.first(where: { ($0 as? Message)?.metadata == message.metadata }) as? Message)?.image = imageData
                }
                
                self.save(context: context)
                callback()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // delete channel
    func deleteChannel(by channelArn: String, callback: @escaping () -> Void = { }) {
        delegate.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
            request.predicate = NSPredicate(format: "channelArn = %@", channelArn)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print(error)
            }
            
            self.save(context: context)
            callback()
        }
    }
    
    // delete message
    func deleteMessage(message: KitMessage, callback: @escaping () -> Void = { }) {
        delegate.persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            let request = NSFetchRequest<Channel>(entityName: "Channel")
            request.predicate = NSPredicate(format: "channelArn = %@", message.channelArn)
            request.fetchLimit = 1
            
            do {
                let result = try context.fetch(request)
                guard let channel = result.first else { return }
                guard let messageToDelete = channel.messagesArray.first(where: { $0.messageID == message.messageId }) else { return }
                channel.removeFromMessages(messageToDelete)
                
                self.save(context: context)
                callback()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // is exist message
    private func isExist(_ message: KitMessage, in context: NSManagedObjectContext) -> Bool {
        let request = NSFetchRequest<Channel>(entityName: "Channel")
        request.predicate = NSPredicate(format: "channelArn = %@", message.channelArn)
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            guard let channel = result.first else { return false }
            return channel.messagesArray.contains { $0.metadata == message.metadata }
        } catch {
            print(error.localizedDescription)
        }
        
        return false
    }
    
    // is exist channel
    private func isExist(_ channel: ChannelWithMessagesModel, in context: NSManagedObjectContext) -> Bool {
        let request = NSFetchRequest<Channel>(entityName: "Channel")
        request.predicate = NSPredicate(format: "channelArn = %@", channel.channelArn)
        
        do {
            let result = try context.fetch(request)
            return result.contains { $0.channelArn == channel.channelArn }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    // save context
    private func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Could not save context. \(error)")
        }
    }
}
