//
//  ProfileInfoView.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 12.08.2021.
//

import UIKit
import SnapKit
import SDWebImage

final class ProfileInfoView: UIView {
    
    // MARK: - Properties
    
    private let profileImageWidth: CGFloat = 100
    private var profile: ProfileModel?
    
    // MARK: - UI
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "elon-musk")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageWidth / 2
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
        return profileImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Elon Musk"
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textColor = .black
        return nameLabel
    }()
    
    private lazy var phoneLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.text = "+380 85 476 8391"
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .systemGray
        return statusLabel
    }()
    
    private lazy var usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.text = "@elonmusk322"
        usernameLabel.font = .systemFont(ofSize: 14)
        usernameLabel.textColor = .systemGray
        return usernameLabel
    }()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func setModel(profile: ProfileModel) {
        self.profile = profile
        setLabels()
    }
    
    // MARK: - Private
    
    private func setupView() {
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(phoneLabel)
        addSubview(usernameLabel)
        
        configureLayout()
        addBottomBorder()
        
    }
    
    private func setLabels() {
        guard let profile = profile else { return }
        nameLabel.text = profile.firstName + " " + profile.lastName
        phoneLabel.text = profile.phoneNumber
        usernameLabel.text = profile.username
        
        profileImageView.sd_imageTransition = .fade
        profileImageView.sd_setImage(with: URL(string: profile.image), placeholderImage: UIImage(named: "elon-musk"))
    }
    
    private func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(profileImageWidth)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(snp.top).offset(50)
        }
        
        nameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(10)
        }
        
        phoneLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(phoneLabel.snp.bottom).offset(5)
        }
    }
}
