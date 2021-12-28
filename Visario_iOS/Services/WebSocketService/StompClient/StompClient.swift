//
//  StompClient.swift
//  Visario_iOS
//
//  Created by Vitaliy   on 07.10.2021.
//

import StompClientLib

protocol StompClientDelegate: AnyObject {
    func userActivity(user: ContactModel)
}

final class StompClient {
    
    private let topic = "/users/activity/messages"
    
    static let shared = StompClient()
    
    private let socketClient = StompClientLib()
    
    weak var delegate: StompClientDelegate?
    
    private init() {
        openSocket()
    }
    
    private func openSocket() {
        guard let profile = KeyChainStorage.shared.getProfile() else { return }
        let headers = ["userArn" : "\(profile.userArn)"]
        guard let url = URL(string: Constants.usersActivityBaseURL) else { return }
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url), delegate: self, connectionHeaders: headers)
    }
    
    private func activeUser(from message: String) -> ContactModel? {
        guard let data = message.data(using: .utf8) else { return nil }
        do {
            let activityModel = try JSONDecoder().decode(UserActivityModel.self, from: data)
            return user(by: activityModel)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func user(by activityModel: UserActivityModel) -> ContactModel {
        ContactModel(id: activityModel.data.id,
                     userArn: activityModel.data.userArn,
                     firstName: "",
                     lastName: "",
                     username: "",
                     email: "",
                     phoneNumber: "",
                     image: "",
                     about: "",
                     online: activityModel.data.status == "online" ? true : false,
                     favorite: false,
                     muted: false,
                     inMyContacts: true)
    }
}

// MARK: - StompClientLibDelegate

extension StompClient: StompClientLibDelegate {
    
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        guard let activityMessage = stringBody,
              let user = activeUser(from: activityMessage),
              let delegate = delegate else { return }
        delegate.userActivity(user: user)
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        socketClient.unsubscribe(destination: topic)
    }
        
    func stompClientDidConnect(client: StompClientLib!) {
        socketClient.subscribe(destination: topic)
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        
    }
    
    func serverDidSendPing() {
        
    }
    
}
