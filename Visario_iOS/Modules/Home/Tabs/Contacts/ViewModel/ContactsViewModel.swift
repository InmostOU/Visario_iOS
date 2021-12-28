//
//  ContactsViewModel.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.08.2021.
//

import Moya

final class ContactsViewModel {
    
    // MARK: - Variables
    
    private let contactsService = ContactsAPIService()
    
    weak var view: (BaseView & UIViewController)?
    
    private(set) var allContacts: [ContactModel] = []
    private(set) var searchedContacts: [ContactModel] = []
    
    func getAllContacts(callback: @escaping (Result<Void, Error>) -> Void) {
        contactsService.getAllContacts { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let contacts):
                self.allContacts = contacts
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func deleteContact(at index: Int, callback: @escaping (Result<AuthDataModel, Error>) -> Void) {
        let userID = allContacts[index].id
        allContacts.remove(at: index)
        
        contactsService.deleteContact(id: userID) { response in
            switch response {
            case .success(let void):
                
                callback(.success(void))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func addContact(contact: ContactModel, callback: @escaping (Result<AuthDataModel, Error>) -> Void) {
        guard !allContacts.contains(where: { $0.username == contact.username }) else { return }
        
        contactsService.addContact(username: contact.username) { response in
            switch response {
            case .success(let void):
                self.allContacts.append(contact)
                callback(.success(void))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func searchContacts(by query: String, callback: @escaping (Result<Void, Error>) -> Void) {
        contactsService.findContact(username: query) { [weak self] response in
            switch response {
            case .success(let contacts):
                self?.searchedContacts = contacts
                callback(.success(()))
            case .failure(let error):
                print(error)
                callback(.failure(error))
            }
        }
    }
    
    func getContactsActivityStatus(by userArn: String, callback: @escaping (Result<Void, Error>) -> Void) {
        contactsService.getContactsActivityStatus(by: userArn) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let contacts):
                for contact in contacts {
                    guard let contactIndex = self.allContacts.firstIndex(where: { $0.userArn == contact.userArn }) else { return }
                    self.allContacts[contactIndex].online = contact.status == "online" ? true : false
                }
                callback(.success(()))
            case .failure(let error):
                print(error)
                callback(.failure(error))
            }
        }
    }
    
    func getSearchedContactsActivityStatus(by userArn: String, callback: @escaping (Result<Void, Error>) -> Void) {
        contactsService.getContactsActivityStatus(by: userArn) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let contacts):
                for contact in contacts {
                    if let contactIndex = self.searchedContacts.firstIndex(where: { $0.userArn == contact.userArn }) {
                        self.searchedContacts[contactIndex].online = contact.status == "online" ? true : false
                    }
                }
                callback(.success(()))
            case .failure(let error):
                print(error)
                callback(.failure(error))
            }
        }
    }
    
    func setActivityStatus(of contact: ContactModel) {
        guard let contactIndex = allContacts.firstIndex(where: { $0.userArn == contact.userArn }) else { return }
        allContacts[contactIndex].online = contact.online
    }

    func removeAllSearchedContacts() {
        searchedContacts.removeAll()
    }
}

// MARK: - Router methods

extension ContactsViewModel {
    
    func showContactInfo(with profile: ContactModel) {
        let profileViewModel = ProfileViewModel(profile: profile)
        let profileViewController = ProfileViewController(viewModel: profileViewModel)
        view?.navigationController?.pushViewController(profileViewController, animated: true)
    }
}
