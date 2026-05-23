//
//  PlaceAnnotation.swift
//  TravelApp
//
//  Created by Laptop X on 24/05/26.
//


//
//  PlaceAnnotation.swift
//  TravelApp
//

import MapKit

final class PlaceAnnotation: NSObject, MKAnnotation {
    let place: MapPlace
    let index: Int

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: place.coordinates.latitude,
            longitude: place.coordinates.longitude
        )
    }

    var title: String? { place.name }
    var subtitle: String? { place.primaryCategoryName }

    init(place: MapPlace, index: Int) {
        self.place = place
        self.index = index
    }
}
