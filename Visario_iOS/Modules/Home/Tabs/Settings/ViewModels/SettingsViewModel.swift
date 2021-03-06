//
//  SettingsViewModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 13.08.2021.
//

import UIKit

final class SettingsViewModel {
    
    // MARK: - Properties
    
    private let contactsService = ContactsAPIService()
    private let authenticationService = AuthenticationService()
    private(set) var profile: ProfileModel?
    
    var settings = [SettingOption]()
    weak var view: (SettingsView & UIViewController)?
    
    // MARK: - Public
    
    func viewDidLoad() {
        configureSettings()
        getProfileData()
    }
    
    func viewWillAppear() {
        getProfileData()
    }
    
    func logout() {
        KeyChainStorage.shared.deleteAccessToken()
        let loginNavigationController = UINavigationController(rootViewController: LoginViewController())
        UIApplication.shared.window?.rootViewController = loginNavigationController
    }
    
    func getProfileData() {
        if let userProfile = KeyChainStorage.shared.getProfile() {
            profile = userProfile
            view?.configureProfileInfoView(profile: userProfile)
        } else {
            contactsService.getProfile { result in
                switch result {
                case .success(let profileModel):
                    self.profile = profileModel
                    self.view?.configureProfileInfoView(profile: profileModel)
                    KeyChainStorage.shared.saveProfile(profile: profileModel)
                case .failure(let error):
                    self.view?.showError(error: error)
                }
            }
        }
    }
    
    func changePassword(oldPass: String, newPass: String, repeatPass: String, completion: @escaping (Result<Void, Error>) -> Void) {
        authenticationService.changePassword(oldPass: oldPass, newPass: newPass, repeatPass: repeatPass, callback: completion)
    }
    
    // MARK: - Private
    
    private func configureSettings() {
        settings.append(SettingOption(title: "Change Password", icon: UIImage(systemName: "lock"), iconBackground: .gray, handler: view?.goTohangePasswordView))
        settings.append(SettingOption(title: "Log Out", icon: UIImage(systemName: "multiply.circle.fill"), iconBackground: .systemRed, handler: view?.showAlert))
    }
}


