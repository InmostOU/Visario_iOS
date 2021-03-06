//
//  ProfileView.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 09.08.2021.
//

import UIKit
import SDWebImage

protocol ProfileViewDelegate: AnyObject {
    func chatButtonTapped()
    func voiceButtonTapped()
    func videoButtonTapped()
}

final class ProfileView: UIView {
    
    // MARK: - Properties
    
    var profile: ContactModel
    private let navigationController: UINavigationController
    weak var delegate: ProfileViewDelegate?
    
    // MARK: - UI
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "profile-icon")
        return profileImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Elon Musk"
        nameLabel.font = .boldSystemFont(ofSize: 17)
        nameLabel.textColor = .black
        return nameLabel
    }()
    
    private lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.text = "online"
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .systemBlue
        return statusLabel
    }()
    
    private lazy var chatButton: UIButton = {
        let chatButton = UIButton()
        chatButton.setImage(UIImage(systemName: "message.circle.fill"), for: .normal)
        chatButton.tintColor = .systemBlue
        chatButton.contentHorizontalAlignment = .fill
        chatButton.contentVerticalAlignment = .fill
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        return chatButton
    }()
    
    private lazy var voiceChatButton: UIButton = {
        let voiceChatButton = UIButton()
        voiceChatButton.setImage(UIImage(systemName: "phone.circle.fill"), for: .normal)
        voiceChatButton.tintColor = .systemBlue
        voiceChatButton.contentHorizontalAlignment = .fill
        voiceChatButton.contentVerticalAlignment = .fill
        voiceChatButton.addTarget(self, action: #selector(voiceButtonTapped), for: .touchUpInside)
        return voiceChatButton
    }()
    
    private lazy var videoChatButton: UIButton = {
        let videoChatButton = UIButton()
        videoChatButton.setImage(UIImage(systemName: "video.circle.fill"), for: .normal)
        videoChatButton.tintColor = .systemBlue
        videoChatButton.contentHorizontalAlignment = .fill
        videoChatButton.contentVerticalAlignment = .fill
        videoChatButton.addTarget(self, action: #selector(videoButtonTapped), for: .touchUpInside)
        return videoChatButton
    }()
    
    // MARK: - Init
    
    init(contact: ContactModel, navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.profile = contact
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    @objc
    private func voiceButtonTapped() {
        delegate?.voiceButtonTapped()
    }
    
    @objc
    private func chatButtonTapped() {
        delegate?.chatButtonTapped()
    }
    
    @objc
    private func videoButtonTapped() {
        delegate?.videoButtonTapped()
    }
    
    private func setupView() {
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(statusLabel)
        addSubview(chatButton)
        addSubview(voiceChatButton)
        addSubview(videoChatButton)
        
        configureLayout()
        addBottomBorder()
        setLabels()
    }
    
    func setLabels() {
        nameLabel.text = profile.firstName + " " + profile.lastName
        
        profileImageView.sd_imageTransition = .fade
        profileImageView.sd_setImage(with: URL(string: profile.image), placeholderImage: UIImage(named: "profile-icon"))
        
        switch profile.online ?? false {
        case true:
            statusLabel.text = "online"
        case false:
            statusLabel.text = "offline"
        }
    }
    
    private func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-55)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(13)
        }
        
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.leading.equalTo(nameLabel.snp.leading)
        }
        
        chatButton.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(11)
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.height.equalTo(30)
        }
        
        voiceChatButton.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(11)
            $0.trailing.equalTo(chatButton.snp.leading).offset(-10)
            $0.width.height.equalTo(chatButton.snp.width)
        }
        
        videoChatButton.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(11)
            $0.trailing.equalTo(voiceChatButton.snp.leading).offset(-10)
            $0.width.height.equalTo(chatButton.snp.width)
        }
    }
}
