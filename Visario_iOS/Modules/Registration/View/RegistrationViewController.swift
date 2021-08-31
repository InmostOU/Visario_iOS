//
//  RegistrationViewController.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 03.08.2021.
//

import UIKit
import SnapKit

final class RegistrationViewController: UIViewController {
    
    // MARK: - Variables
    
    private let authViewModel = AuthViewModel()
    
    private let fieldsStackInnerSpacing: CGFloat = 20.0
    private var isPasswordEyeButtonTapped = false
    private var isConfirmPasswordEyeButtonTapped = false
    
    private var activeTextField: UITextField!
    
    private enum FieldTag: CustomStringConvertible {
        case userName
        case email
        case firstName
        case lastName
        case birthDate
        case password
        case confirmPassword
        
        var index: Int {
            switch self {
            case .userName:
                return 0
            case .email:
                return 1
            case .firstName:
                return 2
            case .lastName:
                return 3
            case .birthDate:
                return 4
            case .password:
                return 5
            case .confirmPassword:
                return 6
            }
        }
        
        var description: String {
            switch self {
            case .userName:
                return "latin letters, and symbols \". -\" (dot, dash)"
            case .email:
                return "standard email regexp validator"
            case .firstName:
                return "allowed only letters"
            case .lastName:
                return "allowed only letters"
            case .birthDate:
                return "dd.mm.yyyy"
            case .password:
                return "must contains at least: 6 characters, 1 digit, 1 specific symbol"
            case .confirmPassword:
                return "must contains at least: 6 characters, 1 digit, 1 specific symbol"
            }
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome"
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .purple
        return label
    }()
    
    private lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.innerPaddings(left: 15, right: 15)
        textField.placeholder = "Username"
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.delegate = self
        textField.tag = FieldTag.userName.index
        return textField
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.innerPaddings(left: 15, right: 15)
        textField.placeholder = "Email"
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.delegate = self
        textField.tag = FieldTag.email.index
        return textField
    }()
    
    private lazy var firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.innerPaddings(left: 15, right: 15)
        textField.placeholder = "First name"
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.delegate = self
        textField.tag = FieldTag.firstName.index
        return textField
    }()
    
    private lazy var lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.innerPaddings(left: 15, right: 15)
        textField.placeholder = "Last name"
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.delegate = self
        textField.tag = FieldTag.lastName.index
        return textField
    }()
    
    private lazy var dateOfBirthTextField: UITextField = {
        let textField = UITextField()
        textField.innerPaddings(left: 15, right: 15)
        textField.tintColor = .clear
        textField.placeholder = "Date of birth (Optional)"
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.delegate = self
        textField.tag = FieldTag.birthDate.index
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.innerPaddings(left: 15, right: 15)
        textField.isSecureTextEntry = true
        textField.placeholder = "Password"
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.rightViewMode = .always
        textField.rightView = passwordEyeButton
        textField.delegate = self
        textField.tag = FieldTag.password.index
        return textField
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.innerPaddings(left: 15, right: 15)
        textField.isSecureTextEntry = true
        textField.placeholder = "Confirm password"
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.rightViewMode = .always
        textField.rightView = confirmPasswordEyeButton
        textField.delegate = self
        textField.tag = FieldTag.confirmPassword.index
        return textField
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    private lazy var fieldsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = fieldsStackInnerSpacing
        return stack
    }()
    
    private lazy var passwordEyeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(passwordEyeButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .black
        button.isEnabled = false
        return button
    }()
    
    private lazy var confirmPasswordEyeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(confirmPasswordEyeButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .black
        button.isEnabled = false
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .gray
        button.isEnabled = false
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(registerButtonHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace, doneButton], animated: false)
        return toolBar
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authViewModel.view = self
        
        setupSubviews()
        configureConstraints()
        addKeyboardAppearingObservers()
    }
    
    private func addKeyboardAppearingObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    private func setupSubviews() {
        view.backgroundColor = .white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        dateOfBirthTextField.inputView = datePicker
        dateOfBirthTextField.inputAccessoryView = toolBar
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubviews(titleLabel, fieldsStackView, registerButton)
        
        fieldsStackView.addArrangedSubviews(usernameTextField, emailTextField, firstNameTextField, lastNameTextField, dateOfBirthTextField, passwordTextField, confirmPasswordTextField)
    }
    
    private func configureConstraints() {
        scrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(view.layoutMarginsGuide)
        }
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.height.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(20)
            $0.centerX.equalTo(containerView)
        }
        fieldsStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
        usernameTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview()
        }
        emailTextField.snp.makeConstraints {
            $0.height.equalTo(usernameTextField)
            $0.leading.trailing.equalToSuperview()
        }
        firstNameTextField.snp.makeConstraints {
            $0.height.equalTo(usernameTextField)
            $0.leading.trailing.equalToSuperview()
        }
        lastNameTextField.snp.makeConstraints {
            $0.height.equalTo(usernameTextField)
            $0.leading.trailing.equalToSuperview()
        }
        dateOfBirthTextField.snp.makeConstraints {
            $0.height.equalTo(usernameTextField)
            $0.leading.trailing.equalToSuperview()
        }
        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(usernameTextField)
            $0.leading.trailing.equalToSuperview()
        }
        confirmPasswordTextField.snp.makeConstraints {
            $0.height.equalTo(usernameTextField)
            $0.leading.trailing.equalToSuperview()
        }
        passwordEyeButton.snp.makeConstraints {
            $0.height.equalTo(25)
            $0.width.equalTo(passwordEyeButton.snp.height).multipliedBy(2.4)
        }
        confirmPasswordEyeButton.snp.makeConstraints {
            $0.height.equalTo(25)
            $0.width.equalTo(confirmPasswordEyeButton.snp.height).multipliedBy(2.4)
        }
        registerButton.snp.makeConstraints {
            $0.top.equalTo(fieldsStackView.snp.bottom).offset(50)
            $0.height.equalTo(40)
            $0.width.equalTo(150)
            $0.centerX.equalTo(fieldsStackView)
        }
    }
    
    private func checkRegisterButtonEnabling() {
        guard !(usernameTextField.text?.isEmpty ?? false),
              !(emailTextField.text?.isEmpty ?? false),
              !(firstNameTextField.text?.isEmpty ?? false),
              !(lastNameTextField.text?.isEmpty ?? false),
              !(passwordTextField.text?.isEmpty ?? false),
              !(confirmPasswordTextField.text?.isEmpty ?? false) else {
            
            registerButton.isEnabled = false
            registerButton.backgroundColor = .gray
            return
        }
        
        guard isValid(usernameTextField),
              isValid(emailTextField),
              isValid(firstNameTextField),
              isValid(lastNameTextField),
              isValid(passwordTextField),
              isValid(confirmPasswordTextField) else {
            
            registerButton.isEnabled = false
            registerButton.backgroundColor = .gray
            return
        }
              
        registerButton.isEnabled = true
        registerButton.backgroundColor = .purple
    }
    
    private func isValid(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return true }
        
        switch textField.tag {
        case FieldTag.userName.index:
            return text.isValidUserName()
        case FieldTag.email.index:
            return text.isValidEmail()
        case FieldTag.firstName.index, FieldTag.lastName.index:
            return text.isValidLastFirstName()
        case FieldTag.birthDate.index:
            return true
        case FieldTag.password.index, FieldTag.confirmPassword.index:
            return text.isValidPassword()
        default:
            return false
        }
    }
    
    private func alignFieldsStackSpacing() {
        fieldsStackView.subviews.forEach { subview in
            if fieldsStackView.customSpacing(after: subview) < fieldsStackInnerSpacing {
                fieldsStackView.setCustomSpacing(fieldsStackInnerSpacing, after: subview)
            }
        }
    }
    
    private func setupFieldsStackView(with textField: UITextField) {
        textField.layer.borderColor = isValid(textField) ? UIColor.black.cgColor : UIColor.red.cgColor
        textField.textColor = .black
        passwordEyeButton.isEnabled = false
        confirmPasswordEyeButton.isEnabled = false
        hintLabel.isHidden = false
        
        
        switch textField.tag {
        case FieldTag.userName.index:
            fieldsStackView.insertArrangedSubview(hintLabel, at: FieldTag.userName.index + 1)
            hintLabel.text = FieldTag.userName.description
        case FieldTag.email.index:
            fieldsStackView.insertArrangedSubview(hintLabel, at: FieldTag.email.index + 1)
            hintLabel.text = FieldTag.email.description
        case FieldTag.firstName.index:
            fieldsStackView.insertArrangedSubview(hintLabel, at: FieldTag.firstName.index + 1)
            hintLabel.text = FieldTag.firstName.description
        case FieldTag.lastName.index:
            fieldsStackView.insertArrangedSubview(hintLabel, at: FieldTag.lastName.index + 1)
            hintLabel.text = FieldTag.lastName.description
        case FieldTag.birthDate.index:
            fieldsStackView.insertArrangedSubview(hintLabel, at: FieldTag.birthDate.index + 1)
            hintLabel.text = FieldTag.birthDate.description
        case FieldTag.password.index:
            fieldsStackView.insertArrangedSubview(hintLabel, at: FieldTag.password.index + 1)
            hintLabel.text = FieldTag.password.description
            passwordEyeButton.isEnabled = true
        case FieldTag.confirmPassword.index:
            fieldsStackView.insertArrangedSubview(hintLabel, at: FieldTag.confirmPassword.index + 1)
            hintLabel.text = FieldTag.confirmPassword.description
            confirmPasswordEyeButton.isEnabled = true
        default:
            break
        }
        
        hintLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
        }
        
        alignFieldsStackSpacing()
        fieldsStackView.setCustomSpacing(5, after: textField)
    }
    
    // disappearing hint animation
    private func wrongPasswordsMatchingNotification(withDuration duration: Double = 0.3) {
        let oldHintLabelText = hintLabel.text
        let oldTextColor = hintLabel.textColor
        
        UIView.animate(withDuration: duration, delay: 0, options: [.autoreverse]) {
            self.hintLabel.alpha = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.hintLabel.text = "Passwords not matched!"
                self.hintLabel.textColor = .red
            }
        } completion: { complete in
            self.hintLabel.alpha = 1
            
            UIView.animate(withDuration: duration, delay: duration * 3, options: [.autoreverse]) {
                self.hintLabel.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + duration * 3.8) {
                    self.hintLabel.text = oldHintLabelText
                    self.hintLabel.textColor = oldTextColor
                }
            } completion: { complete in
                self.hintLabel.alpha = 1
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func registerButtonHandler(_ sender: UIButton) {
        guard passwordTextField.text == confirmPasswordTextField.text else {
            wrongPasswordsMatchingNotification()
            return
        }
        
        view.showRotationHUD()
        
        authViewModel.registerUser(
            firstName: firstNameTextField.text ?? "",
            lastName: lastNameTextField.text ?? "",
            birthDay: UInt(datePicker.date == Date() ? 0 : datePicker.date.timeIntervalSince1970),
            userName: usernameTextField.text ?? "",
            password: passwordTextField.text ?? "",
            matchingPassword: confirmPasswordTextField.text ?? "",
            email: emailTextField.text ?? ""
        ) { response in
            switch response {
            case .success(_):
                self.view.showSuccessHUD()
            case .failure(_):
                self.view.hideHUD()
                break
            }
        }
    }
    
    @objc private func passwordEyeButtonTapped(_ sender: UIButton) {
        isPasswordEyeButtonTapped.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordEyeButtonTapped
        let eyeIcon = UIImage(systemName: isPasswordEyeButtonTapped ? "eye" : "eye.slash")
        sender.setImage(eyeIcon, for: .normal)
    }
    
    @objc private func confirmPasswordEyeButtonTapped(_ sender: UIButton) {
        isConfirmPasswordEyeButtonTapped.toggle()
        confirmPasswordTextField.isSecureTextEntry = !isConfirmPasswordEyeButtonTapped
        let eyeIcon = UIImage(systemName: isConfirmPasswordEyeButtonTapped ? "eye" : "eye.slash")
        sender.setImage(eyeIcon, for: .normal)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardHeight = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + 20, right: 0)
        scrollView.contentInset = contentInsets
        var viewRect = view.frame
        viewRect.size.height -= keyboardHeight
        guard let activeTextField = activeTextField else { return }
        if !viewRect.contains(activeTextField.frame.origin) {
            let destinationPoint = CGPoint(x: 0, y: activeTextField.frame.origin.y - keyboardHeight)
            scrollView.setContentOffset(destinationPoint, animated: true)
        }
    }
    
    @objc private func keyboardWillHide() {
        scrollView.contentInset = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func doneButtonTapped() {
        let dateString = datePicker.date.format(dateFormat: .ddMMYYYY)
        dateOfBirthTextField.text = dateString
        dateOfBirthTextField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setupFieldsStackView(with: textField)
        activeTextField = textField
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = isValid(textField) ? UIColor.gray.cgColor : UIColor.red.cgColor
        textField.textColor = .gray
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.layer.borderColor = isValid(textField) ? UIColor.black.cgColor : UIColor.red.cgColor
        checkRegisterButtonEnabling()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        hintLabel.isHidden = true
        alignFieldsStackSpacing()
        return true
    }
}

// MARK: - BaseView

extension RegistrationViewController: BaseView {
    
}
