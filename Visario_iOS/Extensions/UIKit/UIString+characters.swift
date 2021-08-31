//
//  UIString+characters.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 17.08.2021.
//

import Foundation

extension String {
    
    func isEmptyOrWhitespace() -> Bool {
        if self.isEmpty  {
            return true
        }
        return (self.trimmingCharacters(in: .whitespacesAndNewlines) == "")
    }
}
