//
//  ContactTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.08.2021.
//

import SnapKit
import SDWebImage

class ContactTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    private let iconImageWidth: CGFloat = 50.0
    
    // MARK: - UI Elements
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.layer.cornerRadius = iconImageWidth / 2
        imageView.layer.masksToBounds = true
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
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
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(contentView.layoutMarginsGuide)
            $0.width.height.equalTo(iconImageWidth)
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
        iconImageView.sd_setImage(with: URL(string: contact.image), placeholderImage: UIImage(systemName: "person.crop.circle"))
        
        switch contact.online ?? false {
        case true:
            subtitleLabel.text = "online"
            subtitleLabel.textColor = .systemGreen
        case false:
            subtitleLabel.text = "offline"
            subtitleLabel.textColor = .gray
        }
    }
}
