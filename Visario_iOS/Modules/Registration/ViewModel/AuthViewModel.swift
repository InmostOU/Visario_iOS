//
//  AuthViewModel.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 03.08.2021.
//

import UIKit

final class AuthViewModel {
    
    private let authenticationService = AuthenticationService()
    private let contactsService = ContactsAPIService()
    
    weak var view: (BaseView & UIViewController)?
    
    func registerUser(firstName: String, lastName: String, birthDay: UInt, userName: String, password: String, matchingPassword: String, email: String, callback: @escaping (Result<Void, Error>) -> Void) {
        
        authenticationService.registerUser(firstName: firstName, lastName: lastName, birthDay: birthDay, userName: userName, password: password, matchingPassword: matchingPassword, email: email) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let void):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.goToLoginScreen()
                }
                callback(.success(void))
            case .failure(let error):
                self.view?.showError(error: error)
                callback(.failure(error))
            }
        }
    }
    
    func loginUser(email: String, password: String, callback: @escaping () -> Void) {
        authenticationService.loginUser(email: email, password: password) { [weak view] result in
            callback()
            switch result {
            case .success:
                UIApplication.shared.window?.rootViewController = ChimeTabBarController()
            case .failure(let error):
                view?.showAlert(title: "Error", message: "Something went wrong :(,\n\(error)")
            }
        }
    }
    
    func forgotPassword(email: String, callback: @escaping (Result<Void, Error>) -> Void) {
        authenticationService.forgotPassword(email: email, callback: callback)
    }
    
    func goToRegister() {
        let navigationItem = UIBarButtonItem(title: "Login")
        view?.navigationItem.backBarButtonItem = navigationItem
        self.view?.navigationController?.pushViewController(RegistrationViewController(), animated: true)
    }
    
    func goToForgotPassword() {
        let navigationItem = UIBarButtonItem(title: "Forgot Password")
        view?.navigationItem.backBarButtonItem = navigationItem
        self.view?.navigationController?.pushViewController(ForgotPasswordViewController(), animated: true)
    }
    
    private func goToLoginScreen() {
        let navigationItem = UIBarButtonItem(title: "Registration")
        view?.navigationItem.backBarButtonItem = navigationItem
        view?.navigationController?.pushViewController(LoginViewController(), animated: true)
    }
}
