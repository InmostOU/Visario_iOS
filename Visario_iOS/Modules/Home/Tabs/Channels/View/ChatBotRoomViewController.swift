//
//  ChatBotRoomViewController.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 20.10.2021.
//

import MessageKit
import InputBarAccessoryView
import CoreLocation

final class ChatBotRoomViewController: MessagesViewController {
    
    // MARK: - Properties
    
    private let channelsViewModel: ChannelsViewModel
    private let locationService: LocationService
    private var sender: Sender!
    
    // MARK: - Lifecycle
    
    init(viewModel: ChannelsViewModel) {
        self.channelsViewModel = viewModel
        self.locationService = LocationService()
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
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .top, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationService.stoppingGettingLocation()
    }
    
    private func setupNavigationController() {
        navigationItem.title = "Chat-Bot"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map.fill"), style: .plain, target: self, action: #selector(mapBarButtonTapped))
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
        layout.setMessageOutgoingAvatarSize(.zero)
        
        let outgoingLabelEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        let outgoingLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: outgoingLabelEdgeInsets)
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }
    
    private func setSender() {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return }
        sender = Sender(senderId: userProfile.userArn, displayName: userProfile.username)
    }
    
    private func setupLocationManager() {
        locationService.requestLocationAuthorization()
        
        locationService.didChangeStatus = { [weak self] isChanged in
            switch isChanged {
            case true:
                self?.locationService.startingToGetLocation()
            case false:
                print("Location access status: FALSE")
            }
        }
    }
    
    private func reloadTableAndScrollToBottom() {
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(at: .top, animated: true)
        }
    }
    
    private func sendMessage(with text: String) {
        channelsViewModel.sendMessageToBot(message: newMessage(text)) { response in
            switch response {
            case .success:
                self.reloadTableAndScrollToBottom()
            case .failure:
                self.view.showFailedHUD()
            }
        }
    }
    
    private func newMessage(_ text: String) -> KitMessage {
        let createdTimestamp = Int(Date().timeIntervalSince1970 * 1000)
        let uniqueID = UUID().uuidString
        let lat = Double(locationService.currentLocation?.coordinate.latitude ?? 0)
        let lng = Double(locationService.currentLocation?.coordinate.longitude ?? 0)
        
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
                          fileURL: nil,
                          lat: String(lat),
                          lng: String(lng))
    }
    
    // MARK: - Actions
    
    @objc private func mapBarButtonTapped() {
        showMaps()
    }
    
    private func showMaps() {
        let mapScreen = MapScreen()
        mapScreen.delegate = self
        mapScreen.modalPresentationStyle = .fullScreen
        present(mapScreen, animated: true)
    }
}


// MARK: - MessagesDataSource

extension ChatBotRoomViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let message = channelsViewModel.chatBotMessages[indexPath.section]
        return message
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return channelsViewModel.chatBotMessages.count
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ChatBotRoomViewController: MessagesLayoutDelegate {
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 0 : 20
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ChatBotRoomViewController: MessagesDisplayDelegate {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let avatarImage = UIImage(named: "bot") else { return }
        let avatar = Avatar(image: avatarImage, initials: "robi")
        avatarView.backgroundColor = .white
        avatarView.set(avatar: avatar)
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

extension ChatBotRoomViewController: InputBarAccessoryViewDelegate {
    
    /// press send button
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = ""
        sendMessage(with: text)
    }
    
}

// MARK: - MapsDelegate

extension ChatBotRoomViewController: MapsDelegate {
    
    func selectLocation(coordinate: CLLocationCoordinate2D) {
        print("--- coordinate --->", coordinate)
    }
    
}
