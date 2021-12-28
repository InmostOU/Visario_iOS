//
//  ChannelDescriptionTableViewCell.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 24.08.2021.
//

import UIKit

final class ChannelDescriptionTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let placeholderText = "Description text ..."
    
    weak var delegate: CreateChannelCellDelegate?
    
    // MARK: - UI Elements
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.text = placeholderText
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .lightGray
        textView.delegate = self
        return textView
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
    }
    
    private func addConstraints() {
        descriptionTextView.snp.makeConstraints {
            $0.edges.equalTo(contentView.layoutMarginsGuide)
            $0.height.equalTo(100)
        }
    }
}

// MARK: - UITextViewDelegate

extension ChannelDescriptionTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard descriptionTextView.textColor == .lightGray else { return }
        descriptionTextView.text = ""
        descriptionTextView.textColor = .black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard descriptionTextView.text.isEmpty else  { return }
        descriptionTextView.text = placeholderText
        descriptionTextView.textColor = .lightGray
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.setChannelDescription(description: textView.text)
    }
}
