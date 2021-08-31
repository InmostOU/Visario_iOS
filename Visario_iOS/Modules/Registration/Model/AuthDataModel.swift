//
//  AuthDataModel.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 03.08.2021.
//

import Foundation

struct AuthDataModel: Decodable {
    let timestamp: Int?
    let status: Int?
    let error: String?
    let message: String?
    let path: String?
    let accessToken: String?
    let refreshToken: String?
    let userProfile: ProfileModel?
}
