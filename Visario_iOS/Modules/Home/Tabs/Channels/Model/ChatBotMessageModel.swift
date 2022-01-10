//
//  ChatBotMessageModel.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 06.01.2022.
//

import Foundation

struct ChatBotMessageModel: Identifiable, Decodable {
    let message: String
    let lat: String
    let lng: String
    var id: String? = UUID().uuidString
}
