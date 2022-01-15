//
//  ForgotPasswordViewController.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 15.11.2021.
//

import UIKit
import SkyFloatingLabelTextField

final class ForgotPasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    private let authViewModel = AuthViewModel()
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email address to receive additional instructions how to change password"
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    private lazy var hintBottomLabel: UILabel = {
        let label = UILabel()
        label.text = "email format"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private lazy var mailTextField: SkyFloatingLabelTextField = {
        let mailTextField = SkyFloatingLabelTextField()
        mailTextField.placeholder = "Email"
        mailTextField.addTarget(self, action: #selector(mailTextFieldDidChange), for: .editingChanged)
        return mailTextField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = .gray
        button.isEnabled = false
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
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
        
        setupNavigationController()
        setupViews()
        configureLayout()
    }
    
    private func setupNavigationController() {
        navigationItem.title = "Verify Email"
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(titleLabel)
        view.addSubview(mailTextField)
        view.addSubview(hintBottomLabel)
        view.addSubview(sendButton)
    }
    
    private func configureLayout() {
        mailTextField.snp.makeConstraints {
            $0.width.equalTo(view.layoutMarginsGuide)
            $0.height.equalTo(50)
            $0.center.equalToSuperview()
        }
        hintBottomLabel.snp.makeConstraints {
            $0.width.equalTo(view.layoutMarginsGuide)
            $0.centerX.equalTo(mailTextField)
            $0.top.equalTo(mailTextField.snp.bottom).offset(10)
        }
        titleLabel.snp.makeConstraints {
            $0.width.equalTo(view.layoutMarginsGuide)
            $0.bottom.equalTo(mailTextField.snp.top).offset(-30)
            $0.centerX.equalToSuperview()
        }
        sendButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(mailTextField.snp.bottom).offset(100)
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
    }
    
    private func checkSendButtonEnabling(by textField: UITextField) {
        guard let text = textField.text else { return }
        sendButton.isEnabled = text.isValidEmail()
        sendButton.backgroundColor = text.isValidEmail() ? .systemBlue : .gray
    }
}

// MARK: - UITextFieldDelegate

extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

// MARK: - Actions

@objc private extension ForgotPasswordViewController {

    private func send(_ sender: UIButton) {
        guard let email = mailTextField.text else { return }
        view.endEditing(true)
        startDoneButtonSpinner(button: sender)
        authViewModel.forgotPassword(email: email.lowercased()) { [weak self] response in
            guard let self = self else { return }
            self.stopDoneButtonSpinner(button: sender)
            switch response {
            case .success(_):
                self.showAlert(title: "Complete!", message: "Go to specified email for further instructions") {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self.view.showFailedHUD()
                print(error)
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
    
    private func mailTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        guard let floatingTextField = textField as? SkyFloatingLabelTextField else { return }
        checkSendButtonEnabling(by: floatingTextField)
        
        floatingTextField.errorMessage = text.isValidEmail() ? nil : "Invalid email"
        
        if text.isEmpty {
            floatingTextField.errorMessage = nil
        }
    }
    
    private func dismissKeyboard() {
        view.endEditing(true)
    }

}
