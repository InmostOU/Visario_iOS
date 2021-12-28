//
//  WebSocketResponse.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 30.08.2021.
//

import Foundation

struct WebSocketResponse: Decodable {
    let timestamp: Int
    let status: Int
    let error: String?
    let message: String
    let path: String
}
