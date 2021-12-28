//
//  CoreDataService.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.09.2021.
//

import Foundation
import CoreData

final class CoreDataService {
    
    private let coreDataManager = CoreDataManager.shared
    
    func getChannels(callback: @escaping ([Channel]) -> Void) {
        coreDataManager.readChannels(callback: callback)
    }
    
    func saveChannels(channels: [ChannelWithMessagesModel], callback: @escaping () -> Void) {
        coreDataManager.saveChannels(channels: channels, callback: callback)
    }
    
    func deleteChannel(by channelArn: String, callback: @escaping () -> Void = { }) {
        coreDataManager.deleteChannel(by: channelArn, callback: callback)
    }
    
    func saveMessage(_ message: KitMessage, callback: @escaping () -> Void) {
        coreDataManager.saveMessage(message: message, callback: callback)
    }
    
    func updateMessage(_ message: KitMessage, callback: @escaping () -> Void) {
        coreDataManager.updateMessage(by: message, callback: callback)
    }
    
    func deleteMessage(_ message: KitMessage, callback: @escaping () -> Void) {
        coreDataManager.deleteMessage(message: message, callback: callback)
    }
}
