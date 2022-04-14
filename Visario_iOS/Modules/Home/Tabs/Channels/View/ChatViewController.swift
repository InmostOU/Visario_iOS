//
//  ChatViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 12.08.2021.
//

import MessageKit
import InputBarAccessoryView
import SDWebImage
import MobileCoreServices
import UniformTypeIdentifiers
import SoundWave

class ChatViewController: MessagesViewController {
    
    // MARK: - Properties
    
    private let channelsViewModel: ChannelsViewModel
    private let channelArn: String
    private let channelName: String
    private let delegate: ChannelsListTableViewController
    private var sender: Sender!
    private var messageForEdit: KitMessage?
    private var audioRecorder: AudioRecorder!
    
    private var stopWatchTimer = Timer()
    private var (minutes, seconds, milliseconds) = (0, 0, 0)
    
    private var channel: ChannelWithMessagesModel? {
        channelsViewModel.channels.first(where: { $0.channelArn == channelArn })
    }
    
    private var audioDuration: Float {
        if minutes == 0 {
            return (seconds == 0) ? (Float(milliseconds) / 100) : (Float(seconds) + (Float(milliseconds) / 100))
        } else {
            return Float(minutes * 60 + seconds) + Float(milliseconds) / 100
        }
    }
    
    enum SendButtonType: String {
        case send = "Send"
        case save = "Save"
        case microphone
    }
    
    enum SendingStatus: String {
        case sended
        case delivered
    }
    
    // MARK: - UI Elements
    
    private lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.sizeToFit()
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.setTitle(channelName, for: .normal)
        button.addTarget(self, action: #selector(navBarTitleButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cameraBarButton: UIBarButtonItem = {
        let cameraButton = UIButton(type: .system)
        cameraButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
        cameraButton.addTarget(self, action: #selector(videoBarButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: cameraButton)
        return barButton
    }()
    
    private lazy var plusBarButton: InputBarButtonItem = {
        let cameraButton = InputBarButtonItem(type: .system)
        cameraButton.image = UIImage(systemName: "plus")
        cameraButton.setSize(CGSize(width: 60, height: 30), animated: false)
        cameraButton.tintColor = .systemBlue
        cameraButton.addTarget(self, action: #selector(plusBarButtonPressed), for: .primaryActionTriggered)
        return cameraButton
    }()
    
    private lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    private lazy var documentPickerController: UIDocumentPickerViewController = {
        let supportedTypes: [UTType] = [.pdf, .text, .doc, .docx, .xls, .xlsx]
        let docPickerController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        docPickerController.allowsMultipleSelection = false
        docPickerController.delegate = self
        return docPickerController
    }()
    
    private lazy var micLongPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        return gesture
    }()
    
    private lazy var microphoneBarButton: InputBarButtonItem = {
        let micButton = InputBarButtonItem(type: .system)
        micButton.image = UIImage(systemName: "mic")
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        micButton.addTarget(self, action: #selector(microphoneBarButtonTapped), for: .primaryActionTriggered)
        micButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(micBarButtonLongPress)))
        return micButton
    }()
    
    private lazy var sendBarButton: InputBarButtonItem = {
        let barButton = InputBarButtonItem(type: .system)
        barButton.title = "Send"
        barButton.setSize(CGSize(width: 30, height: 30), animated: false)
        barButton.addTarget(self, action: #selector(sendBarButtonTapped), for: .primaryActionTriggered)
        return barButton
    }()
    
    private lazy var audioVisualizationView: AudioVisualizationView = {
        let audioView = AudioVisualizationView()
        audioView.backgroundColor = .clear
        audioView.transform = audioView.transform.rotated(by: .pi)
        audioView.meteringLevelBarWidth = 2.0
        audioView.meteringLevelBarInterItem = 1.0
        audioView.meteringLevelBarCornerRadius = 0.0
        return audioView
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.snp.makeConstraints { $0.width.equalTo(60) }
        return label
    }()
    
    private lazy var audioVisualizationStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.backgroundColor = .white
        let width = messageInputBar.inputTextView.frame.width - 20
        let height = messageInputBar.inputTextView.frame.height
        stack.frame = CGRect(x: 0, y: 0, width: width, height: height)
        stack.addArrangedSubviews(timerLabel, audioVisualizationView)
        return stack
    }()
    
    private lazy var tipLabel: UILabel = {
        let tipLabel = UILabel()
        tipLabel.text = "Hold to record"
        tipLabel.textColor = .gray
        tipLabel.textAlignment = .center
        tipLabel.alpha = 0
        return tipLabel
    }()
    
    private lazy var playBarButton: InputBarButtonItem = {
        let barButton = InputBarButtonItem(type: .system)
        barButton.image = UIImage(systemName: "play")
        barButton.setSize(CGSize(width: 30, height: 30), animated: false)
        barButton.addTarget(self, action: #selector(playBarButtonTapped), for: .primaryActionTriggered)
        return barButton
    }()
    
    private lazy var delAudioBarButton: InputBarButtonItem = {
        let barButton = InputBarButtonItem(type: .system)
        barButton.image = UIImage(systemName: "x.circle")
        barButton.setSize(CGSize(width: 30, height: 30), animated: false)
        barButton.addTarget(self, action: #selector(delAudioBarButtonTapped), for: .primaryActionTriggered)
        return barButton
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .black
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: ChannelsViewModel, channelArn: String, channelName: String, delegate: ChannelsListTableViewController) {
        self.channelsViewModel = viewModel
        self.channelArn = channelArn
        self.channelName = channelName
        self.delegate = delegate
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
        setMessageBottomLabelInsets()
        setupMessagesCollectionView()
        configureMessageCollectionView()
        setupInputBarButtons()
        
        setupAudioRecorder()
        setSender()
        setupWebsocketCompletion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        channelsViewModel.removeBadgeCounterFromChannel(by: channelArn)
        ConnectivityManager.shared.addListener(listener: self)
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .top, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioRecorder.stopPlaying()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ConnectivityManager.shared.removeListener(listener: self)
    }
    
    private func setupWebsocketCompletion() {
        delegate.websocketCompletion = {
            DispatchQueue.main.async {
                self.reloadTableAndScrollToBottom()
            }
        }
    }
    
    private func setupNavigationController() {
        navigationItem.rightBarButtonItem = cameraBarButton
        navigationItem.titleView = titleButton
    }
    
    private func setupMessagesCollectionView() {
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
    }
    
    private func setupInputBarButtons() {
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([plusBarButton], forStack: .left, animated: false)
        messageInputBar.setStackViewItems([microphoneBarButton], forStack: .right, animated: false)
    }
    
    private func setupAudioRecorder() {
        audioRecorder = AudioRecorder(messagesCollectionView: messagesCollectionView)
        audioRecorder.delegate = self
    }
    
    private func removeMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
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
    
    private func setMessageBottomLabelInsets() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
        layout.textMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        layout.textMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        layout.photoMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        layout.photoMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        layout.linkPreviewMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        layout.linkPreviewMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        layout.audioMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        layout.audioMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
    }
    
    private func configureMessageCollectionView() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
        layout.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 10, right: 0))
        layout.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 10))
    }
    
    private func reloadTableAndScrollToBottom() {
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(at: .top, animated: true)
        }
    }
    
    private func setSender() {
        guard let userProfile = KeyChainStorage.shared.getProfile() else { return }
        let userName = userProfile.firstName + userProfile.lastName
        sender = Sender(senderId: userProfile.userArn, displayName: userName)
    }
    
    private func showMessageActionsSheet(by index: Int) {
        guard let message = channel?.messages[index] else { return }
        let alertController = UIAlertController(title: "Message actions", message: "", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Save to library", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let image = message.image else { return }
            self.channelsViewModel.writeToPhotoAlbum(image: image)
        }
        let resendAction = UIAlertAction(title: "Resend message", style: .default) { [weak self] action in
            guard let self = self else { return }
            self.resendMessage(by: index)
        }
        let editAction = UIAlertAction(title: "Edit message", style: .default) { [weak self] action in
            guard let self = self else { return }
            switch message.kind {
            case .text(let text):
                self.messageForEdit = message
                self.sendBarButton.title = SendButtonType.save.rawValue
                self.messageInputBar.inputTextView.text = text
                self.messageInputBar.inputTextView.becomeFirstResponder()
            default:
                break
            }
        }
        let deleteAction = UIAlertAction(title: "Delete message", style: .destructive) { [weak self] action in
            guard let self = self else { return }
            self.channelsViewModel.deleteMessage(message: message) { response in
                switch response {
                case .success(_):
                    self.messagesCollectionView.deleteSections(IndexSet(integer: index))
                case .failure(let error):
                    switch error {
                    case .errorResponse(let error):
                        self.showAlert(title: error.error.rawValue, message: error.message)
                    default:
                        self.showError(error: error)
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if let contentCell = messagesCollectionView.cellForItem(at: IndexPath(row: 0, section: index)) as? MessageContentCell {
            if contentCell.messageBottomLabel.text == SendingStatus.sended.rawValue, ConnectivityManager.shared.isNetworkAvailable {
                resendAction.isEnabled = true
            } else {
                resendAction.isEnabled = false
            }
        }
        
        if message.image == nil || message.content.contains(Constants.baseURL) {
            saveAction.isEnabled = false
        }
        
        if message.image != nil || message.content.contains(Constants.baseURL) {
            editAction.isEnabled = false
        }
        
        alertController.addAction(resendAction)
        alertController.addAction(saveAction)
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func showAttachmentsSheet() {
        let alertController = UIAlertController(title: "Attachments", message: "", preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Photo", style: .default) { [weak self] action in
            guard let self = self else { return }
            self.present(self.imagePickerController, animated: true)
        }
        let fileAction = UIAlertAction(title: "File", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.showDocumentPickerController()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(fileAction)
        alertController.addAction(photoAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func showAudioActionSheet() {
        let alertController = UIAlertController(title: "Delete Audio", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
            self?.deleteRecordedAudio()
        }
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func deleteRecordedAudio() {
        audioRecorder.stopPlaying()
        messageInputBar.setStackViewItems([microphoneBarButton], forStack: .right, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 50, animated: false)
        audioVisualizationView.reset()
        audioVisualizationStackView.removeFromSuperview()
        audioRecorder.deleteRecordedAudio()
        resetTimer()
    }
    
    private func resendMessage(by index: Int) {
        guard let message = channel?.messages[index] else { return }
        channelsViewModel.resendMessage(message: message) { [weak self] _ in
            guard let self = self else { return }
            self.reloadTableAndScrollToBottom()
        }
    }
    
    private func newMessage(_ text: String, image: UIImage? = nil, file: Data? = nil) -> KitMessage {
        let sender = Sender(senderId: sender.senderId, displayName: sender.displayName)
        let createdTimestamp = Int(Date().timeIntervalSince1970 * 1000)
        let sentDate = Date(timeIntervalSince1970: TimeInterval(createdTimestamp))
        let uniqueID = UUID().uuidString
        var fileName = ""
        
        if file != nil || image != nil {
            fileName = text.components(separatedBy: "/").last ?? ""
        }
        
        return KitMessage(sender: sender,
                          messageId: uniqueID,
                          sentDate: sentDate,
                          content: text,
                          createdTimestamp: createdTimestamp,
                          lastEditedTimestamp: createdTimestamp,
                          metadata: uniqueID,
                          redacted: false,
                          senderArn: sender.senderId,
                          senderName: sender.displayName,
                          type: .standard,
                          channelArn: channelArn,
                          fromCurrentUser: true,
                          delivered: false,
                          image: image,
                          file: file,
                          imageURL: image != nil ? text : nil,
                          fileURL: file != nil ? text : nil,
                          fileName: fileName,
                          audioDuration: audioDuration)
    }
    
    private func messageType(for cell: MessageCollectionViewCell) -> MessageKind {
        guard let selectedCellIndexPath = messagesCollectionView.indexPath(for: cell) else { return .text("Error: no cell index!") }
        let channelModel = channelsViewModel.channels.first(where: {$0.channelArn == channelArn })!
        let message = channelModel.messages[selectedCellIndexPath.section]
        return message.kind
    }
    
    private func sendMessage(with text: String) {
        channelsViewModel.sendMessage(message: newMessage(text)) { response in
            switch response {
            case .success(_):
                self.reloadTableAndScrollToBottom()
            case .failure(_):
                self.view.showFailedHUD()
            }
        }
    }
    
    private func sendAudio(file: Data, fileURL: URL) {
        let audioMessage = newMessage(fileURL.path, file: file)
        channelsViewModel.sendMessage(message: audioMessage) { response in
            switch response {
            case .success(_):
                self.reloadTableAndScrollToBottom()
            case .failure(_):
                self.view.showFailedHUD()
            }
        }
    }
    
    private func editMessage(with text: String) {
        guard var messageForEdit = messageForEdit else { return }
        messageForEdit.content = text
        channelsViewModel.editMessage(message: messageForEdit) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(_):
                guard let editedMessageIndex = self.channel?.messages.firstIndex(where: { $0.messageId == messageForEdit.messageId }) else { return }
                self.messagesCollectionView.reloadSections(IndexSet(integer: editedMessageIndex))
            case .failure(_):
                self.view.showFailedHUD()
            }
        }
    }
    
    private func showDocumentPickerController() {
        present(documentPickerController, animated: true)
    }
    
    private func setSendButtonType(type: SendButtonType) {
        switch type {
        case .send:
            messageInputBar.setStackViewItems([sendBarButton], forStack: .right, animated: false)
            audioRecorder.deleteRecordedAudio()
        case .save:
            break
        case .microphone:
            messageInputBar.setStackViewItems([microphoneBarButton], forStack: .right, animated: false)
        }
    }
    
    private func startAudioRecording() {
        startStopWatchTimer()
        audioVisualizationView.reset()
        audioVisualizationStackView.removeFromSuperview()
        messageInputBar.inputTextView.addSubview(audioVisualizationStackView)
        audioVisualizationView.audioVisualizationMode = .write
        audioRecorder.startRecording()
    }
    
    private func stopAudioRecording() {
        stopStopWatchTimer()
        audioRecorder.finishRecording()
        messageInputBar.setRightStackViewWidthConstant(to: 110, animated: false)
        messageInputBar.setStackViewItems([sendBarButton, delAudioBarButton, playBarButton], forStack: .right, animated: false)
    }
    
    private func startStopWatchTimer() {
        stopWatchTimer = .scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateStopWatch), userInfo: nil, repeats: true)
    }
    
    private func stopStopWatchTimer() {
        stopWatchTimer.invalidate()
    }
    
    private func resetTimer() {
        (minutes, seconds, milliseconds) = (0, 0, 0)
    }
    
}

// MARK: - Actions -

@objc extension ChatViewController {
    
    private func playBarButtonTapped() {
        switch audioRecorder.currentState {
        case .paused:
            audioRecorder.resumePlaying()
            audioVisualizationView.play(for: audioRecorder.resumeDuration())
            playBarButton.image = UIImage(systemName: "pause")
        case .playing:
            guard (audioVisualizationView.currentGradientPercentage ?? 0) > 0 else { return }
            audioRecorder.pauseSound()
            audioVisualizationView.pause()
            playBarButton.image = UIImage(systemName: "play")
        case .ready, .recorded:
            playBarButton.image = UIImage(systemName: "pause")
            audioRecorder.playRecording()
            audioVisualizationView.audioVisualizationMode = .read
            audioVisualizationView.meteringLevels = audioRecorder.meteringLevels
            audioVisualizationView.play(for: Double(audioDuration))
        default:
            break
        }
    }
    
    private func delAudioBarButtonTapped() {
        showAudioActionSheet()
    }
    
    private func videoBarButtonTapped() {
        channelsViewModel.createMeeting { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let meetingID):
                self.sendMessage(with: Constants.meetingURL + meetingID)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func plusBarButtonPressed() {
        showAttachmentsSheet()
    }
    
    private func navBarTitleButtonTapped() {
        let channelMembersTableViewController = ChannelMembersListTableViewController(model: channelsViewModel, channelArn: channelArn)
        channelMembersTableViewController.title = navigationItem.rightBarButtonItem?.title
        navigationController?.pushViewController(channelMembersTableViewController, animated: true)
    }
    
    private func microphoneBarButtonTapped() {
        // blink
        UIView.animate(withDuration: 0.5) {
            self.tipLabel.alpha = 1
            self.tipLabel.frame = self.messageInputBar.inputTextView.frame
            self.messageInputBar.inputTextView.addSubview(self.tipLabel)
            self.messageInputBar.inputTextView.placeholder = ""
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5) {
                self.tipLabel.alpha = 0
            } completion: { _ in
                self.messageInputBar.inputTextView.placeholder = "Aa"
                self.tipLabel.frame = .zero
                self.tipLabel.removeFromSuperview()
            }
        }
    }
    
    private func micBarButtonLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            startAudioRecording()
        case .ended:
            stopAudioRecording()
        default:
            break
        }
    }
    
    private func sendBarButtonTapped() {
        setupMicrophoneBarButton()
        
        if let audioFile = audioRecorder.getAudioFile(),
           let fileURL = audioRecorder.recordedAudioURL {
            sendAudio(file: audioFile, fileURL: fileURL)
            audioRecorder.clearMeteringLevels()
            audioRecorder.recordedAudioURL = nil
            resetTimer()
        } else {
            let inputText = messageInputBar.inputTextView.text ?? ""
            switch sendBarButton.title {
            case SendButtonType.send.rawValue:
                sendMessage(with: inputText)
            case SendButtonType.save.rawValue:
                editMessage(with: inputText)
                messageInputBar.endEditing(true)
                messageInputBar.sendButton.title = SendButtonType.send.rawValue
                sendBarButton.title = SendButtonType.send.rawValue
            default:
                break
            }
            messageInputBar.inputTextView.text = ""
        }
    }
    
    private func setupMicrophoneBarButton() {
        messageInputBar.setStackViewItems([microphoneBarButton], forStack: .right, animated: true)
        messageInputBar.setRightStackViewWidthConstant(to: 50, animated: true)
        audioVisualizationView.reset()
        audioVisualizationStackView.removeFromSuperview()
    }
    
    private func updateStopWatch() {
        milliseconds += 1
        if milliseconds > 99 {
            seconds += 1
            milliseconds = 0
        }
        if seconds == 60 {
            minutes += 1
            seconds = 0
        }
        if minutes > 9 {
            stopAudioRecording()
            stopStopWatchTimer()
        }
        timerLabel.text = String(format: "%01i:%02i.%02i", minutes, seconds, milliseconds)
    }
    
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard let message = channel?.messages[indexPath.section] else { return KitMessage.placeholder }
        return message
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        guard let channelMessages = channel?.messages else { return 0 }
        return channelMessages.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let stringAttributes = [
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption1),
            NSAttributedString.Key.foregroundColor : UIColor(white: 0.3, alpha: 1)
        ]
        let senderName = channel?.messages[indexPath.section].sender.displayName
        let attributedString = NSAttributedString(string: senderName ?? "", attributes: stringAttributes)
        return attributedString
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard let message = channel?.messages[indexPath.section] else { return nil }
        let sendingStatus = message.delivered ? SendingStatus.delivered.rawValue : SendingStatus.sended.rawValue
        
        let stringAttributes = [
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption1),
            NSAttributedString.Key.foregroundColor : UIColor(white: 0.3, alpha: 1)
        ]
        let attributedString = NSAttributedString(string: sendingStatus, attributes: stringAttributes)
        return attributedString
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 0 : 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 20 : 0
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let dotsImage = UIImage(named: "three-dots")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: dotsImage)
        imageView.frame = accessoryView.bounds
        accessoryView.addSubview(imageView)
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.layer.masksToBounds = true
        accessoryView.layer.backgroundColor = UIColor.clear.cgColor
        accessoryView.backgroundColor = .systemGray6
        
        if !isFromCurrentSender(message: message) {
            guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
            layout.setMessageIncomingAccessoryViewSize(CGSize(width: 0, height: 0))
        }
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
        guard var message = channel?.messages[indexPath.section] else { return }
        
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
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        // this is needed especially when the cell is reconfigure while is playing sound
        audioRecorder.configureAudioCell(cell, message: message)
        loadAudio(for: message, of: cell)
    }
    
    private func loadAudio(for message: MessageType, of cell: AudioMessageCell) {
        guard let kitMessage = message as? KitMessage else { return }
        
        guard let fileURL = URL(string: kitMessage.fileURL ?? ""), fileURL.scheme == "https" else {
            cell.playButton.isEnabled = isFromCurrentSender(message: kitMessage) ? kitMessage.delivered : true
            return }
        
        guard let fileName = kitMessage.fileName, !audioRecorder.isFileExist(with: fileName) else { return }
        cell.playButton.isEnabled = false
        
        audioRecorder.loadAudio(by: kitMessage) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let message):
                self.channelsViewModel.addFileToMessage(message: message) {
                    cell.playButton.isEnabled = message.delivered
                    self.messagesCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didSelectURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        switch messageType(for: cell) {
        case .photo(let photoItem):
            showMeeting(by: photoItem.url)
        default:
            break
        }
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        showMessageActionsSheet(by: indexPath.section)
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard cell.playButton.isEnabled,
              let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        else { return }
        
        if audioRecorder.playingMessage?.messageId == message.messageId {
            if audioRecorder.currentState == .playing {
                audioRecorder.pausePlaying(for: message, in: cell)
            } else {
                audioRecorder.resumePlaying()
            }
        } else {
            audioRecorder.stopAnyOngoingPlaying()
            audioRecorder.playAudio(for: message, in: cell)
        }
    }
    
    private func showMeeting(by url: URL?) {
        guard let url = url else { return }
        guard let meetingID = getQueryStringParameter(from: url, param: "meetingId") else { return }
        let vm = MeetingViewModel(meetingId: meetingID)
        let vc = MeetingViewController(viewModel: vm)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    private func getQueryStringParameter(from url: URL, param: String) -> String? {
        guard let url = URLComponents(string: url.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
}

// MARK: - InputBarViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        setSendButtonType(type: text.isEmpty ? .microphone : .send)
    }
    
}

// MARK: - NetworkConnectionStatusListener

extension ChatViewController: NetworkConnectionStatusListener {
    
    func networkStatusDidChange(status: NetworkConnectionStatus) {
        switch status {
        case .online:
            break
        case .offline:
            break
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }
        guard let url = info[.imageURL] as? URL else { return }
        let newMessage = newMessage(url.absoluteString, image: image)
        
        channelsViewModel.sendMessage(message: newMessage) { [weak self] _ in
            guard let self = self else { return }
            self.reloadTableAndScrollToBottom()
        }
    }
    
}

// MARK: - UIDocumentPickerDelegate

extension ChatViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        do {
            let fileData = try Data(contentsOf: url)
            let newMessage = newMessage(url.absoluteString, file: fileData)
            channelsViewModel.sendMessage(message: newMessage) { [weak self] response in
                self?.reloadTableAndScrollToBottom()
            }
        } catch {
            print(error)
        }
        
        controller.dismiss(animated: true)
    }
}

// MARK: - AudioRecorderDelegate

extension ChatViewController: AudioRecorderDelegate {
    
    func audioRecorder(didUpdateDecibel decibel: Float) {
        audioVisualizationView.add(meteringLevel: decibel)
    }
    
}

// MARK: - AudioPlayerDelegate

extension ChatViewController: AudioPlayerDelegate {
    
    func audioPlayer(didFinishPlaying finish: Bool) {
        playBarButton.image = UIImage(systemName: "play")
    }
    
}
