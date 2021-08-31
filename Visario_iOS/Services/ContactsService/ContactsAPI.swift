//
//  ContactsAPI.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.08.2021.
//

import Moya

enum ContactsAPI {
    case getAllContacts
    case deleteContact(id: Int)
    case addContact(username: String)
    case findContact(username: String)
    case updateProfile(firstName: String, lastName: String, username: String, birthday: Int, about: String, showEmailTo: String, showPhoneNumberTo: String)
    case getProfile
    case editContact(id: Int, firstName: String, lastName: String)
    case uploadUserPhoto(data: Data, description: String)
    case getUserPhotoUrl
}

// MARK: - TargetType

extension ContactsAPI: TargetType {
    
    private var boundary: String {
        return UUID().uuidString
    }
    
    private var token: String? {
        return KeyChainStorage.shared.getAccessToken()
    }
    
    var baseURL: URL {
        return URL(string: Constants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getAllContacts:
            return "/contact/getAllContacts"
        case .deleteContact:
            return "/contact/delete"
        case .addContact:
            return "/contact/add"
        case .findContact:
            return "/contact/findUserByUsername"
        case .updateProfile:
            return "/user/profile/update"
        case .getProfile:
            return "/user/profile"
        case .editContact:
            return "/contact/edit"
        case .uploadUserPhoto:
            return "/user/uploadUserPhoto"
        case .getUserPhotoUrl:
            return "/user/getUserAvatarUrl"
        }
    }
    
    var method: Method {
        switch self {
        case .addContact, .deleteContact, .getAllContacts, .updateProfile, .editContact, .uploadUserPhoto:
            return .post
        case .findContact, .getProfile, .getUserPhotoUrl:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getAllContacts, .findContact, .getProfile, .uploadUserPhoto, .getUserPhotoUrl:
            return Data()
        case .deleteContact(id: let id):
            return "{\"id\" : \(id)}".data(using: .utf8) ?? Data()
        case .addContact(username: let username):
            return "{\"username\" : \"\(username)\"}".data(using: .utf8) ?? Data()
        case .updateProfile(firstName: let firstName, lastName: let lastName, username: let username, birthday: let birthday, about: let about, showEmailTo: let showEmailTo, showPhoneNumberTo: let showPhoneNumberTo):
            return "{\"firstName\" : \"\(firstName)\", \"lastName\" : \"\(lastName)\", \"username\" : \"\(username)\", \"birthday\" : \"\(birthday)\", \"about\" : \"\(about)\", \"showEmailTo\" : \"\(showEmailTo)\", \"showPhoneNumberTo\" : \"\(showPhoneNumberTo)\"}".data(using: .utf8) ?? Data()
        case .editContact(id: let id, firstName: let firstName, lastName: let lastName):
            return "{\"id\" : \"\(id)\", \"firstName\" : \"\(firstName)\", \"lastName\" : \"\(lastName)\"}".data(using: .utf8) ?? Data()
        }
    }
    
    var task: Task {
        switch self {
        case .getAllContacts, .getProfile, .getUserPhotoUrl:
            return .requestPlain
        case .deleteContact, .addContact, .updateProfile, .editContact:
            return .requestData(sampleData)
        case .findContact(username: let username):
            return .requestParameters(parameters: ["username" : "\(username)"], encoding: URLEncoding.default)
        case .uploadUserPhoto(data: let data, description: let description):
            let imgData = MultipartFormData(provider: .data(data), name: "file", fileName: "userAvatar.png", mimeType: "image/png")
            let descriptionData = MultipartFormData(provider: .data(description.data(using: .utf8)!), name: "description")
            let multipartData = [imgData, descriptionData]
            
            return .uploadMultipart(multipartData)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .uploadUserPhoto:
            
            return [
                     "Authorization" : token ?? "",
                     "Content-Type" : "multipart/form-data; boundary=\(boundary)"
                   ]
        default:
            return [
                     "Authorization" : token ?? "",
                     "Content-Type" : "application/json"
                   ]
        }
    }
}
