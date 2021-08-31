//
//  SectionModel.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 16.08.2021.
//

import Foundation

struct SectionModel<Title: Equatable, Item: Equatable> {
    let title: Title
    var items: [Item]
    
    init(title: Title, items: [Item]) {
        self.title = title
        self.items = items
    }
}

enum CreateChannelDataSource: Equatable {
    case name(String)
    case description(String)
    case privacy(ChannelPrivacyModel)
}

struct ChannelPrivacyModel {
    let title: String
    let description: String
    let privacy: ChannelPrivacy
    let mode: ChannelMode
}

// MARK: - Equatable 

extension ChannelPrivacyModel: Equatable {
    
    static func == (lhs: ChannelPrivacyModel, rhs: ChannelPrivacyModel) -> Bool {
        return lhs.privacy == rhs.privacy &&
               lhs.title == rhs.title
    }
}

extension SectionModel: Equatable where Title: Equatable {
    
    static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
        return lhs.title == rhs.title && lhs.items == rhs.items
    }
}
