//
//  SearchedChannelChatViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 13.09.2021.
//

import MessageKit

final class SearchedChannelChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    private let channelsViewModel: ChannelsViewModel
    private let channelArn: String
    private let delegate: ChannelsListTableViewController
    
    // MARK: - Lifecycle
    
    init(viewModel: ChannelsViewModel, channelArn: String, delegate: ChannelsListTableViewController) {
        self.channelsViewModel = viewModel
        self.channelArn = channelArn
        self.delegate = delegate
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
        setupMessagesInputBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .top, animated: false)
        }
    }
    
    private func setupNavigationController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .plain, target: self, action: #selector(joinToChannelBarButtonTapped))
        if channelsViewModel.channels.contains(where: { $0.channelArn == channelArn } ) {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func removeMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        
        let incomingLabelAlignment = LabelAlignment(
            textAlignment: .left,
            textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        )
        layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
        
        let outgoingLabelAlignment = LabelAlignment(
            textAlignment: .right,
            textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        )
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }
    
    private func setupMessagesInputBar() {
        messageInputBar.inputTextView.isEditable = false
    }
    
    private func setupMessagesCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func showAddToChannelAlertSheet(by channelArn: String) {
        let alert = UIAlertController(title: "Add To Channel", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Join to channel", style: .destructive) { [unowned self] action in
            self.addMemberToChannel(by: channelArn)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func addMemberToChannel(by channelArn: String) {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return }
        view.showRotationHUD()
        
        channelsViewModel.addMemberToChannel(channelArn: channelArn, memberArn: userProfile.userArn) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(_):
                self.view.showSuccessHUD()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.delegate.fetchAllChannels()
                    self.navigationController?.popToRootViewController(animated: true)
                    self.delegate.searchController.isActive = false
                }
            case .failure(let error):
                self.view.hideHUD()
                self.showAlertWithError(error: error)
            }
        }
    }
    
    private func showAlertWithError(error: NetworkError) {
        switch error {
        case .errorResponse(let response):
            showAlert(title: response.error.rawValue.uppercased(), message: response.message)
        case .errorMessage(let message):
            showAlert(title: "NetworkError", message: message)
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @objc private func joinToChannelBarButtonTapped() {
        showAddToChannelAlertSheet(by: channelArn)
    }
}

// MARK: - MessagesDataSource

extension SearchedChannelChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        let userProfile = KeyChainStorage.shared.getProfile()!
        return Sender(senderId: userProfile.userArn, displayName: userProfile.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let channelModel = channelsViewModel.findedChannels.first(where: {$0.channelArn == channelArn })!
        let message = channelModel.messages[indexPath.section]
        return message
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        guard let channelModel = channelsViewModel.findedChannels.first(where: {$0.channelArn == channelArn }) else { return 0 }
        return channelModel.messages.count
    }
    
}

// MARK: - MessagesLayoutDelegate

extension SearchedChannelChatViewController: MessagesLayoutDelegate {
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 0 : 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 20 : 0
    }
    
}

// MARK: - MessagesDisplayDelegate

extension SearchedChannelChatViewController: MessagesDisplayDelegate {
    
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let channel = channelsViewModel.findedChannels.first(where: {$0.channelArn == channelArn }) else { return }
        var message = channel.messages[indexPath.section]
        
        switch message.kind {
        case .photo(let photoItem):
            if let url = photoItem.url, url.absoluteString.contains(Constants.meetingPath) {
                imageView.image = UIImage(named: "visario-meeting-icon")
            } else {
                guard message.image == nil else { return }
                imageView.sd_setImage(with: photoItem.url, placeholderImage: UIImage(named: "placeholder")) { image, _, _, _ in
                    message.image = image
                    self.channelsViewModel.updateImage(from: message)
                }
            }
        default:
            imageView.sd_cancelCurrentImageLoad()
        }
    }
    
}
