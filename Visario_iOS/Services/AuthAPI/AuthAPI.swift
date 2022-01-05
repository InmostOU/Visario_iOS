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
    case loginWithFacebook(fbToken: String)
    case changePassword(oldPass: String, newPass: String, repeatPass: String)
    case forgotPassword(email: String)
}

// MARK: - TargetType

extension AuthAPI: TargetType {
    
    private var authToken: String {
        KeyChainStorage.shared.getAccessToken() ?? ""
    }
    
    var baseURL: URL {
        return URL(string: Constants.authURL)!
    }
    
    var path: String {
        switch self {
        case .login:
            return Constants.loginPath
        case .loginWithFacebook:
            return Constants.loginWithFbPath
        case .register:
            return Constants.registerPath
        case .changePassword:
            return Constants.changePasswordPath
        case .forgotPassword:
            return Constants.forgotPasswordPath
        }
    }
    
    var method: Method {
        switch self {
        case .forgotPassword:
            return .get
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        case .register(firstName: let firstName, lastName: let lastName, birthDay: let birthDay, userName: let userName, password: let password, matchingPassword: let mathingPassword, email: let email):
            
            return "{\"firstName\" : \"\(firstName)\", \"lastName\" : \"\(lastName)\", \"birthday\" : \"\(birthDay)\", \"username\" : \"\(userName)\", \"password\" : \"\(password)\", \"matchingPassword\" : \"\(mathingPassword)\", \"email\" : \"\(email)\"}".data(using: .utf8) ?? Data()
            
        case .login(let email, let password):
            return "{\"email\" : \"\(email)\", \"password\" : \"\(password)\"}".data(using: .utf8) ?? Data()
        case .loginWithFacebook(let fbToken):
            return "{\"fbAccessToken\" : \"\(fbToken)\"}".data(using: .utf8) ?? Data()
        case .changePassword(let oldPass, let newPass, let repeatPass):
            return "{\"oldPassword\" : \"\(oldPass)\", \"newPassword\" : \"\(newPass)\", \"matchingPassword\" : \"\(repeatPass)\"}".data(using: .utf8) ?? Data()
        case .forgotPassword:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .forgotPassword(let email):
            return .requestParameters(parameters: ["email":email], encoding: URLEncoding.default)
        default:
            return .requestData(sampleData)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .changePassword:
            return ["Authorization" : authToken,
                    "Content-Type" : "application/json"]
        default:
            return ["Content-type" : "application/json"]
        }
    }
    
}

