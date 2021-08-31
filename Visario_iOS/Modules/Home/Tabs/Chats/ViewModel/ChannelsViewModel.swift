//
//  ChannelsViewModel.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 12.08.2021.
//

import Moya
import MessageKit

final class ChannelsViewModel {
    
    typealias VoidCallback = (Result<Void, Error>) -> Void
    typealias Section = SectionModel<String, CreateChannelDataSource>
    
    // MARK: - Properties
    
    private let channelsAPIService = ChannelsAPIService()
    
    private(set) var channels: [ChannelModel] = []
    private(set) var findedChannels: [ChannelModel] = []
    private(set) var messages: [KitMessage] = []
    private(set) var channelsSections: [Section] = []
    
    var newChannel = ChannelModel.placeholder
    
    weak var view: (BaseView & UIViewController)?
    
    // MARK: - Methods
    
    func getAllChannels(callback: @escaping VoidCallback) {
        channelsAPIService.getAllChannels { [unowned self] response in
            switch response {
            case .success(let channels):
                self.channels = channels
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func createChannel(callback: @escaping VoidCallback) {
        channelsAPIService.createChannel(channel: newChannel, callback: callback)
    }
    
    func leaveChannel(channelArn: String, callback: @escaping VoidCallback) {
        channelsAPIService.leaveChannel(channelArn: channelArn) { response in
            switch response {
            case .success(let void):
                self.channels.removeAll { $0.channelArn == channelArn }
                callback(.success(void))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func addMemberToChannel(channelArn: String, memberArn: String, callback: @escaping VoidCallback) {
        channelsAPIService.addMemberToChannel(channelArn: channelArn, memberArn: memberArn, callback: callback)
    }
    
    func findChannel(name: String, callback: @escaping VoidCallback) {
        channelsAPIService.findChannels(name: name) { [unowned self] response in
            switch response {
            case .success(let channels):
                self.findedChannels = channels
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func getMessages(channelArn: String, callback: @escaping VoidCallback) {
        channelsAPIService.getMessagesList(channelArn: channelArn) { [unowned self] response in
            switch response {
            case .success(let serverMessages):
                self.messages = kitMessages(from: serverMessages)
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func sendMessage(message: KitMessage, callback: @escaping VoidCallback) {
        messages.append(message)
        
        switch message.kind {
        case .text(let content):
            let newMessage = ServerMessage(
                content: content,
                createdTimestamp: Int(message.sentDate.timeIntervalSince1970),
                lastEditedTimestamp: 0,
                messageId: message.messageId,
                metadata: message.sender.displayName,
                redacted: true,
                senderArn: message.sender.senderId,
                senderName: message.sender.displayName,
                type: .standard,
                channelArn: message.channelArn,
                fromCurrentUser: true)
            
            channelsAPIService.sendMessage(message: newMessage) { response in
                switch response {
                case .success(let void):
                    callback(.success(void))
                case .failure(let error):
                    self.view?.showError(error: error)
                    callback(.failure(error))
                }
            }
        default:
            return
        }
    }
    
    func getWebSocketSignedURL(callback: @escaping (Result<WebSocketResponse, Error>) -> Void) {
        channelsAPIService.getWebSocketSignedUrl(callback: callback)
    }
    
    func addChannelRestrictionModel() {
        let privacyDataModel = ChannelPrivacyModel(title: "Restricted", description: "Administrators, moderators, and channel members can add themselves and other members to unrestricted channels. Only administrators and moderators can add members to restricted channels", privacy: .private, mode: .unrestricted)
        let privacySectionItem = CreateChannelDataSource.privacy(privacyDataModel)
        channelsSections.indices.last.map { channelsSections[$0].items.append(privacySectionItem) }
    }
    
    func removeChannelRestrictionModel() {
        guard let lastSectionIndex = channelsSections.indices.last else { return }
        channelsSections[lastSectionIndex].items.removeLast()
    }
    
    func setChannelRestriction(mode: ChannelMode) {
        newChannel.mode = mode
    }
    
    func setChannelPrivacy(privacy: ChannelPrivacy) {
        newChannel.privacy = privacy
        switch privacy {
        case .public:
            removeChannelRestrictionModel()
        case .private:
            addChannelRestrictionModel()
            setChannelRestriction(mode: .unrestricted)
        }
    }
    
    func createSections() {
        let nameDataSource = CreateChannelDataSource.name("")
        let nameSection = Section(title: "Set name", items: [nameDataSource])
        
        let descriptionDataSource = CreateChannelDataSource.description("Description")
        let descriptionSection = Section(title: "Set description", items: [descriptionDataSource])
        
        let privacyDataModel = ChannelPrivacyModel(title: "Private", description: "if switch is On - channel will be PRIVATE - visible only current user, else channel will be  PUBLIC - visible for all", privacy: .public, mode: .restricted)
        let privacySectionItem = CreateChannelDataSource.privacy(privacyDataModel)
        let privacySection = Section(title: "Set privacy", items: [privacySectionItem])
        
        channelsSections = [nameSection, descriptionSection, privacySection]
    }
    
    func removeAllFindedChannels() {
        findedChannels.removeAll()
    }
    
    // [ServerMessage] -> [KitMessage]
    private func kitMessages(from netMessages: [ServerMessage]) -> [KitMessage] {
        var kitMessages: [KitMessage] = []
        
        for netMessage in netMessages {
            let sender = Sender(senderId: netMessage.senderArn, displayName: netMessage.senderName)
            let createdTimeStamp = Date(timeIntervalSince1970: TimeInterval(netMessage.createdTimestamp))
            
            let kitMessage = KitMessage(sender: sender,
                                        messageId: netMessage.messageId ?? "",
                                        sentDate: createdTimeStamp,
                                        kind: .text(netMessage.content),
                                        channelArn: netMessage.channelArn,
                                        metadata: "")
            kitMessages.append(kitMessage)
        }
        return kitMessages
    }
}
