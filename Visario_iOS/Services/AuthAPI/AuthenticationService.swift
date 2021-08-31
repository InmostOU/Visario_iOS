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
}

final class AuthenticationService {
    
    private let provider = MoyaProvider<AuthAPI>()
    
    func registerUser(firstName: String,
                      lastName: String,
                      birthDay: UInt,
                      userName: String,
                      password: String,
                      matchingPassword: String,
                      email: String,
                      callback: @escaping (Result<(), Error>) -> Void) {
        
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
    
    func loginUser(email: String, password: String, callback: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.login(email: email, password: password)) { result in
            switch result {
            case .success(let response):
                guard (200...299).contains(response.statusCode) else {
                    callback(.failure(NetworkError.badRequest))
                    return
                }
                do {
                    let data = try JSONDecoder().decode(AuthDataModel.self, from: response.data)
                    guard let token = data.accessToken, let userProfile = data.userProfile else {
                        callback(.failure(NetworkError.errorDecode))
                        return
                    }
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
}


