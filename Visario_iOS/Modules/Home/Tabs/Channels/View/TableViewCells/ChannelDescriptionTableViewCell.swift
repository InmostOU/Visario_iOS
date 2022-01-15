//
//  ChannelDescriptionTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 24.08.2021.
//

import UIKit

final class ChannelDescriptionTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: CreateChannelCellDelegate?
    
    // MARK: - UI Elements
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.delegate = self
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Description text ..."
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 16, weight: .regular)
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
        contentView.addSubview(descriptionTextView)
        descriptionTextView.addSubview(placeholderLabel)
    }
    
    private func addConstraints() {
        descriptionTextView.snp.makeConstraints {
            $0.edges.equalTo(contentView.layoutMarginsGuide)
            $0.height.equalTo(100)
        }
        placeholderLabel.snp.makeConstraints {
            $0.height.equalTo(35)
            $0.leading.equalToSuperview().offset(5)
        }
    }
}

// MARK: - UITextViewDelegate

extension ChannelDescriptionTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.setChannelDescription(description: textView.text)
    }
}
