//
//  ChatViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 12.08.2021.
//

import MessageKit
import InputBarAccessoryView

final class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    private let channelsViewModel: ChannelsViewModel
    private let channel: ChannelModel
    private var sender: Sender!
    
    // MARK: - Lifecycle
    
    init(viewModel: ChannelsViewModel, channel: ChannelModel) {
        self.channelsViewModel = viewModel
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelsViewModel.view = self
        
        setupNavigationController()
        removeMessageAvatars()
        setupMessagesCollection()
        getMessages()
        setSender()
        setupWebSocket()
    }
    
    private func setupWebSocket() {
        channelsViewModel.getWebSocketSignedURL { response in
            switch response {
            case .success(let webSocketModel):
                WebSocketManager.shared.connectToWebSocket(with: webSocketModel.message)
                self.receiveMessagesData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func receiveMessagesData() {
        WebSocketManager.shared.receiveData { amazonMessageModel in
            switch amazonMessageModel {
            case .success(_):
                self.getMessages()
            case .failure(let error):
                print(error)
            }
            self.receiveMessagesData()
        }
    }
    
    private func setupNavigationController() {
        navigationItem.title = channel.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Members", style: .plain, target: self, action: #selector(membersBarButtonTapped))
    }
    
    private func setupMessagesCollection() {
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func removeMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            return
        }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        
        let incomingLabelAlignment = LabelAlignment(
            textAlignment: .left,
            textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
        
        let outgoingLabelAlignment = LabelAlignment(
            textAlignment: .right,
            textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }
    
    private func getMessages() {
        channelsViewModel.getMessages(channelArn: channel.channelArn) { response in
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
            }
            switch response {
            case .success(_):
                break
            case .failure(let error):
                print(error)
                self.showError(error: error)
            }
        }
    }
    
    private func setSender() {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return }
        sender = Sender(senderId: userProfile.userArn, displayName: userProfile.username)
    }
    
    // MARK: - Actions
    
    @objc private func membersBarButtonTapped() {
        let channelMembersTableViewController = ChannelMembersListTableViewController(model: channelsViewModel, channel: channel)
        channelMembersTableViewController.title = navigationItem.rightBarButtonItem?.title
        navigationController?.pushViewController(channelMembersTableViewController, animated: true)
    }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return channelsViewModel.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return channelsViewModel.messages.count
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    /// send message
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newMessage = KitMessage(sender: sender,
                                    messageId: UUID().uuidString,
                                    sentDate: Date(),
                                    kind: .text(text),
                                    channelArn: channel.channelArn,
                                    metadata: sender.displayName)
        
        channelsViewModel.sendMessage(message: newMessage) { response in
            switch response {
            case .success(_):
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
                }
            case .failure(_):
                self.view.showFailedHUD()
            }
        }
        inputBar.inputTextView.text = ""
    }
}

// MARK: BaseView

extension ChatViewController: BaseView {
    
}
