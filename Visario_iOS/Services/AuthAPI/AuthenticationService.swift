//
//  AuthenticationService.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 03.08.2021.
//

import Moya

enum NetworkError: Error {
    case statusCode
    case badRequest
    case errorDecode
    case errorMessage(String)
    case errorResponse(ErrorResponse)
}

final class AuthenticationService {
    
    typealias VoidCallback = (Result<Void, Error>) -> Void
    
    private let provider = MoyaProvider<AuthAPI>()
    
    func registerUser(firstName: String,
                      lastName: String,
                      birthDay: UInt,
                      userName: String,
                      password: String,
                      matchingPassword: String,
                      email: String,
                      callback: @escaping VoidCallback) {
        
        provider.request(.register(firstName: firstName, lastName: lastName, birthDay: birthDay, userName: userName, password: password, matchingPassword: matchingPassword, email: email)) { result in
            
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    callback(.failure(NetworkError.badRequest))
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func loginUser(email: String, password: String, callback: @escaping VoidCallback) {
        provider.request(.login(email: email, password: password)) { result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    callback(.failure(NetworkError.badRequest))
                    return
                }
                do {
                    let data = try JSONDecoder().decode(AuthDataModel.self, from: response.data)
                    guard let token = data.accessToken, var userProfile = data.userProfile else {
                        callback(.failure(NetworkError.errorDecode))
                        return
                    }
                    if let savedProfile = KeyChainStorage.shared.getProfile(), savedProfile.email == email {
                        userProfile.channels = savedProfile.channels
                    }
                    userProfile.password = password
                    KeyChainStorage.shared.saveProfile(profile: userProfile)
                    KeyChainStorage.shared.saveAccessToken(token: token)
                    callback(.success(()))
                }
                catch(let error) {
                    print(error)
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func loginViaFacebook(fbToken: String, callback: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.loginWithFacebook(fbToken: fbToken)) { result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    callback(.failure(NetworkError.badRequest))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AuthDataModel.self, from: response.data)
                    guard var userProfile = result.userProfile else {
                        callback(.failure(NetworkError.errorDecode))
                        return }
                    guard let token = result.accessToken else {
                        callback(.failure(NetworkError.errorDecode))
                        return
                    }
                    if let savedProfile = KeyChainStorage.shared.getProfile(),
                       savedProfile.email == userProfile.email {
                        userProfile.channels = savedProfile.channels
                    }
                    
                    KeyChainStorage.shared.saveProfile(profile: userProfile)
                    KeyChainStorage.shared.saveAccessToken(token: token)
                    callback(.success(()))
                } catch {
                    print(error)
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func loginViaGoogle(idToken: String, callback: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.loginWithGoogle(googleIdToken: idToken)) { result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    callback(.failure(NetworkError.badRequest))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AuthDataModel.self, from: response.data)
                    guard var userProfile = result.userProfile else {
                        callback(.failure(NetworkError.errorDecode))
                        return }
                    guard let token = result.accessToken else {
                        callback(.failure(NetworkError.errorDecode))
                        return
                    }
                    if let savedProfile = KeyChainStorage.shared.getProfile(),
                       savedProfile.email == userProfile.email {
                        userProfile.channels = savedProfile.channels
                    }
                    KeyChainStorage.shared.saveProfile(profile: userProfile)
                    KeyChainStorage.shared.saveAccessToken(token: token)
                    callback(.success(()))
                } catch {
                    print(error)
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func changePassword(oldPass: String, newPass: String, repeatPass: String, callback: @escaping VoidCallback) {
        provider.request(.changePassword(oldPass: oldPass, newPass: newPass, repeatPass: repeatPass)) { result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    callback(.failure(NetworkError.badRequest))
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func forgotPassword(email: String, callback: @escaping VoidCallback) {
        provider.request(.forgotPassword(email: email)) { result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    callback(.failure(NetworkError.badRequest))
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
}


