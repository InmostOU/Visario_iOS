//
//  MeetingChatViewController.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 14.12.2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView

final class MeetingChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    private var meetingViewModel: MeetingViewModel!
    private var sender: Sender!
    
    // MARK: - Lifecycle
    
    init(viewModel: MeetingViewModel) {
        self.meetingViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        setupMessagesCollectionView()
        removeMessageAvatars()
        setSender()
        setupReceivingMessagesObserver()
    }
    
    private func setupNavigationController() {
        navigationItem.title = "Chat"
    }
    
    private func setupMessagesCollectionView() {
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func removeMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        layout.setMessageOutgoingAvatarSize(.zero)
        layout.setMessageIncomingAvatarSize(.zero)
        
        let outgoingLabelEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        let outgoingLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: outgoingLabelEdgeInsets)
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
        
        let incomingLabelEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        let incomingLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: incomingLabelEdgeInsets)
        layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
    }
    
    private func setSender() {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return }
        sender = Sender(senderId: userProfile.userArn, displayName: userProfile.username)
    }
    
    private func reloadTableAndScrollToBottom() {
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(at: .top, animated: true)
        }
    }
    
    private func setupReceivingMessagesObserver() {
        meetingViewModel.messageDidReceivedHandler = { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                self.reloadTableAndScrollToBottom()
            case .failure:
                self.view.showFailedHUD()
            }
        }
    }
    
    private func sendMessage(with text: String) {
        meetingViewModel.sendMessage(message: newMessage(text))
    }
    
    private func newMessage(_ text: String) -> KitMessage {
        let createdTimestamp = Int(Date().timeIntervalSince1970 * 1000)
        let uniqueID = UUID().uuidString
        
        return KitMessage(sender: sender,
                          messageId: uniqueID,
                          sentDate: Date(),
                          content: text,
                          createdTimestamp: createdTimestamp,
                          lastEditedTimestamp: createdTimestamp,
                          metadata: uniqueID,
                          redacted: false,
                          senderArn: sender.senderId,
                          senderName: sender.displayName,
                          type: .standard,
                          channelArn: "",
                          fromCurrentUser: true,
                          delivered: false,
                          image: nil,
                          file: nil,
                          imageURL: nil,
                          fileURL: nil)
    }
}


// MARK: - MessagesDataSource

extension MeetingChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let message = meetingViewModel.messages[indexPath.section]
        return message
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return meetingViewModel.messages.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let stringAttributes = [
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption1),
            NSAttributedString.Key.foregroundColor : UIColor(white: 0.3, alpha: 1)
        ]
        let senderName = meetingViewModel.messages[indexPath.section].sender.displayName
        let attributedString = NSAttributedString(string: senderName, attributes: stringAttributes)
        return attributedString
    }
    
}

// MARK: - MessagesLayoutDelegate

extension MeetingChatViewController: MessagesLayoutDelegate {
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 0 : 20
    }
    
}

// MARK: - MessagesDisplayDelegate

extension MeetingChatViewController: MessagesDisplayDelegate {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector {
        case .url:
            return [.foregroundColor : UIColor.blue]
        default:
            return [:]
        }
    }
    
}

// MARK: - InputBarViewDelegate

extension MeetingChatViewController: InputBarAccessoryViewDelegate {
    
    /// press send button
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = ""
        sendMessage(with: text)
    }
    
}
