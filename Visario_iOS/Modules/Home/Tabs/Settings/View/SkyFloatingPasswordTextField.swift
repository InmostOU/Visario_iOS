//
//  SkyFloatingPasswordTextField.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 10.11.2021.
//

import SkyFloatingLabelTextField

final class SkyFloatingPasswordTextField: SkyFloatingLabelTextField {
    
    // MARK: - UI Elements
    
    lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Must contains at least: 6 characters, 1 digit, 1 specific symbol"
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textColor = .purple
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        common()
        setupViews()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        common()
    }
    
    private func common() {
        title = placeholder
    }
    
    private func setupViews() {
        addSubview(bottomLabel)
    }
    
    private func configureConstraints() {
        bottomLabel.snp.makeConstraints {
            $0.top.equalTo(snp.bottom)
            $0.height.greaterThanOrEqualTo(25)
            $0.width.equalTo(snp.width)
        }
    }
}
