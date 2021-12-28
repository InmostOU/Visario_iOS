//
//  ContactModel.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.08.2021.
//

import Foundation

struct ContactsActivityStatusDataWrapper: Decodable {
    let data: [ContactActivityModel]
}

struct ContactActivityModel: Decodable {
    let id: Int
    let userArn: String
    let status: String
    let lastSeen: Int
}

struct ContactDataWrapper: Decodable {
    let status: Int
    let message: String
    let data: [ContactModel]
}

struct ContactModel: Decodable {
    let id: Int
    let userArn: String
    var firstName: String
    var lastName: String
    let username: String
    let email: String
    let phoneNumber: String
    let image: String
    let about: String
    var online: Bool?
    let favorite: Bool
    let muted: Bool
    let inMyContacts: Bool
}

// MARK: - Mockable

extension ContactModel: Mockable {
    
    static func mock(count: Int) -> [ContactModel] {
        (0..<count).map { index in
            ContactModel(id: index,
                         userArn: "userArn must be there",
                         firstName: "Victor \(index)",
                         lastName: "Pavlov",
                         username: "userVictor",
                         email: "myMail@mail.ru",
                         phoneNumber: "777 777 77 77",
                         image: "...",
                         about: "....",
                         online: Bool.random(),
                         favorite: Bool.random(),
                         muted: Bool.random(),
                         inMyContacts: Bool.random())
        }
    }
}

// MARK: Equatable

extension ContactModel: Equatable {
    
}
