//
//  VisarioTextField.swift
//  Visario_iOS
//
//  Created by VitaliyButsan on 13.04.2022.
//

import UIKit

final class VisarioTextField: UITextField {
    
    // MARK: - Properties
    
    private var isEyeClosed = true
    
    // MARK: - UI Elements
    
    private lazy var eyeButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 30)
        button.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    // MARK: - Lifecycle
    
    convenience init(isSecure: Bool = false) {
        self.init(frame: .zero)
        
        setupTextField(isSecure: isSecure)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTextField(isSecure: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextField(isSecure: Bool) {
        innerPaddings(left: 15, right: 15)
        isSecureTextEntry = isSecure
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        
        if isSecure {
            addEye()
        }
    }
    
    private func addEye() {
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        newView.addSubview(eyeButton)
        rightView = newView
        rightViewMode = .always
    }
    
    @objc private func eyeButtonTapped(_ sender: UIButton) {
        isEyeClosed.toggle()
        isSecureTextEntry = isEyeClosed
        let eyeIcon = UIImage(systemName: isEyeClosed ? "eye.slash" : "eye")
        sender.setImage(eyeIcon, for: .normal)
    }
}
