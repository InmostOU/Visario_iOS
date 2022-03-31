//
//  CoreDataService.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 06.09.2021.
//

import Foundation
import CoreData

final class CoreDataService {
    
    typealias VoidCallback = () -> Void
    
    private let coreDataManager = CoreDataManager.shared
    
    func getChannels(by channelsArns: [String], callback: @escaping ([Channel]) -> Void) {
        coreDataManager.fetchChannels(by: channelsArns, callback: callback)
    }
    
    func getChatBotMessages(callback: @escaping ([BotMessage]) -> Void) {
        coreDataManager.fetchBotMessages(callback: callback)
    }
    
    func saveChannels(channels: [ChannelWithMessagesModel], callback: @escaping VoidCallback) {
        coreDataManager.saveChannels(channels: channels, callback: callback)
    }
    
    func deleteChannel(by channelArn: String, callback: @escaping VoidCallback) {
        coreDataManager.deleteChannel(by: channelArn, callback: callback)
    }
    
    func saveMessage(_ message: KitMessage, callback: @escaping VoidCallback) {
        coreDataManager.saveMessage(message: message, callback: callback)
    }
    
    func saveBotMessage(_ message: KitMessage, callback: @escaping VoidCallback) {
        coreDataManager.saveBotMessage(message: message, callback: callback)
    }
    
    func updateMessage(_ message: KitMessage, callback: @escaping VoidCallback) {
        coreDataManager.updateMessage(by: message, callback: callback)
    }
    
    func deleteMessage(_ message: KitMessage, callback: @escaping VoidCallback) {
        coreDataManager.deleteMessage(message: message, callback: callback)
    }
}
