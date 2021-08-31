//
//  Mockable.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 09.08.2021.
//

import Foundation

protocol Mockable {
    associatedtype ItemType
    static func mock(count: Int) -> [ItemType]
}
