//
//  TravelList.swift
//  TravelApp
//

import Foundation

struct TravelList: Decodable {
    let id: String
    let title: String
    let shortDescription: String?
    let longDescription: String?
    let coverPhoto: CoverPhoto
    let stats: ListStats
    let places: [Place]
    let creator: Creator

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case shortDescription = "short_description"
        case longDescription = "long_description"
        case coverPhoto = "cover_photo"
        case stats
        case places
        case creator
    }
}

struct Creator: Decodable {
    let userId: String
    let username: String
    let firstName: String
    let lastName: String
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePhoto = "profile_photo"
    }

    var fullName: String { "\(firstName) \(lastName)" }
}

struct CoverPhoto: Decodable {
    let small: String
    let medium: String
    let large: String
}

struct ListStats: Decodable {
    let viewCount: Int
    let placeCount: Int
    let savedCount: Int
    let commentCount: Int
    let shareCount: Int

    enum CodingKeys: String, CodingKey {
        case viewCount = "view_count"
        case placeCount = "place_count"
        case savedCount = "saved_count"
        case commentCount = "comment_count"
        case shareCount = "share_count"
    }
}

struct Place: Decodable {
    let placeId: String
    let name: String
    let description: String?
    let rating: Double?
    let reviewCount: Int?
    let categories: [PlaceCategory]
    let coverMedia: CoverPhoto?

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case description
        case rating
        case reviewCount = "review_count"
        case categories
        case coverMedia = "cover_media"
    }

    var primaryCategoryName: String? {
        categories.first(where: { $0.isPrimary == 1 })?.name ?? categories.first?.name
    }
}

struct PlaceCategory: Decodable {
    let name: String
    let isPrimary: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case isPrimary = "is_primary"
    }
}
