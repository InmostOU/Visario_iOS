//
//  ProfileModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 12.08.2021.
//

import Foundation

struct ProfileModel: Decodable {
    let id: Int
    let userArn: String
    var firstName: String
    var lastName: String
    let username: String
    let birthday: Int
    let email: String
    let phoneNumber: String
    let image: String
    let about: String
    let showEmailTo: Privacy
    let showPhoneNumberTo: Privacy
    var password: String?
    var channels: [String]?
    
    func asContactModel() -> ContactModel {
        let contactModel = ContactModel(id: id, userArn: userArn, firstName: firstName, lastName: lastName, username: username, email: email, phoneNumber: phoneNumber, image: image, about: about, online: true, favorite: false, muted: false, inMyContacts: false)
        return contactModel
    }
}
