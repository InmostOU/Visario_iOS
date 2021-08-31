//
//  KeyChainStorage.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 05.08.2021.
//

import Foundation

/// Storage for secure items

final class KeyChainStorage {

    static let shared = KeyChainStorage()
    
    private let userDefaults = UserDefaults.standard
    
    /// Note: add new keys for new secure items
    private struct Key {
        static let token: String = "accessToken"
        static let userProfile: String = "userProfile"
    }
    
    private init() { }

    private func isValueExist(for key: String) -> Bool {
        userDefaults.value(forKey: key) != nil ? true : false
    }
    
    // read
    func getAccessToken() -> String? {
        userDefaults.string(forKey: Key.token)
    }
    
    func getProfile() -> ProfileModel? {
        guard let userInfo = userDefaults.dictionary(forKey: Key.userProfile) else { return nil }
        
        let profile = ProfileModel(
            id: userInfo["id"] as? Int ?? 0,
            userArn: userInfo["userArn"] as? String ?? "",
            firstName: userInfo["firstName"] as? String ?? "",
            lastName: userInfo["lastName"] as? String ?? "",
            username: userInfo["username"] as? String ?? "",
            birthday: userInfo["birthday"] as? Int ?? 0,
            email: userInfo["email"] as? String ?? "",
            phoneNumber: userInfo["phoneNumber"] as? String ?? "",
            image: userInfo["image"] as? String ?? "",
            about: userInfo["about"] as? String ?? "",
            showEmailTo: userInfo["showEmailTo"] as? Privacy ?? .contacts,
            showPhoneNumberTo: userInfo["showPhoneNumberTo"] as? Privacy ?? .contacts
        )
        return profile
    }
    
    // write
    func saveAccessToken(token: String) {
        userDefaults.set(token, forKey: Key.token)
    }
    
    func saveProfile(profile: ProfileModel) {
        var userInfo: [String: Any] = [:]
        
        userInfo["id"] = profile.id
        userInfo["userArn"] = profile.userArn
        userInfo["firstName"] = profile.firstName
        userInfo["lastName"] = profile.lastName
        userInfo["username"] = profile.username
        userInfo["birthday"] = profile.birthday
        userInfo["email"] = profile.email
        userInfo["phoneNumber"] = profile.phoneNumber
        userInfo["image"] = profile.image
        userInfo["about"] = profile.about
        userInfo["showEmailTo"] = profile.showEmailTo.rawValue
        userInfo["showPhoneNumberTo"] = profile.showPhoneNumberTo.rawValue
        
        userDefaults.setValue(userInfo, forKey: Key.userProfile)
    }
   
    // delete
    func deleteAccessToken() {
        userDefaults.removeObject(forKey: Key.token)
    }
}
