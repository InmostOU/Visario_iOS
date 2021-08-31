//
//  UserProfileData.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 12.08.2021.
//

import Foundation

struct UpdateProfileDataModel: Codable {
    var firstName: String
    var lastName: String
    var username: String
    var birthday: Int
    var about: String
    var showEmailTo: Privacy
    var showPhoneNumberTo: Privacy
}
