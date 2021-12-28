//
//  SettingTableViewCell.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 12.08.2021.
//

import UIKit
import SnapKit

final class SettingTableViewCell: UITableViewCell {
    
    // MARK: - UI
    
    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 6
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        return iconImageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        return titleLabel
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(titleLabel)
        
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImageView.image = nil
        titleLabel.text = nil
        iconContainerView.backgroundColor = nil
    }
    
    // MARK: - Public
    
    public func configure(with model: SettingOption) {
        titleLabel.text = model.title
        iconImageView.image = model.icon
        iconContainerView.backgroundColor = model.iconBackground
    }
    
    // MARK: - Private
    
    private func configureLayout() {
        let size = frame.size.height - 16.0
        let imageSize = size / 1.5
        
        iconContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(size)
        }
        
        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(imageSize)
            $0.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconContainerView.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
        }
    }
}
