//
//  AddContactTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.08.2021.
//

import UIKit

protocol AddContactCellDelegate: class {
    func add(contact: ContactModel)
}

final class AddContactTableViewCell: ContactTableViewCell {
    
    // MARK: - Variables
    
    private var contact: ContactModel?
    
    weak var delegate: AddContactCellDelegate?
    
    // MARK: - UI Elements
    
    private lazy var addContactButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
        button.imageView?.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        button.addTarget(self, action: #selector(addContactButtonTapped), for: .touchUpInside)
        button.imageView?.tintColor = .black
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupSubviews()
        addConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        contentView.addSubview(addContactButton)
    }
    
    private func addConstraints() {
        addContactButton.snp.makeConstraints {
            $0.top.equalTo(10)
            $0.bottom.equalTo(-10)
            $0.trailing.equalTo(-30)
            $0.width.equalTo(addContactButton.snp.height)
        }
    }
    
    override func fill(with contact: ContactModel) {
        self.contact = contact
        titleLabel.text = contact.username

        switch contact.muted {
        case true:
            subtitleLabel.text = OnlineState.offline.rawValue
        case false:
            subtitleLabel.text = OnlineState.online.rawValue
        }
    }
    
    @objc private func addContactButtonTapped(_ sender: UIButton) {
        guard let delegate = delegate, let contact = contact else { return }
        delegate.add(contact: contact)
    }
    
    func setContainsContactIcon() {
        addContactButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
    }
}
