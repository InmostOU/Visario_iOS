//
//  ChannelSelectionViewModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 23.09.2021.
//

import UIKit

final class ChannelSelectionViewModel {
    private let meetingService = MeetingAPIService()
    private let messagesConverter = MessagesConverter()
    private var meetingURLData: CreateMeetingResponseModel?
    
    weak var view: UIViewController?
    
    func createMeetingAndGetInviteMessage(channelArn: String, completionHandler: @escaping (KitMessage, String) -> ()) {
        createMeetingRequest { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let meetingId):
                guard let message = self.configureInviteMessage(meetingId: meetingId, channelArn: channelArn) else { return }
                completionHandler(message, meetingId)
                
            case .failure(let error):
                self.view?.showError(error: error)
            }
        }
    }
    
    private func configureInviteMessage(meetingId: String, channelArn: String) -> KitMessage? {
        guard let myProfile = KeyChainStorage.shared.getProfile() else { return nil }
        
        let date = Date()
        let timeInterval = date.timeIntervalSince1970
        let intDate = Int(timeInterval)
        let id = UUID().uuidString
        
        let message = ServerMessage(content: Constants.meetingURL + meetingId, createdTimestamp: intDate, lastEditedTimestamp: intDate, messageId: id, metadata: id, redacted: false, senderArn: myProfile.userArn, senderName: myProfile.username, type: .standard, channelArn: channelArn, fromCurrentUser: true, delivered: false)
        
        let kitMessage = messagesConverter.kitMessage(from: message)
        return kitMessage
    }
    
    private func createMeetingRequest(completionHandler: @escaping (Result<String, Error>) -> Void) {
        meetingService.createMeeting { result in
            switch result {
            case .success(let response):
                self.meetingURLData = response
                completionHandler(.success(response.meetingObject.meetingId))
            case .failure(let error):
                self.view?.showError(error: error)
                completionHandler(.failure(error))
            }
        }
    }
}
