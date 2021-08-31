//
//  ChannelsAPIService.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 12.08.2021.
//

import Moya

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
    
    func addMemberToChannel(channelArn: String, memberArn: String, callback: @escaping VoidCallback) {
        channelsProvider.request(.addMemberToChannel(channelArn: channelArn, memberArn: memberArn)) { response in
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
    
    func sendMessage(message: ServerMessage, callback: @escaping VoidCallback) {
        channelsProvider.request(.sendMessage(message: message)) { response in
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
}
