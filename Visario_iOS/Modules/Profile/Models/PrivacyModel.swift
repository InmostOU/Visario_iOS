//
//  PrivacyModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 12.08.2021.
//

import Foundation

enum Privacy: String, Codable {
    case everyone = "EVERYONE"
    case nobody = "NO_ONE"
    case contacts = "CONTACTS"
    
    init(rawValue: String) {
        switch rawValue {
        case "Everyone":
            self = .everyone
        case "Only me":
            self = .nobody
        case "Only contacts":
            self = .contacts
        default:
            self = .everyone
        }
    }
}

