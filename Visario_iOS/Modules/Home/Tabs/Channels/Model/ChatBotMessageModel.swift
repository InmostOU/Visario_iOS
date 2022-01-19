//
//  ChatBotMessageModel.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 06.01.2022.
//

import Foundation

struct ChatBotMessageModel: Identifiable, Decodable {
    let message: String?
    let lat: String?
    let lng: String?
    var id: String? = UUID().uuidString
    
    let results: [Place]
    
    init(message: String) {
        self.message = message
        self.lat = nil
        self.lng = nil
        self.results = []
    }
    
    init(message: String, lat: String?, lng: String?) {
        self.message = message
        self.lat = lat
        self.lng = lng
        self.results = []
    }
}

// MARK: - Result
struct Place: Codable {
    let formattedAddress: String?
    let geometry: Geometry
    let name: String
    let icon: String
    let placeId: String /// String must bee
    let scope: Scope
    let rating: Double
    let types: [String]
    let openingHours: OpeningHours?
    let photos: [Photo]?
    let vicinity: String
    let permanentlyClosed: Bool
    let userRatingsTotal: Int
    let businessStatus: BusinessStatus
}

enum BusinessStatus: String, Codable {
    case operational = "OPERATIONAL"
}

// MARK: - Geometry
struct Geometry: Codable {
    //let bounds: JSONNull?
    let location: Location
    //let locationType: JSONNull?
    let viewport: Viewport
}

// MARK: - Location
struct Location: Codable {
    let lat, lng: Double
}

// MARK: - Viewport
struct Viewport: Codable {
    let northeast, southwest: Location
}

// MARK: - OpeningHours
struct OpeningHours: Codable {
    let openNow: Bool
    //let periods, weekdayText, permanentlyClosed: JSONNull?
}

// MARK: - Photo
struct Photo: Codable {
    let photoReference: String
    let height, width: Int
    let htmlAttributions: [String]
}

enum Scope: String, Codable {
    case google = "GOOGLE"
}
