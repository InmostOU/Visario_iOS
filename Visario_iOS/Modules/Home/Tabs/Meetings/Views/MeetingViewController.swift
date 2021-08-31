//
//  MeetingViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 17.08.2021.
//

import UIKit

final class MeetingViewController: UIViewController {
    
    private let declineButtonWidth: CGFloat = 40.0
    private var participants = [ContactModel]()
    
    private lazy var participantsCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: MeetingsLayout())
        collection.register(ParticipantCollectionViewCell.self, forCellWithReuseIdentifier: ParticipantCollectionViewCell.identifier)
        collection.isScrollEnabled = false
        collection.dataSource = self
        return collection
    }()
    
    private lazy var declineButton: UIButton = {
        let declineButton = UIButton()
        declineButton.backgroundColor = .systemRed
        declineButton.tintColor = .white
        declineButton.setImage(UIImage(systemName: "phone.down"), for: .normal)
        declineButton.layer.cornerRadius = declineButtonWidth / 2.0
        declineButton.layer.masksToBounds = false
        declineButton.clipsToBounds = true
        return declineButton
    }()
    
    private lazy var muteButton: UIButton = {
        let muteButton = UIButton()
        muteButton.backgroundColor = .systemRed
        muteButton.tintColor = .white
        muteButton.setImage(UIImage(systemName: "mic.slash"), for: .normal)
        muteButton.layer.cornerRadius = declineButtonWidth / 2.0
        muteButton.layer.masksToBounds = false
        muteButton.clipsToBounds = true
        return muteButton
    }()
    
    private lazy var enableVideoButton: UIButton = {
        let enableVideoButton = UIButton()
        enableVideoButton.backgroundColor = .systemRed
        enableVideoButton.tintColor = .white
        enableVideoButton.setImage(UIImage(systemName: "video"), for: .normal)
        enableVideoButton.layer.cornerRadius = declineButtonWidth / 2.0
        enableVideoButton.layer.masksToBounds = false
        enableVideoButton.clipsToBounds = true
        return enableVideoButton
    }()
    
    private lazy var shareScreenButton: UIButton = {
        let shareScreenButton = UIButton()
        shareScreenButton.backgroundColor = .systemRed
        shareScreenButton.tintColor = .white
        shareScreenButton.setImage(UIImage(systemName: "rectangle.on.rectangle"), for: .normal)
        shareScreenButton.layer.cornerRadius = declineButtonWidth / 2.0
        shareScreenButton.layer.masksToBounds = false
        shareScreenButton.clipsToBounds = true
        return shareScreenButton
    }()
    
    private lazy var handUpButton: UIButton = {
        let handUpButton = UIButton()
        handUpButton.backgroundColor = .systemRed
        handUpButton.tintColor = .white
        handUpButton.setImage(UIImage(systemName: "hand.raised"), for: .normal)
        handUpButton.layer.cornerRadius = declineButtonWidth / 2.0
        handUpButton.layer.masksToBounds = false
        handUpButton.clipsToBounds = true
        return handUpButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(uiTapped))
        view.addGestureRecognizer(tap)
        
        let ltap = UILongPressGestureRecognizer(target: self, action: #selector(uiLongTapped))
        view.addGestureRecognizer(ltap)
        
        setupViews()
        configureLayout()
    }
    
    @objc
    private func uiTapped() {
        let p1 = ContactModel(id: 123, userArn: "asd", firstName: "Konstatin", lastName: "Deulin", username: "knstd", email: "knstd@gmail.com", phoneNumber: "+380895754752", image: "", about: "software dev", online: true, favorite: true, muted: false, inMyContacts: false)
        participants.append(p1)
        
//        for i in 0 ..< participantsCollectionView.numberOfItems(inSection: 0) {
//            participantsCollectionView.reloadItems(at: [IndexPath(item: i, section: 0)])
//        }
        participantsCollectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
       
    }
    
    @objc
    func uiLongTapped() {
        participants.removeLast()
        participantsCollectionView.deleteItems(at: [IndexPath(item: 1, section: 0)])
    }
    
    private func setupViews() {
        
        participants.append(contentsOf: ContactModel.mock(count: 3))
        
        view.addSubview(participantsCollectionView)
        view.addSubview(declineButton)
        view.addSubview(muteButton)
        view.addSubview(enableVideoButton)
        view.addSubview(shareScreenButton)
        view.addSubview(handUpButton)
        
        participantsCollectionView.reloadData()
    }
    
    private func configureLayout() {
        participantsCollectionView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        muteButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
            $0.bottom.equalToSuperview().offset(-30)
            $0.centerX.equalToSuperview()
        }
        
        handUpButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
            $0.bottom.equalTo(muteButton.snp.bottom)
            $0.leading.equalTo(muteButton).offset(50)
        }
        
        declineButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
            $0.bottom.equalTo(muteButton.snp.bottom)
            $0.leading.equalTo(handUpButton).offset(50)
        }
        
        enableVideoButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
            $0.bottom.equalTo(muteButton.snp.bottom)
            $0.leading.equalTo(muteButton).offset(-50)
        }
        
        shareScreenButton.snp.makeConstraints {
            $0.width.height.equalTo(declineButtonWidth)
            $0.bottom.equalTo(muteButton.snp.bottom)
            $0.leading.equalTo(enableVideoButton).offset(-50)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MeetingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(participants.count)
        return participants.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ParticipantCollectionViewCell.identifier, for: indexPath) as? ParticipantCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.layer.cornerRadius = 6
        cell.configure(with: participants[indexPath.row])
        return cell
    }
}

// MARK: - BaseView

extension MeetingViewController: BaseView {
    
}
