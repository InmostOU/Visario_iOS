//
//  EditContactProfileViewModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 15.08.2021.
//

import UIKit

final class EditContactProfileViewModel {
    
    // MARK: - Properties
    
    private let contactsService = ContactsAPIService()
    
    var profile: ContactModel
    var settingsDataSource = [TableViewData]()
    weak var view: (BaseView & UIViewController)?
    
    // MARK: - Init
    
    init(profile: ContactModel) {
        self.profile = profile
    }
    
    // MARK: - Public
    
    func viewWillAppear() {
        configureSettings()
    }
    
    func deleteContact(completion: @escaping () -> Void) {
        contactsService.deleteContact(id: profile.id) { result in
            switch result {
            case .success(let response):
                print(response)
                completion()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func editContact(completion: @escaping () -> Void) {
        contactsService.editContact(id: profile.id, firstName: profile.firstName, lastName: profile.lastName) { result in
            switch result {
            case .success(let response):
                print(response)
                completion()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Private
    
    private func configureSettings() {
        settingsDataSource.append(TableViewData(footerTitle: "", items: [
                                                    TextFieldModel(text: profile.firstName, placeholder: "First Name", isDateField: false, isPrivacyField: false),
                                                    TextFieldModel(text: profile.lastName, placeholder: "Last Name", isDateField: false, isPrivacyField: false)]))
    }
}

