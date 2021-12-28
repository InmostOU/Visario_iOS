//
//  AttendeeResponseModel.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 30.08.2021.
//

import Foundation

struct AttendeeResponseModel: Decodable {
    let externalUserId: String
    let attendeeId: String
    let joinToken: String
}
