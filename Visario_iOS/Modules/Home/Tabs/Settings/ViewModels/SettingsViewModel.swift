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
    private(set) var profile: ProfileModel?
    
    var settings = [SettingOption]()
    weak var view: (SettingsView & UIViewController)?
    
    // MARK: - Public
    
    func viewDidLoad() {
        configureSettings()
    }
    
    func viewWillAppear() {
        guard let userProfile = KeyChainStorage.shared.getProfile() else {
            getProfileData()
            return
        }
        
        self.profile = userProfile
        view?.configureProfileInfoView(profile: userProfile)
    }
    
    func logout() {
        KeyChainStorage.shared.deleteAccessToken()
        let loginNavigationController = UINavigationController(rootViewController: LoginViewController())
        UIApplication.shared.window?.rootViewController = loginNavigationController
    }
    
    func getProfileData() {
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
    
    // MARK: - Private
    
    private func configureSettings() {
        settings.append(SettingOption(title: "Log Out", icon: UIImage(systemName: "multiply.circle.fill"), iconBackground: .systemRed, handler: view?.showAlert))
    }
}


