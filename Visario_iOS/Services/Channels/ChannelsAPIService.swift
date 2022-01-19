//
//  ChannelsAPIService.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 12.08.2021.
//

import Moya
import MessageKit

final class ChannelsAPIService {
    
    typealias VoidCallback = (Result<Void, Error>) -> Void
    
    // MARK: - Properties
    
    let channelsProvider = MoyaProvider<ChannelsAPI>()
    
    // MARK: - Methods
    
    func getAllChannels(callback: @escaping (Result<[ChannelModel], Error>) -> Void) {
        channelsProvider.request(.getAllChannels) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let channelsWrapper = try JSONDecoder().decode(ChannelsDataWrapper.self, from: response.data)
                    callback(.success(channelsWrapper.data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func createChannel(channel: ChannelModel, callback: @escaping VoidCallback) {
        channelsProvider.request(.createChannel(channel: channel)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func leaveChannel(channelArn: String, callback: @escaping VoidCallback) {
        channelsProvider.request(.leaveChannel(channelArn: channelArn)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func addMemberToChannel(channelArn: String, memberArn: String, callback: @escaping (Result<Void, NetworkError>) -> Void) {
        channelsProvider.request(.addMemberToChannel(channelArn: channelArn, memberArn: memberArn)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    do {
                        let errorModel = try JSONDecoder().decode(ErrorResponse.self, from: response.data)
                        callback(.failure(.errorResponse(errorModel)))
                    } catch {
                        callback(.failure(.errorMessage(error.localizedDescription)))
                    }
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(.errorMessage(error.localizedDescription)))
            }
        }
    }
    
    func getChannelMembers(channelArn: String, callback: @escaping (Result<[ChannelMember], Error>) -> Void) {
        channelsProvider.request(.getChannelMembers(channelArn: channelArn)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let channelsWrapper = try JSONDecoder().decode(ChannelMembersDataWrapper.self, from: response.data)
                    callback(.success(channelsWrapper.data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func getChannelMembersActivityStatus(channelArn: String, callback: @escaping (Result<[ContactActivityModel], Error>) -> Void) {
        channelsProvider.request(.getChannelMembersActivityStatus(channelArn: channelArn)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let channelsWrapper = try JSONDecoder().decode(ContactsActivityStatusDataWrapper.self, from: response.data)
                    callback(.success(channelsWrapper.data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func findChannels(name: String, callback: @escaping (Result<[ChannelModel], Error>) -> Void) {
        channelsProvider.request(.findChannels(name: name)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let channelsWrapper = try JSONDecoder().decode(ChannelsDataWrapper.self, from: response.data)
                    callback(.success(channelsWrapper.data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func getMessagesList(channelArn: String, callback: @escaping (Result<[ServerMessage], Error>) -> Void) {
        channelsProvider.request(.getMessagesList(channelArn: channelArn)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let messagesWrapper = try JSONDecoder().decode(MessagesDataWrapper.self, from: response.data)
                    callback(.success(messagesWrapper.data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func sendMessage(message: KitMessage, callback: @escaping VoidCallback) {
        switch message.kind {
        case .photo(let imageItem):
            if let url = imageItem.url, url.absoluteString.contains(Constants.baseURL) {
                sendTextMessage(message: message, callback: callback)
            } else {
                sendAttachmentMessage(message: message, callback: callback)
            }
        case .audio:
            sendAttachmentMessage(message: message, callback: callback)
        case .linkPreview:
            sendAttachmentMessage(message: message, callback: callback)
        default:
            sendTextMessage(message: message, callback: callback)
        }
    }
    
    func sendChatBotMessage(message: ChatBotMessageModel, callback: @escaping (Result<ChatBotMessageModel, Error>) -> Void) {
        channelsProvider.request(.sendChatBotMessage(message: message)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let places = try JSONDecoder().decode(ChatBotMessageModel.self, from: response.data)
                    callback(.success(places))
                } catch {
                    let messageString = String(decoding: response.data, as: UTF8.self)
                    let message = ChatBotMessageModel(message: messageString)
                    callback(.success(message))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func editMessage(message: KitMessage, callback: @escaping VoidCallback) {
        channelsProvider.request(.editMessage(message: message)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func deleteMessage(messageID: String, callback: @escaping (Result<Void, NetworkError>) -> Void) {
        channelsProvider.request(.deleteMessage(id: messageID)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    do {
                        let errorModel = try JSONDecoder().decode(ErrorResponse.self, from: response.data)
                        callback(.failure(.errorResponse(errorModel)))
                    } catch {
                        callback(.failure(.errorMessage(error.localizedDescription)))
                    }
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(.errorMessage(error.localizedDescription)))
            }
        }
    }
    
    func getWebSocketSignedUrl(callback: @escaping (Result<WebSocketResponse, Error>) -> Void) {
        channelsProvider.request(.getWebSocketSignedURL) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let webSocketModel = try JSONDecoder().decode(WebSocketResponse.self, from: response.data)
                    callback(.success(webSocketModel))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    private func sendTextMessage(message: KitMessage, callback: @escaping VoidCallback) {
        channelsProvider.request(.sendTextMessage(message: message)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    private func sendAttachmentMessage(message: KitMessage, callback: @escaping VoidCallback) {
        channelsProvider.request(.sendAttachmentMessage(message: message)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
}

