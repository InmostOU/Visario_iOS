//
//  ContactTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.08.2021.
//

import SnapKit

enum OnlineState: String {
    case online
    case offline
}

class ContactTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .black
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupSubviews()
        addConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        contentView.addSubviews(iconImageView, titleLabel, subtitleLabel)
    }
    
    private func addConstraints() {
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.bottom.equalTo(-15)
            $0.leading.equalTo(contentView.layoutMarginsGuide)
            $0.width.equalTo(iconImageView.snp.height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.bottom.equalTo(-15)
        }
    }
    
    func fill(with contact: ContactModel) {
        titleLabel.text = contact.username
        
        switch contact.muted {
        case true:
            subtitleLabel.text = OnlineState.offline.rawValue
        case false:
            subtitleLabel.text = OnlineState.online.rawValue
        }
    }
}
