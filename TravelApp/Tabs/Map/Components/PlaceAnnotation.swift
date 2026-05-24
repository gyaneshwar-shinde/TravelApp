//
//  PlaceAnnotation.swift
//  TravelApp
//

import MapKit

enum PlaceHighlight {
    case mostVisited
    case leastVisited
    case highlyRecommended
    case goodRating
    case none

    var displayText: String? {
        switch self {
        case .mostVisited:       return "Most Visited"
        case .leastVisited:      return "Least Visited"
        case .highlyRecommended: return "Highly Recommended"
        case .goodRating:        return "Average"
        case .none:              return nil
        }
    }

    /// Classifies a place relative to its peer collection.
    /// Priority: Most Visited → Highly Recommended → Least Visited → Good Rating → none.
    static func compute(for place: MapPlace, in collection: [MapPlace]) -> PlaceHighlight {
        let counts = collection.map { $0.reviewCount }
        let maxCount = counts.max() ?? 0
        let minCount = counts.min() ?? 0
        let hasSpread = maxCount > minCount

        if hasSpread, place.reviewCount == maxCount {
            return .mostVisited
        }
        if place.rating >= 4.7 && place.reviewCount >= 100 {
            return .highlyRecommended
        }
        if hasSpread, place.reviewCount == minCount {
            return .leastVisited
        }
        if place.rating >= 4.5 {
            return .goodRating
        }
        return .none
    }
}

final class PlaceAnnotation: NSObject, MKAnnotation {
    let place: MapPlace
    let index: Int
    let highlight: PlaceHighlight

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: place.coordinates.latitude,
            longitude: place.coordinates.longitude
        )
    }

    var title: String? { place.name }
    var subtitle: String? { place.primaryCategoryName }

    init(place: MapPlace, index: Int, highlight: PlaceHighlight = .none) {
        self.place = place
        self.index = index
        self.highlight = highlight
    }
}
