//
//  UserActivityModel.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 11.10.2021.
//

import Foundation

enum ActivityAction: String, Decodable {
    case update = "UPDATE"
}

struct UserActivityModel: Decodable {
    let table: String
    let action: ActivityAction
    let data: ActivityData
    
    struct ActivityData: Decodable {
        let id: Int
        let userArn: String
        let status: String
        let lastSeen: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case userArn = "user_arn"
            case status
            case lastSeen = "last_seen"
        }
    }
}
