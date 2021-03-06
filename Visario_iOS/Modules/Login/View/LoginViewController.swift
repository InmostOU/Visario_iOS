//
//  LoginViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 05.08.2021.
//

import UIKit
import SnapKit
import LocalAuthentication

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let authViewModel = AuthViewModel()
    
    private var isPasswordEyeButtonTapped = false
    let scanner = LAContext()
    
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
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        rightView.addSubview(passwordEyeButton)
        
        passwordTextField.rightView = rightView
        passwordTextField.rightViewMode = .always
        
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
        let registerButton = UIButton(type: .system)
        registerButton.setTitle("Register", for: .normal)
        registerButton.addTarget(self, action: #selector(goToRegisterTapped), for: .touchUpInside)
        registerButton.setTitleColor(.purple, for: .normal)
        return registerButton
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password", for: .normal)
        button.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        button.setTitleColor(.purple, for: .normal)
        return button
    }()
    
    private lazy var passwordEyeButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 30)
        button.addTarget(self, action: #selector(passwordEyeButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private lazy var biometricButton: UIButton = {
        var imageName = ""
        scanner.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)

        switch scanner.biometryType {
        case .faceID:
            imageName = "faceid"
        case .touchID:
            imageName = "touchid"
        default:
            break
        }

        let button = UIButton()
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = .purple
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.imageView?.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 3, bottom: 5, right: 3)
        button.isHidden = true
        button.addTarget(self, action: #selector(biometricButtonTapped), for: .touchUpInside)
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
        
        authViewModel.view = self
        
        configureView()
        configureLayout()
        checkAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
    }
    
    private func checkAuthorization() {
        if KeyChainStorage.shared.getProfile() != nil {
            biometricButton.isHidden = false
        }
    }
    
    private func startDoneButtonSpinner(button: UIButton) {
        DispatchQueue.main.async {
            button.setTitle("", for: .normal)
            button.addSubview(self.spinner)
            self.spinner.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            self.spinner.startAnimating()
        }
    }
    
    private func stopDoneButtonSpinner(button: UIButton) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        button.setTitle("Done", for: .normal)
    }
    
    // MARK: - Actions
    
    @objc
    private func loginTapped(_ sender: UIButton) {
        guard let email = mailTextField.text, let password = passwordTextField.text else { return }
        self.view.endEditing(true)
        self.startDoneButtonSpinner(button: sender)
        authViewModel.loginUser(email: email, password: password) {
            self.stopDoneButtonSpinner(button: sender)
        }
    }
    
    @objc
    private func goToRegisterTapped() {
        authViewModel.goToRegister()
    }
    
    @objc private func forgotPasswordButtonTapped() {
        authViewModel.goToForgotPassword()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func biometricButtonTapped(_ sender: UIButton) {
        let reason = "Please authorize with TouchID"
        if scanner.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: .none) {
            scanner.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self]
                success, error in
                guard let self = self else { return }
                guard success, error == nil else { return }
                guard let profile = KeyChainStorage.shared.getProfile() else {
                    print("No profile")
                    return
                }
                guard let password = profile.password else {
                    print("No Password")
                    return
                }
                self.startDoneButtonSpinner(button: self.loginButton)
                self.authViewModel.loginUser(email: profile.email, password: password) { [weak self] in
                    guard let self = self else { return }
                    self.stopDoneButtonSpinner(button: self.loginButton)
                }
            }
        }
    }
    
    @objc private func passwordEyeButtonTapped(_ sender: UIButton) {
        isPasswordEyeButtonTapped.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordEyeButtonTapped
        let eyeIcon = UIImage(systemName: isPasswordEyeButtonTapped ? "eye" : "eye.slash")
        sender.setImage(eyeIcon, for: .normal)
    }
    
    // MARK: - Private
    
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
    
    private func configureView() {
        view.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
       
        loginStackView.addArrangedSubview(mailTextField)
        loginStackView.addArrangedSubview(passwordTextField)
        
        view.addSubview(welcomeLabel)
        view.addSubview(loginStackView)
        view.addSubview(loginButton)
        view.addSubview(biometricButton)
        view.addSubview(registerButton)
        view.addSubview(forgotPasswordButton)
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
        
        biometricButton.snp.makeConstraints {
            $0.width.height.equalTo(loginButton.snp.height)
            $0.leading.equalTo(loginButton.snp.trailing).offset(16)
            $0.centerY.equalTo(loginButton)
        }
        
        registerButton.snp.makeConstraints {
            $0.trailing.equalTo(passwordTextField.snp.trailing)
            $0.top.equalTo(loginButton.snp.bottom).offset(15)
        }
        
        forgotPasswordButton.snp.makeConstraints {
            $0.leading.equalTo(passwordTextField)
            $0.centerY.equalTo(registerButton)
        }
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkLoginButtonEnabling()
    }
}


