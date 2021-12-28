//
//  ChannelTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 11.08.2021.
//

import SnapKit

final class ChannelTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let newMessagesBadgeLabelWidth: CGFloat = 20.0
    
    // MARK: - UI Elements
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bubble.left.and.bubble.right")
        imageView.tintColor = .baseBlue
        return imageView
    }()
    
    private lazy var channelNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    private lazy var newMessagesBadgeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemRed
        label.layer.cornerRadius = newMessagesBadgeLabelWidth / 2
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.isHidden = true
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
        contentView.addSubviews(iconImageView, channelNameLabel, subtitleLabel, dateLabel, newMessagesBadgeLabel)
    }
    
    private func addConstraints() {
        iconImageView.snp.makeConstraints {
            $0.leading.equalTo(contentView.layoutMarginsGuide)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(iconImageView.snp.height).multipliedBy(1.4)
        }
        dateLabel.snp.makeConstraints {
            $0.trailing.equalTo(contentView.layoutMarginsGuide)
            $0.width.equalTo(80)
            $0.firstBaseline.equalTo(channelNameLabel)
        }
        channelNameLabel.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
            $0.trailing.equalTo(dateLabel.snp.leading).offset(-10)
        }
        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(channelNameLabel)
            $0.top.equalTo(channelNameLabel.snp.bottom).offset(5)
            $0.bottom.equalTo(-15)
        }
        newMessagesBadgeLabel.snp.makeConstraints {
            $0.width.height.equalTo(newMessagesBadgeLabelWidth)
            $0.top.equalTo(dateLabel.snp.bottom).offset(5)
            $0.centerX.equalTo(dateLabel)
        }
    }
    
    func fill(with channel: ChannelWithMessagesModel) {
        channelNameLabel.text = channel.name
        subtitleLabel.text = channel.privacy.rawValue.lowercased()
        setupNewMessagesBadge(with: channel.newMessages.count)
        
        guard let lastSendedMessage = channel.messages.last else { return }
        let sendedTime = lastSendedMessage.sentDate.timeIntervalSince1970 / 1000
        let sendedDate = Date(timeIntervalSince1970: TimeInterval(sendedTime))
        dateLabel.text = sendedDate.format(dateFormat: .ddMMYYYY)
    }
    
    private func setupNewMessagesBadge(with messagesCount: Int) {
        if messagesCount > 0 {
            newMessagesBadgeLabel.text = "\(messagesCount)"
            newMessagesBadgeLabel.isHidden = false
        } else {
            newMessagesBadgeLabel.isHidden = true
        }
    }
}
