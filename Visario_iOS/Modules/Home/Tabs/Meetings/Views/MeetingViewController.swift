//
//  MeetingViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 17.08.2021.
//

import UIKit
import ReplayKit

protocol MeetingView {
    func reloadCollectionAnimated()
    func getCell(by attendeeId: String) -> ParticipantCollectionViewCell?
}

final class MeetingViewController: UIViewController, MeetingView {
    
    // MARK: - Properties
    
    private let declineButtonWidth: CGFloat = 40.0
    private let meetingViewModel: MeetingViewModel
    private let channelsViewModel = ChannelsViewModel()
    
    // MARK: - UI Elements
    
    private lazy var participantsCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: MeetingsLayout())
        collection.register(ParticipantCollectionViewCell.self, forCellWithReuseIdentifier: ParticipantCollectionViewCell.identifier)
        collection.isScrollEnabled = false
        collection.dataSource = self
        collection.backgroundColor = .darkGray
        return collection
    }()
    
    private lazy var controllButtonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }()
    
    private lazy var declineButton: UIButton = {
        let declineButton = UIButton()
        declineButton.backgroundColor = .systemRed
        declineButton.tintColor = .white
        declineButton.setImage(UIImage(systemName: "phone.down"), for: .normal)
        declineButton.layer.cornerRadius = declineButtonWidth / 2
        declineButton.layer.masksToBounds = false
        declineButton.clipsToBounds = true
        declineButton.addTarget(self, action: #selector(declineButtonTapped), for: .touchUpInside)
        return declineButton
    }()
    
    private lazy var muteButton: UIButton = {
        let muteButton = UIButton()
        muteButton.backgroundColor = .lightGray
        muteButton.tintColor = .white
        muteButton.setImage(UIImage(systemName: "mic"), for: .normal)
        muteButton.setImage(UIImage(systemName: "mic.slash"), for: .selected)
        muteButton.layer.cornerRadius = declineButtonWidth / 2
        muteButton.layer.masksToBounds = false
        muteButton.clipsToBounds = true
        muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
        return muteButton
    }()
    
    private lazy var enableVideoButton: UIButton = {
        let enableVideoButton = UIButton()
        enableVideoButton.backgroundColor = .systemRed
        enableVideoButton.tintColor = .white
        enableVideoButton.setImage(UIImage(systemName: "video.slash"), for: .normal)
        enableVideoButton.layer.cornerRadius = declineButtonWidth / 2
        enableVideoButton.layer.masksToBounds = false
        enableVideoButton.clipsToBounds = true
        enableVideoButton.addTarget(self, action: #selector(enableVideoButtonTapped), for: .touchUpInside)
        return enableVideoButton
    }()
    
    // not used yet
    private lazy var shareScreenButton: UIButton = {
        let shareScreenButton = UIButton()
        shareScreenButton.backgroundColor = .lightGray
        shareScreenButton.tintColor = .white
        shareScreenButton.setImage(UIImage(systemName: "rectangle.on.rectangle"), for: .normal)
        shareScreenButton.layer.cornerRadius = declineButtonWidth / 2
        shareScreenButton.layer.masksToBounds = false
        shareScreenButton.clipsToBounds = true
        return shareScreenButton
    }()
    
    private lazy var handUpButton: UIButton = {
        let handUpButton = UIButton()
        handUpButton.backgroundColor = .lightGray
        handUpButton.tintColor = .white
        handUpButton.setImage(UIImage(systemName: "hand.raised"), for: .normal)
        handUpButton.layer.cornerRadius = declineButtonWidth / 2
        handUpButton.layer.masksToBounds = false
        handUpButton.clipsToBounds = true
        return handUpButton
    }()
    
    private lazy var pickerView: RPSystemBroadcastPickerView = {
        let pickerView = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        pickerView.preferredExtension = "com.Visario-iOS.Visario-UploadBroadcastExtension"
        pickerView.showsMicrophoneButton = false
        pickerView.backgroundColor = .systemGray
        pickerView.layer.cornerRadius = declineButtonWidth / 2
        pickerView.layer.masksToBounds = false
        pickerView.clipsToBounds = true
        return pickerView
    }()
    
    private lazy var chatButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.tintColor = .white
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.layer.cornerRadius = declineButtonWidth / 2
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    init(viewModel: MeetingViewModel) {
        self.meetingViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        viewModel.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupViews()
        configureLayout()
        participantsCollectionView.reloadData()
    }
    
    @objc
    private func muteButtonTapped() {
        meetingViewModel.muteAudio()
        
        if meetingViewModel.isMuted {
            muteButton.setImage(UIImage(systemName: "mic.slash"), for: .normal)
            muteButton.backgroundColor = .systemRed
        } else {
            muteButton.setImage(UIImage(systemName: "mic"), for: .normal)
            muteButton.backgroundColor = .lightGray
        }
    }
    
    @objc
    private func enableVideoButtonTapped() {
        if !meetingViewModel.videoEnabled {
            meetingViewModel.enableVideo()
            enableVideoButton.setImage(UIImage(systemName: "video"), for: .normal)
            enableVideoButton.backgroundColor = .lightGray
        } else {
            meetingViewModel.disableVideo()
            enableVideoButton.setImage(UIImage(systemName: "video.slash"), for: .normal)
            enableVideoButton.backgroundColor = .systemRed
        }
    }
    
    @objc
    private func declineButtonTapped() {
        meetingViewModel.exitMeeting()
        dismiss(animated: true)
    }
    
    @objc
    private func chatButtonTapped() {
        let meetingChatViewController = MeetingChatViewController(viewModel: meetingViewModel)
        let meetingChatNavController = UINavigationController(rootViewController: meetingChatViewController)
        present(meetingChatNavController, animated: true)
    }
    
    func reloadCollectionAnimated() {
        participantsCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func getCell(by attendeeId: String) -> ParticipantCollectionViewCell? {
        for i in meetingViewModel.participants.indices {
            if meetingViewModel.participants[i].attendeeId == attendeeId {
                return participantsCollectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? ParticipantCollectionViewCell
            }
        }
        return nil
    }
    
    private func setupViews() {
        view.addSubview(participantsCollectionView)
        view.addSubview(controllButtonsStackView)
        
        controllButtonsStackView.addArrangedSubview(pickerView)
        controllButtonsStackView.addArrangedSubview(chatButton)
        controllButtonsStackView.addArrangedSubview(enableVideoButton)
        controllButtonsStackView.addArrangedSubview(muteButton)
        controllButtonsStackView.addArrangedSubview(handUpButton)
        controllButtonsStackView.addArrangedSubview(declineButton)
    }
    
    private func configureLayout() {
        participantsCollectionView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        controllButtonsStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-30)
        }
        muteButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
        }
        handUpButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
        }
        declineButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
        }
        enableVideoButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
        }
        shareScreenButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
        }
        pickerView.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
        }
        chatButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MeetingViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(meetingViewModel.participants.count)
        return meetingViewModel.participants.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantCollectionViewCell.identifier, for: indexPath) as? ParticipantCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 6
        cell.configure(with: meetingViewModel.participants[indexPath.row])
        return cell
    }
    
}
