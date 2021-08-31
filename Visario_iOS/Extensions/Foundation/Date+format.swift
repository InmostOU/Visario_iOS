//
//  Date+format.swift
//  Visario_iOS
//
//  Created by Butsan Vitaliy on 17.08.2021.
//

import Foundation

enum DateFormat: String {
    case ddMMYYYY = "dd.MM.YYYY"
}

extension DateFormatter {

    static private let formatter = DateFormatter()

    static func formatDate(_ date: Date, dateFormat: DateFormat) -> String {
        formatter.dateFormat = dateFormat.rawValue
        return formatter.string(from: date)
    }

    static func formatString(_ string: String, dateFormat: DateFormat) -> Date {
        formatter.dateFormat = dateFormat.rawValue
        return formatter.date(from: string) ?? Date()
    }

}

extension String {

    func format(dateFormat: DateFormat) -> Date {
        return DateFormatter.formatString(self, dateFormat: dateFormat)
    }

}

extension Date {

    func format(dateFormat: DateFormat) -> String {
        return DateFormatter.formatDate(self, dateFormat: dateFormat)
    }

}

