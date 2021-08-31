//
//  ChannelTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 11.08.2021.
//

import SnapKit

final class ChannelTableViewCell: UITableViewCell {
    
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
        label.textAlignment = .right
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
        contentView.addSubviews(iconImageView, channelNameLabel, subtitleLabel, dateLabel)
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
    }
    
    func fill(with channel: ChannelModel) {
        channelNameLabel.text = channel.name
        subtitleLabel.text = channel.privacy.rawValue.lowercased()
        dateLabel.text = Date().format(dateFormat: .ddMMYYYY)
    }
}
