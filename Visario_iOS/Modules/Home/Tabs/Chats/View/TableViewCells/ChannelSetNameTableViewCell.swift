//
//  ChannelSetNameTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 16.08.2021.
//

import UIKit

protocol CreateChannelCellDelegate: class {
    func setChannelName(name: String)
    func setChannelPrivacy(_ isOn: Bool, for indexPath: IndexPath)
    func setChannelDescription(description: String)
}

final class ChannelSetNameTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: CreateChannelCellDelegate?
    
    // MARK: - UI Elements
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Set channel name"
        textField.innerPaddings(left: 5, right: 5)
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(setName), for: .editingChanged)
        textField.delegate = self
        return textField
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
        contentView.addSubview(nameTextField)
    }
    
    private func addConstraints() {
        nameTextField.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.trailing.equalTo(contentView.layoutMarginsGuide)
        }
    }
    
    func fill(with name: String) {
        nameTextField.text = name
    }
    
    @objc private func setName(_ sender: UITextField) {
        delegate?.setChannelName(name: sender.text ?? "")
    }
}

// MARK: - CreateChannelCellDelegate default implementation

extension CreateChannelCellDelegate {
    
    func setChannelName(name: String) { }
    func setChannelPrivacy(privacy: ChannelPrivacy) { }
    func setChannelDescription(description: String) { }
    
}

// MARK: - UITextFieldDelegate

extension ChannelSetNameTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
    }
}
