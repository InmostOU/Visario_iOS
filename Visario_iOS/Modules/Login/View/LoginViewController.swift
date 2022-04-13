//
//  LoginViewController.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 05.08.2021.
//

import UIKit
import SnapKit
import LocalAuthentication
import FBSDKLoginKit
import GoogleSignIn

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
    
    private lazy var mailTextField: VisarioTextField = {
        let mailTextField = VisarioTextField()
        mailTextField.placeholder = "Email"
        mailTextField.delegate = self
        return mailTextField
    }()
    
    private lazy var passwordTextField: VisarioTextField = {
        let passwordTextField = VisarioTextField(isSecure: true)
        passwordTextField.placeholder = "Password"
        passwordTextField.delegate = self
        return passwordTextField
    }()
    
    private lazy var passwordTextField1: UITextField = {
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
    
    private lazy var socialNetworkButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var facebookButton: SocialNetworkButton = {
        let fbButton = SocialNetworkButton()
        fbButton.layer.cornerRadius = 3
        fbButton.layer.masksToBounds = true
        fbButton.setImage(UIImage(named: "facebook"), for: .normal)
        fbButton.setTitle("", for: .normal)
        fbButton.addTarget(self, action: #selector(fbLoginButtonTapped), for: .touchUpInside)
        return fbButton
    }()
    
    private lazy var googleButton: SocialNetworkButton = {
        let fbButton = SocialNetworkButton()
        fbButton.layer.cornerRadius = 3
        fbButton.layer.masksToBounds = true
        fbButton.setImage(UIImage(named: "google"), for: .normal)
        fbButton.setTitle("", for: .normal)
        fbButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
        return fbButton
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
        if let profile = KeyChainStorage.shared.getProfile(),
           let password = profile.password,
           !password.isEmpty
        {
            biometricButton.isHidden = false
        }
    }
    
    private func startSpinner(for button: UIButton) {
        DispatchQueue.main.async {
            button.setTitle("", for: .normal)
            button.addSubview(self.spinner)
            self.spinner.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            self.spinner.startAnimating()
        }
    }
    
    private func stopSpinner(in button: UIButton) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        button.setTitle("Done", for: .normal)
    }
    
    // MARK: - Actions
    
    @objc
    private func loginTapped(_ sender: UIButton) {
        guard let email = mailTextField.text, let password = passwordTextField.text else { return }
        self.view.endEditing(true)
        self.startSpinner(for: sender)
        authViewModel.loginUser(email: email.lowercased(), password: password) {
            self.stopSpinner(in: sender)
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
                self.startSpinner(for: self.loginButton)
                self.authViewModel.loginUser(email: profile.email, password: password) { [weak self] in
                    guard let self = self else { return }
                    self.stopSpinner(in: self.loginButton)
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
    
    @objc private func fbLoginButtonTapped() {
        LoginManager().logIn(permissions: ["public_profile"], from: self) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print("Encountered Erorr: \(error)")
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                guard let fbToken = result?.token?.tokenString else { return }
                self.startSpinner(for: self.facebookButton)
                self.authViewModel.authenticationViaFacebook(with: fbToken) {
                    self.stopSpinner(in: self.facebookButton)
                }
            }
        }
    }
    
    @objc private func googleLoginButtonTapped() {
        getGoogleIdToken { result in
            switch result {
            case .success(let idToken):
                self.startSpinner(for: self.googleButton)
                self.authViewModel.authenticationViaGoogle(with: idToken) {
                    self.stopSpinner(in: self.googleButton)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Private
    
    private func getGoogleIdToken(callback: @escaping (Result<String, Error>) -> Void) {
        let signInConfig = GIDConfiguration(clientID: "843481142159-97t19lh06n87hdi7rnsp4k1b8q3q3v0k.apps.googleusercontent.com")
        
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }

            user.authentication.do { authentication, error in
                guard error == nil else {
                    callback(.failure(error!))
                    return
                }
                guard let idToken = authentication?.idToken else { return }
                callback(.success(idToken))
            }
        }
    }
    
    private func checkLoginButtonEnabling() {
        guard let password = passwordTextField.text,
              let email = mailTextField.text,
              !email.isEmpty,
              !password.isEmpty
        else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .gray
            return
        }
        loginButton.isEnabled = true
        loginButton.backgroundColor = .purple
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
        
        socialNetworkButtonsStackView.addArrangedSubviews(googleButton, facebookButton)
        view.addSubviews(socialNetworkButtonsStackView)
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
        
        socialNetworkButtonsStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.layoutMarginsGuide)
        }
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkLoginButtonEnabling()
    }
}


