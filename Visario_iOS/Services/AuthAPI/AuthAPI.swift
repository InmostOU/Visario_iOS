//
//  AuthAPI.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 03.08.2021.
//

import Moya

enum AuthAPI {
    case register(firstName: String,
                  lastName: String,
                  birthDay: UInt,
                  userName: String,
                  password: String,
                  matchingPassword: String,
                  email: String)
    case login(email: String, password: String)
}

// MARK: - TargetType

extension AuthAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: Constants.authURL)!
    }
    
    var path: String {
        switch self {
        case .login(_, _):
            return Constants.loginPath
        case .register:
            return Constants.registerPath
        }
    }
    
    var method: Method {
        return .post
    }
    
    var sampleData: Data {
        switch self {
        case .register(firstName: let firstName, lastName: let lastName, birthDay: let birthDay, userName: let userName, password: let password, matchingPassword: let mathingPassword, email: let email):
            
            return "{\"firstName\" : \"\(firstName)\", \"lastName\" : \"\(lastName)\", \"birthday\" : \"\(birthDay)\", \"username\" : \"\(userName)\", \"password\" : \"\(password)\", \"matchingPassword\" : \"\(mathingPassword)\", \"email\" : \"\(email)\"}".data(using: .utf8) ?? Data()
            
        case .login(let email, let password):
            return "{\"email\" : \"\(email)\", \"password\" : \"\(password)\"}".data(using: .utf8) ?? Data()
        }
    }
    
    var task: Task {
        return .requestData(sampleData)
    }
    
    var headers: [String : String]? {
        return ["Content-type" : "application/json"]
    }
    
}

