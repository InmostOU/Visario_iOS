//
//  EditProfileViewModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 12.08.2021.
//

import UIKit

final class EditProfileViewModel {
    
    // MARK: - Properties
    
    private let contactsService = ContactsAPIService()
    
    var profile: ProfileModel
    var updatedProfile: UpdateProfileDataModel
    var settingsDataSource = [TableViewData]()
    weak var view: (BaseView & UIViewController)?
    
    // MARK: - Init
    
    init(profile: ProfileModel) {
        self.profile = profile
        self.updatedProfile = UpdateProfileDataModel(firstName: profile.firstName, lastName: profile.lastName, username: profile.username, birthday: profile.birthday, about: profile.about, showEmailTo: profile.showEmailTo, showPhoneNumberTo: profile.showPhoneNumberTo)
    }
    
    // MARK: - Public
    
    func viewWillAppear() {
        configureSettings()
    }
    
    func updateUserProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        
        contactsService.updateProfile(firstName: updatedProfile.firstName, lastName: updatedProfile.lastName, username: updatedProfile.username, birthday: updatedProfile.birthday, about: updatedProfile.about, showEmailTo: updatedProfile.showEmailTo.rawValue, showPhoneNumberTo: updatedProfile.showPhoneNumberTo.rawValue) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                completion(.success(()))
                
                let updatedProfileModel = ProfileModel(id: self.profile.id, userArn: self.profile.userArn, firstName: self.updatedProfile.firstName, lastName: self.updatedProfile.lastName, username: self.updatedProfile.username, birthday: self.updatedProfile.birthday, email: self.profile.email, phoneNumber: self.profile.phoneNumber, image: self.profile.image, about: self.updatedProfile.about, showEmailTo: self.updatedProfile.showEmailTo, showPhoneNumberTo: self.updatedProfile.showPhoneNumberTo)
                
                KeyChainStorage.shared.saveProfile(profile: updatedProfileModel)
                
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
    }
    
    func uploadUserPhoto(image: UIImage) {
        
        guard let pngData = image.pngData() else { return }
        let size = Double(pngData.count) / 1024
        
        if size > 5000 { return }
        print("actual size of image in KB: %f ", Double(pngData.count) / 1024)
        
        contactsService.uploadUserPhoto(data: pngData, description: "useravatar") { [weak self] result in
            switch result { 
            case .success(let response):
                print(response)
               
                self?.contactsService.getProfile { res in
                    switch res {
                    case .success(let newProfile):
                        self?.profile = newProfile
                        KeyChainStorage.shared.saveProfile(profile: newProfile)
                        
                    case .failure(let error):
                        self?.view?.showError(error: error)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Private
    
    private func configureSettings() {
        settingsDataSource.append(TableViewData(footerTitle: "Enter your name and add an optional profile photo.", items: [
                                                    TextFieldModel(text: updatedProfile.firstName, placeholder: "First Name", isDateField: false, isPrivacyField: false),
                                                    TextFieldModel(text: updatedProfile.lastName, placeholder: "Last Name", isDateField: false, isPrivacyField: false)]))
        
        settingsDataSource.append(TableViewData(footerTitle: "Any details such as occupation, city or hobbies.\nExample: Proffesional esigner from California", items: [TextFieldModel(text: updatedProfile.about, placeholder: "About", isDateField: false, isPrivacyField: false)]))
        
        settingsDataSource.append(TableViewData(footerTitle: "You can use a-z, 0-9. Minimum length is 5 characters", items: [TextFieldModel(text: updatedProfile.username, placeholder: "Username", isDateField: false, isPrivacyField: false)]))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let timeIntervalDate = TimeInterval(updatedProfile.birthday)
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let dateText = formatter.string(from: date)
        
        settingsDataSource.append(TableViewData(footerTitle: "Your birthday. You can change who will see it.", items: [TextFieldModel(text: dateText, placeholder: "Birthday", isDateField: true, isPrivacyField: false)]))
        
        let showNumberText: String
        let showEmailText: String
        
        switch updatedProfile.showPhoneNumberTo {
        case .contacts:
            showNumberText = "Only Contacts"
        case .everyone:
            showNumberText = "Everyone"
        case .nobody:
            showNumberText = "Only me"
        }
        
        switch updatedProfile.showEmailTo {
        case .contacts:
            showEmailText = "Only Contacts"
        case .everyone:
            showEmailText = "Everyone"
        case .nobody:
            showEmailText = "Only me"
        }
        
        settingsDataSource.append(TableViewData(footerTitle: "Privacy settings. You can control who will see your info.", items: [TextFieldModel(text: showNumberText, placeholder: "Who can see your phone number?", isDateField: false, isPrivacyField: true),                                                                 TextFieldModel(text: showEmailText, placeholder: "Who can see your email?", isDateField: false, isPrivacyField: true)]))
    }
}
