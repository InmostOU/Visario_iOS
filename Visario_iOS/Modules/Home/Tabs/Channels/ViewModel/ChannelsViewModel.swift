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
    
    private let meetingAPIService = MeetingAPIService()
    private let channelsAPIService = ChannelsAPIService()
    private let coreDataService = CoreDataService()
    private let filesService = FilesService()
    private let contactsService = ContactsAPIService()
    
    private let messagesConverter = MessagesConverter()
    private let channelsConverter = ChannelsConverter()
    
    // storage
    private(set) var channels: [ChannelWithMessagesModel] = []
    private(set) var findedChannels: [ChannelWithMessagesModel] = []
    private(set) var createChannelSections: [Section] = []
    private(set) var channelMembers: [ChannelMember] = []
    private(set) var filteredMembers: [ChannelMember] = []
    private(set) var chatBotMessages: [KitMessage] = []
    
    var newChannel = ChannelModel.placeholder
    var isChannelsListInFocus = false
    
    weak var view: (BaseView & UIViewController)?
    
    // MARK: - Methods
    
    init() {
        setupCompletions()
    }
    
    private func setupCompletions() {
        filesService.savingCompletion = {
            self.view?.view.showSuccessHUD()
        }
    }
    
    func getAllChannels(callback: @escaping VoidCallback) {
        coreDataService.getChannels { [weak self] coreDataChannels in
            guard let self = self else { return }
            self.channels = self.channelsConverter.channelsWithMessages(from: coreDataChannels)
            //callback(.success(()))
            if ConnectivityManager.shared.isNetworkAvailable {
                self.getChannelsFromServer(callback: callback)
            } else {
                callback(.success(()))
            }
        }
    }
    
    func createMeeting(callback: @escaping (Result<String, Error>) -> Void) {
        meetingAPIService.createMeeting { result in
            switch result {
            case .success(let meetingResponse):
                callback(.success(meetingResponse.meetingObject.meetingId))
            case .failure(let error):
                callback(.failure(error))
                print(error)
            }
        }
    }
    
    private func getChannelsFromServer(callback: @escaping VoidCallback) {
        // get channels from server
        channelsAPIService.getAllChannels { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let serverChannels):
                self.addMessagesToChannels(channels: serverChannels) { response in
                    switch response {
                    case .success(let channelsWithMessages):
                        self.updateChannels(fetchedChannels: channelsWithMessages) {
                            callback(.success(()))
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    private func addMessagesToChannels(channels: [ChannelModel], callback: @escaping (Result<[ChannelWithMessagesModel], Error>) -> Void) {
        var newChannels: [ChannelWithMessagesModel] = channelsConverter.channelsWithMessages(from: channels)
        let group = DispatchGroup()
        for channel in channels {
            group.enter()
            self.getMessages(by: channel.channelArn) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let serverMessages):
                    group.leave()
                    guard let channelIndex = channels.firstIndex(where: { $0.channelArn == channel.channelArn }) else { return }
                    newChannels[channelIndex].messages = self.messagesConverter.kitMessages(from: serverMessages)
                    newChannels[channelIndex].messages.sort { $0.sentDate < $1.sentDate }
                case .failure(let error):
                    print(error.localizedDescription)
                    callback(.failure(error))
                }
            }
        }
        group.notify(queue: .main) {
            callback(.success(newChannels))
        }
    }
    
    private func updateChannels(fetchedChannels: [ChannelWithMessagesModel], callback: @escaping () -> Void) {
        channels = fetchedChannels
        coreDataService.saveChannels(channels: fetchedChannels, callback: callback)
    }
    
    func createChannel(callback: @escaping VoidCallback) {
        channelsAPIService.createChannel(channel: newChannel, callback: callback)
    }
    
    func leaveChannel(channelArn: String, callback: @escaping VoidCallback) {
        channelsAPIService.leaveChannel(channelArn: channelArn) { response in
            switch response {
            case .success(let void):
                self.channels.removeAll { $0.channelArn == channelArn }
                self.coreDataService.deleteChannel(by: channelArn)
                callback(.success(void))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func addMemberToChannel(channelArn: String, memberArn: String, callback: @escaping (Result<Void, NetworkError>) -> Void) {
        channelsAPIService.addMemberToChannel(channelArn: channelArn, memberArn: memberArn, callback: callback)
    }
    
    func getChannelMembers(channelArn: String, callback: @escaping VoidCallback) {
        channelsAPIService.getChannelMembers(channelArn: channelArn) { response in
            switch response {
            case .success(let members):
                self.channelMembers = members
                self.filteredMembers = members
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func getContactsActivityStatus(by userArn: String, callback: @escaping (Result<Void, Error>) -> Void) {
        contactsService.getContactsActivityStatus(by: userArn) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let contacts):
                for contact in contacts {
                    if let memberIndex = self.filteredMembers.firstIndex(where: { $0.userArn == contact.userArn }) {
                        self.filteredMembers[memberIndex].online = contact.status == "online" ? true : false
                        self.filteredMembers[memberIndex].lastSeen = contact.lastSeen
                    }
                }
                callback(.success(()))
            case .failure(let error):
                print(error)
                callback(.failure(error))
            }
        }
    }
    
    func getChannelMembersActivityStatus(channelArn: String, callback: @escaping (Result<Void, Error>) -> Void) {
        channelsAPIService.getChannelMembersActivityStatus(channelArn: channelArn) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let contacts):
                for contact in contacts {
                    if let memberIndex = self.filteredMembers.firstIndex(where: { $0.userArn == contact.userArn }) {
                        self.filteredMembers[memberIndex].lastSeen = contact.lastSeen
                    }
                }
                callback(.success(()))
            case .failure(let error):
                print(error)
                callback(.failure(error))
            }
        }
    }
    
    func filterMembers(by name: String) {
        filteredMembers = channelMembers.filter { $0.username.contains(name.lowercased()) }
    }
    
    func resetMembersFilters() {
        filteredMembers = channelMembers
    }
    
    func findChannels(name: String, callback: @escaping VoidCallback) {
        channelsAPIService.findChannels(name: name) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let channels):
                self.findedChannels = self.channelsConverter.channelsWithMessages(from: channels)
                
                let group = DispatchGroup()
                for channel in channels {
                    group.enter()
                    self.getMessages(by: channel.channelArn) { result in
                        switch result {
                        case .success(let serverMessages):
                            group.leave()
                            guard let channelIndex = self.findedChannels.firstIndex(where: { $0.channelArn == channel.channelArn }) else { return }
                            self.findedChannels[channelIndex].messages = self.messagesConverter.kitMessages(from: serverMessages).sorted { $0.sentDate < $1.sentDate}
                        case .failure(let error):
                            print(error.localizedDescription)
                            callback(.failure(error))
                        }
                    }
                }
                group.notify(queue: .main) {
                    callback(.success(()))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func getMessages(by channelArn: String, callback: @escaping (Result<[ServerMessage], Error>) -> Void) {
        channelsAPIService.getMessagesList(channelArn: channelArn) { response in
            switch response {
            case .success(let messages):
                callback(.success(messages))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func updateMessage(message: AmazonMessage, callback: @escaping () -> Void) {
        guard let channelIndex = channels.firstIndex(where: { $0.channelArn == message.payload.channelArn }) else { return }
        guard var kitMessage = messagesConverter.kitMessage(from: message) else { return }
        
        if let messageIndex = channels[channelIndex].messages.firstIndex(where: { $0.messageId == message.payload.metadata.messageID }) {
            channels[channelIndex].messages[messageIndex].delivered = true
            channels[channelIndex].messages[messageIndex].messageId = message.payload.messageID
            kitMessage.delivered = true
            coreDataService.updateMessage(kitMessage) {
                callback()
            }
        } else {
            channels[channelIndex].messages.append(kitMessage)
            coreDataService.saveMessage(kitMessage) {
                if self.isChannelsListInFocus {
                    self.channels[channelIndex].newMessages.append(kitMessage)
                }
                callback()
            }
        }
    }
    
    func sendMessage(message: KitMessage, callback: @escaping VoidCallback) {
        guard let channelIndex = channels.firstIndex(where: { $0.channelArn == message.channelArn }) else { return }
        channels[channelIndex].messages.append(message)
        callback(.success(()))
        
        self.coreDataService.saveMessage(message) {
            self.channelsAPIService.sendMessage(message: message) { response in
                switch response {
                case .success(let void):
                    callback(.success(void))
                case .failure(let error):
                    self.view?.showError(error: error)
                    callback(.failure(error))
                }
            }
        }
    }
    
    func resendMessage(message: KitMessage, callback: @escaping VoidCallback) {
        channelsAPIService.sendMessage(message: message, callback: callback)
    }
    
    func editMessage(message: KitMessage, callback: @escaping VoidCallback) {
        guard let channelIndex = channels.firstIndex(where: { $0.channelArn == message.channelArn }) else { return }
        guard let messageIndex = channels[channelIndex].messages.firstIndex(where: { $0.messageId == message.messageId }) else { return }
        channels[channelIndex].messages[messageIndex].content = message.content
        callback(.success(()))
        
        coreDataService.updateMessage(message) {
            self.channelsAPIService.editMessage(message: message, callback: callback)
        }
    }
    
    func updateImage(from message: KitMessage) {
        guard let channelIndex = channels.firstIndex(where: { $0.channelArn == message.channelArn }) else { return }
        guard let messageIndex = channels[channelIndex].messages.firstIndex(where: { $0.messageId == message.messageId }) else { return }
        channels[channelIndex].messages[messageIndex].image = message.image
        coreDataService.updateMessage(message) { }
    }
    
    func deleteMessage(message: KitMessage, callback: @escaping (Result<Void, NetworkError>) -> Void) {
        coreDataService.deleteMessage(message) {
            self.channelsAPIService.deleteMessage(messageID: message.messageId) { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .success(let void):
                    guard let channelIndex = self.channels.firstIndex(where: { $0.channelArn == message.channelArn }) else { return }
                    self.channels[channelIndex].messages.removeAll(where: { $0.messageId == message.messageId })
                    callback(.success(void))
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        }
    }
    
    func addFileToMessage(message: KitMessage, callback: @escaping () -> Void) {
        guard let channelIndex = channels.firstIndex(where: { $0.channelArn == message.channelArn }) else { return }
        guard let messageIndex = channels[channelIndex].messages.firstIndex(where: { $0.messageId == message.messageId }) else { return }
        channels[channelIndex].messages[messageIndex].file = message.file
        channels[channelIndex].messages[messageIndex].fileURL = message.fileURL
        channels[channelIndex].messages[messageIndex].fileName = message.fileName
        channels[channelIndex].messages[messageIndex].audioDuration = message.audioDuration
        
        coreDataService.updateMessage(message) {
            DispatchQueue.main.async {
                callback()
            }
        }
    }
    
    func sendMessageToBot(message: KitMessage, callback: @escaping(Result<Void, Error>) -> Void) {
        chatBotMessages.append(message)
        callback(.success(()))
    }
    
    func setActivityState(of contact: ContactModel) {
        guard let memberIndex = filteredMembers.firstIndex(where: { $0.userArn == contact.userArn }) else { return }
        channelMembers[memberIndex].online = contact.online ?? false
        filteredMembers[memberIndex].online = contact.online ?? false
    }
    
    func getWebSocketSignedURL(callback: @escaping (Result<WebSocketResponse, Error>) -> Void) {
        channelsAPIService.getWebSocketSignedUrl(callback: callback)
    }
    
    func addChannelRestrictionModel() {
        let privacyDataModel = ChannelPrivacyModel(title: "Restricted", description: "Administrators, moderators, and channel members can add themselves and other members to unrestricted channels. Only administrators and moderators can add members to restricted channels", privacy: .private, mode: .unrestricted)
        let privacySectionItem = CreateChannelDataSource.privacy(privacyDataModel)
        createChannelSections.indices.last.map { createChannelSections[$0].items.append(privacySectionItem) }
    }
    
    func removeChannelRestrictionModel() {
        guard let lastSectionIndex = createChannelSections.indices.last else { return }
        createChannelSections[lastSectionIndex].items.removeLast()
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
        
        createChannelSections = [nameSection, descriptionSection, privacySection]
    }
    
    func removeAllFindedChannels() {
        findedChannels.removeAll()
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        filesService.writeToPhotoAlbum(image: image)
    }
    
    func removeNewMessagesFromChannel(by channelArn: String) {
        guard let channelIndex = channels.firstIndex(where: { $0.channelArn == channelArn }) else { return }
        channels[channelIndex].newMessages.removeAll()
    }
}

// MARK: - Router methods

extension ChannelsViewModel {
    
    func showContactInfo(with profile: ContactModel) {
        let profileViewModel = ProfileViewModel(profile: profile)
        let profileViewController = ProfileViewController(viewModel: profileViewModel)
        view?.navigationController?.pushViewController(profileViewController, animated: true)
    }
}

