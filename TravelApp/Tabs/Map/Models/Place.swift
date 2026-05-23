//
//  Place.swift
//  TravelApp
//
//  Created by Laptop X on 24/05/26.
//


//
//  Place.swift
//  TravelApp
//

import Foundation

struct MapPlace: Decodable {
    let placeId: String
    let name: String
    let description: String
    let rating: Double
    let reviewCount: Int
    let coordinates: Coordinates
    let coverMedia: CoverMedia
    let openHoursText: String
    let categories: [Category]

    var primaryCategoryName: String {
        categories.first(where: { $0.isPrimary == 1 })?.name
            ?? categories.first?.name
            ?? ""
    }

    struct Coordinates: Decodable {
        let latitude: Double
        let longitude: Double
    }

    struct CoverMedia: Decodable {
        let small: String
        let medium: String
        let large: String
    }

    struct Category: Decodable {
        let name: String
        let isPrimary: Int

        enum CodingKeys: String, CodingKey {
            case name
            case isPrimary = "is_primary"
        }
    }

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name, description, rating, coordinates, categories
        case reviewCount = "review_count"
        case coverMedia = "cover_media"
        case openHoursText = "open_hours_text"
    }

    static func loadFromBundle(filename: String = "places") -> [MapPlace] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            assertionFailure("\(filename).json not found in bundle")
            return []
        }
        do {
            return try JSONDecoder().decode([MapPlace].self, from: data)
        } catch {
            assertionFailure("Failed to decode \(filename).json: \(error)")
            return []
        }
    }
}
