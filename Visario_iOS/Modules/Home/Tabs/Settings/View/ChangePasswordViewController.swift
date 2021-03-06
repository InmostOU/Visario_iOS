//
//  ChangePasswordViewController.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 08.11.2021.
//

import UIKit
import SkyFloatingLabelTextField

final class ChangePasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    private let settingsViewModel = SettingsViewModel()
    
    // MARK: - UI Elements
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        return stackView
    }()
    
    private lazy var currentPasswordTextField: SkyFloatingPasswordTextField = {
        let textField = SkyFloatingPasswordTextField()
        textField.placeholder = "Current Password"
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .allEvents)
        textField.delegate = self
        return textField
    }()
    
    private lazy var newPasswordTextField: SkyFloatingPasswordTextField = {
        let textField = SkyFloatingPasswordTextField()
        textField.placeholder = "New Password"
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .allEvents)
        textField.delegate = self
        return textField
    }()
    
    private lazy var repeatPasswordTextField: SkyFloatingPasswordTextField = {
        let textField = SkyFloatingPasswordTextField()
        textField.placeholder = "Repeat Password"
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .allEvents)
        textField.delegate = self
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .gray
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.systemGray6, for: .disabled)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavController()
        setupViews()
        configureConstraints()
    }
    
    private func setupNavController() {
        navigationItem.title = "Change Password"
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(containerStackView)
        view.addSubview(saveButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        containerStackView.addArrangedSubview(currentPasswordTextField)
        containerStackView.addArrangedSubview(newPasswordTextField)
        containerStackView.addArrangedSubview(repeatPasswordTextField)
    }
    
    private func configureConstraints() {
        containerStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(view.layoutMarginsGuide)
        }
        currentPasswordTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        newPasswordTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(currentPasswordTextField)
        }
        repeatPasswordTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(currentPasswordTextField)
        }
        saveButton.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(40)
        }
    }
    
    private func checkSaveButtonEnabling() {
        // is not empty
        guard let text = currentPasswordTextField.text, !text.isEmpty,
              let text = newPasswordTextField.text, !text.isEmpty,
              let text = repeatPasswordTextField.text, !text.isEmpty
        else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .gray
            return
        }
        // is passwords valid, is newPassword == repeatPassword
        guard isValid(currentPasswordTextField),
              isValid(newPasswordTextField),
              isValid(repeatPasswordTextField),
              newPasswordTextField.text == repeatPasswordTextField.text
        else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .gray
            return
        }
        
        saveButton.isEnabled = true
        saveButton.backgroundColor = .systemBlue
    }
    
    private func isValid(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        return text.isValidPassword()
    }
}

// MARK: - Actions

@objc extension ChangePasswordViewController {
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func saveButtonTapped(_ sender: UIButton) {
        guard let oldPass = currentPasswordTextField.text,
              let newPass = newPasswordTextField.text,
              let repeatPass = repeatPasswordTextField.text
        else { return }
        
        view.endEditing(true)
        startDoneButtonSpinner(button: sender)
        
        settingsViewModel.changePassword(oldPass: oldPass, newPass: newPass, repeatPass: repeatPass) { [weak self] response in
            guard let self = self else { return }
            self.stopDoneButtonSpinner(button: sender)
            switch response {
            case .success(_):
                self.view.showSuccessHUD()
            case .failure(_):
                self.view.showFailedHUD()
            }
        }
    }
    
    private func startDoneButtonSpinner(button: UIButton) {
        button.setTitle("", for: .normal)
        button.addSubview(spinner)
        
        spinner.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        spinner.startAnimating()
    }
    
    private func stopDoneButtonSpinner(button: UIButton) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        button.setTitle("Done", for: .normal)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let floatingTextField = textField as? SkyFloatingPasswordTextField else { return }
        guard let text = floatingTextField.text else { return }
                    
        checkSaveButtonEnabling()
        
        if !text.isEmpty {
            if text.isValidPassword() {
                floatingTextField.errorMessage = ""
            } else {
                floatingTextField.errorMessage = "Invalid password"
            }
        } else {
            floatingTextField.errorMessage = ""
        }
        
        if floatingTextField.isFirstResponder {
            floatingTextField.bottomLabel.isHidden = false
        } else {
            floatingTextField.bottomLabel.isHidden = true
            floatingTextField.errorMessage = ""
            floatingTextField.title = ""
        }
        
        if !isValid(floatingTextField) {
            floatingTextField.textColor = .red
        } else {
            floatingTextField.textColor = .black
        }
    }
}

// MAR: - UITextFieldDelegate

extension ChangePasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
