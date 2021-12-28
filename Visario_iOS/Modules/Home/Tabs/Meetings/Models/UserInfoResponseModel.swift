//
//  UserInfoResponseModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 15.09.2021.
//

import Foundation

struct UserInfoResponseModel: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let image: String
    var attendeeId: String?
    var isMuted: Bool?
}
