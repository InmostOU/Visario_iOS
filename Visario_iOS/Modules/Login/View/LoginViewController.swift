//
//  LoginViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 05.08.2021.
//

import UIKit
import SnapKit

final class LoginViewController: UIViewController, BaseView {
    
    // MARK: - Properties
    
    private let authViewModel = AuthViewModel()
    
    // MARK: - UI
    
    private lazy var welcomeLabel: UILabel = {
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome"
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = .boldSystemFont(ofSize: 30)
        welcomeLabel.textColor = .purple
        return welcomeLabel
    }()
    
    private lazy var mailTextField: UITextField = {
        let mailTextField = UITextField()
        mailTextField.placeholder = "Email"
        mailTextField.borderStyle = .roundedRect
        mailTextField.delegate = self
        return mailTextField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.delegate = self
        return passwordTextField
    }()
    
    private lazy var loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .gray
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.layer.cornerRadius = 5
        loginButton.isEnabled = false
        return loginButton
    }()
    
    private lazy var loginStackView: UIStackView = {
        let loginStackView = UIStackView()
        loginStackView.axis = .vertical
        loginStackView.spacing = 10
        return loginStackView
    }()
    
    private lazy var registerButton: UIButton = {
        let registerButton = UIButton()
        registerButton.setTitle("Register", for: .normal)
        registerButton.addTarget(self, action: #selector(goToRegisterTapped), for: .touchUpInside)
        registerButton.setTitleColor(.purple, for: .normal)
        return registerButton
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        authViewModel.view = self
        
        configureView()
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
    }
    
    // MARK: - Actions
    
    @objc
    private func loginTapped() {
        guard let email = mailTextField.text, let password = passwordTextField.text else { return }
        
        authViewModel.loginUser(email: email, password: password)
    }
    
    @objc
    private func goToRegisterTapped() {
        authViewModel.goToRegister()
    }
    
    private func checkLoginButtonEnabling() {
        guard !(mailTextField.text?.isEmpty ?? false),
              !(passwordTextField.text?.isEmpty ?? false) else {
            
            self.loginButton.isEnabled = false
            self.loginButton.backgroundColor = .gray
            return
        }
        
        self.loginButton.isEnabled = true
        self.loginButton.backgroundColor = .purple
    }
    
    // MARK: - Private
    
    private func configureView() {
        view.backgroundColor = .white
       
        loginStackView.addArrangedSubview(mailTextField)
        loginStackView.addArrangedSubview(passwordTextField)
        
        view.addSubview(welcomeLabel)
        view.addSubview(loginStackView)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
    }
    
    private func configureLayout() {
        loginStackView.snp.makeConstraints {
            $0.center.equalTo(view)
            $0.leading.equalToSuperview().offset(50)
            $0.trailing.equalToSuperview().offset(-50)
        }
        
        mailTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview()
        }
        
        welcomeLabel.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(loginStackView.snp.top).offset(-30)
        }
        
        loginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(loginStackView.snp.bottom).offset(20)
            $0.height.equalTo(35)
            $0.width.equalTo(100)
        }
        
        registerButton.snp.makeConstraints {
            $0.trailing.equalTo(passwordTextField.snp.trailing)
            $0.top.equalTo(loginButton.snp.bottom).offset(15)
        }
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkLoginButtonEnabling()
    }
}


