//
//  ContactsAPIService.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.08.2021.
//

import Moya

final class ContactsAPIService {
    
    // MARK: - Variables
    
    private let contactsProvider = MoyaProvider<ContactsAPI>()
    
    func getAllContacts(callback: @escaping (Result<[ContactModel], Error>) -> Void) {
        contactsProvider.request(.getAllContacts) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let contactsWrapper = try JSONDecoder().decode(ContactDataWrapper.self, from: response.data)
                    callback(.success(contactsWrapper.data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func deleteContact(id: Int, callback: @escaping (Result<AuthDataModel, Error>) -> Void) {
        contactsProvider.request(.deleteContact(id: id)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let responseModel = try JSONDecoder().decode(AuthDataModel.self, from: response.data)
                    callback(.success(responseModel))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func addContact(username: String, callback: @escaping (Result<AuthDataModel, Error>) -> Void) {
        contactsProvider.request(.addContact(username: username)) { response in
            switch response {
            case .success(let response):
                do {
                    let responseModel = try JSONDecoder().decode(AuthDataModel.self, from: response.data)
                    callback(.success(responseModel))
                } catch {
                    print(error)
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func findContact(username: String, callback: @escaping (Result<[ContactModel], Error>) -> Void) {
        contactsProvider.request(.findContact(username: username)) { response in
            switch response {
            case .success(let response):
                let decoder = JSONDecoder()
                guard let contacts = try? decoder.decode(ContactDataWrapper.self, from: response.data) else {
                    callback(.failure(NetworkError.badRequest))
                    return
                }
                callback(.success(contacts.data))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func updateProfile(firstName: String, lastName: String, username: String, birthday: Int, about: String, showEmailTo: String, showPhoneNumberTo: String, callback: @escaping (Result<AuthDataModel, Error>) -> Void) {
        
        contactsProvider.request(.updateProfile(firstName: firstName, lastName: lastName, username: username, birthday: birthday, about: about, showEmailTo: showEmailTo, showPhoneNumberTo: showPhoneNumberTo)) { response in
            switch response {
            case .success(let response):
                let decoder = JSONDecoder()
                guard let data = try? decoder.decode(AuthDataModel.self, from: response.data) else {
                    callback(.failure(NetworkError.badRequest))
                    return
                }
                callback(.success(data))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func getProfile(callback: @escaping (Result<ProfileModel, Error>) -> Void) {
        contactsProvider.request(.getProfile) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let profile = try JSONDecoder().decode(ProfileModel.self, from: response.data)
                    callback(.success(profile))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func editContact(id: Int, firstName: String, lastName: String, callback: @escaping (Result<AuthDataModel, Error>) -> Void) {
        contactsProvider.request(.editContact(id: id, firstName: firstName, lastName: lastName)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let data = try JSONDecoder().decode(AuthDataModel.self, from: response.data)
                    callback(.success(data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func uploadUserPhoto(data: Data, description: String, callback: @escaping (Result<AuthDataModel, Error>) -> Void) {
        contactsProvider.request(.uploadUserPhoto(data: data, description: description)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let data = try JSONDecoder().decode(AuthDataModel.self, from: response.data)
                    callback(.success(data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func getUserAvatarUrl(callback: @escaping (Result<AuthDataModel, Error>) -> Void) {
        contactsProvider.request(.getUserPhotoUrl) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let data = try JSONDecoder().decode(AuthDataModel.self, from: response.data)
                    callback(.success(data))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
}
