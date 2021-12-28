//
//  ErrorResponse.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 13.09.2021.
//

import Foundation

enum ErrorStatus: String, Decodable {
    case forbidden = "FORBIDDEN"
    
    enum CodingKeys: String, CodingKey {
        case forbidden = "FORBIDDEN"
    }
}

struct ErrorResponse: Decodable {
    let error: ErrorStatus
    let message: String
    let path: String
    let status: Int
    //let timestamp: Int
}
