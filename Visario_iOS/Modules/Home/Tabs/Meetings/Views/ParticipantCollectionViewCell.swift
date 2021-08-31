//
//  ParticipantCollectionViewCell.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 17.08.2021.
//

import UIKit

final class ParticipantCollectionViewCell: UICollectionViewCell {
    
    private let profileImageWidth: CGFloat = 100
    
    // MARK: - UI
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageWidth / 2
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "elon-musk")
        return profileImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Elon Musk"
        nameLabel.font = .boldSystemFont(ofSize: 17)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        return nameLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //profileImageView.image = nil
        nameLabel.text = nil
    }
    
    func configure(with model: ContactModel) {
        nameLabel.text = "\(model.firstName) \(model.lastName)"
    }
    
    private func configureView() {
        backgroundColor = .darkGray
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
    }
    
    private func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(profileImageWidth)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(13)
        }
    }
}
