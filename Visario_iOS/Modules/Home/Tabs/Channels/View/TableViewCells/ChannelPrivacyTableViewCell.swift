//
//  ChannelPrivacyTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 16.08.2021.
//

import UIKit

final class ChannelPrivacyTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: CreateChannelCellDelegate?
    
    private var indexPath: IndexPath = .init(row: 0, section: 0)
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.text = "Title"
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textColor = .gray
        label.text = "description"
        return label
    }()
    
    private lazy var privacySwitch: UISwitch = {
        let privacySwitch = UISwitch()
        privacySwitch.addTarget(self, action: #selector(setPrivacy), for: .valueChanged)
        return privacySwitch
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
        contentView.addSubviews(titleLabel,descriptionLabel, privacySwitch)
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(contentView.layoutMarginsGuide)
            $0.trailing.equalTo(privacySwitch.snp.leading).offset(-16)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.trailing.equalTo(titleLabel)
        }
        privacySwitch.snp.makeConstraints {
            $0.trailing.equalTo(contentView.layoutMarginsGuide)
            $0.centerY.equalToSuperview()
        }
    }
    
    func fill(with privacyModel: ChannelPrivacyModel, for indexPath: IndexPath) {
        self.indexPath = indexPath
        titleLabel.text = privacyModel.title
        descriptionLabel.text = privacyModel.description
    }
    
    @objc private func setPrivacy(_ sender: UISwitch) {
        delegate?.setChannelPrivacy(sender.isOn, for: indexPath)
    }
}
