//
//  MapViewController.swift
//  TravelApp
//
//  Created by Laptop X on 23/05/26.
//

import UIKit
import MapKit

final class MapViewController: UIViewController {

    // MARK: - UI

    private let mapView = MKMapView()
    private let layout = CenteredCardLayout()
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(MapPlaceCardCell.self, forCellWithReuseIdentifier: MapPlaceCardCell.reuseIdentifier)
        return cv
    }()

    private let haptic = UISelectionFeedbackGenerator()

    // MARK: - State

    private var places: [MapPlace] = []
    private var annotations: [PlaceAnnotation] = []
    private var currentIndex: Int = -1

    /// True when we initiated a scrollToItem and want to suppress the resulting end callback.
    private var isProgrammaticScroll = false
    private var didPerformInitialFocus = false

    // MARK: - Layout constants

    private let cardHeight: CGFloat = 200
    private let cardHorizontalMargin: CGFloat = 40   // peek on each side
    private var cardWidth: CGFloat { view.bounds.width - cardHorizontalMargin * 2 }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupMapView()
        setupCollectionView()
        loadPlaces()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width = cardWidth
        if layout.itemSize.width != width || layout.itemSize.height != cardHeight {
            layout.itemSize = CGSize(width: width, height: cardHeight)
        }
        let horizontalInset = (view.bounds.width - width) / 2
        let inset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        if collectionView.contentInset != inset {
            collectionView.contentInset = inset
        }

        if !didPerformInitialFocus, !places.isEmpty, view.bounds.width > 0 {
            didPerformInitialFocus = true
            selectPlace(at: 0, source: .initial)
        }
    }

    // MARK: - Setup

    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.showsCompass = true
        mapView.pointOfInterestFilter = .excludingAll
        mapView.register(
            PlaceMarkerView.self,
            forAnnotationViewWithReuseIdentifier: PlaceMarkerView.reuseIdentifier
        )
        // Push Apple's logo / legal label above the card strip.
        mapView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: cardHeight + 24, right: 0)

        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalToConstant: cardHeight)
        ])
    }

    private func loadPlaces() {
        places = MapPlace.loadFromBundle()
        annotations = places.enumerated().map { idx, place in
            PlaceAnnotation(
                place: place,
                index: idx,
                highlight: PlaceHighlight.compute(for: place, in: places)
            )
        }
        mapView.addAnnotations(annotations)
        collectionView.reloadData()
    }

    // MARK: - Selection

    private enum SelectionSource {
        case mapTap          // user tapped a marker
        case collectionScroll // user swiped the card carousel
        case initial          // initial focus on viewDidLayoutSubviews
        case cardTap          // user tapped a card directly
    }

    private func selectPlace(at index: Int, source: SelectionSource) {
        guard places.indices.contains(index) else { return }
        guard index != currentIndex else {
            // Still ensure carousel is centered if the call came from a map tap on the already-selected place.
            if source == .mapTap || source == .cardTap {
                scrollCarousel(to: index, animated: true)
            }
            return
        }

        let previous = currentIndex
        currentIndex = index

        // Highlight markers.
        if previous >= 0, annotations.indices.contains(previous),
           let prevView = mapView.view(for: annotations[previous]) as? PlaceMarkerView {
            prevView.setHighlighted(false)
        }
        if let newView = mapView.view(for: annotations[index]) as? PlaceMarkerView {
            newView.setHighlighted(true)
        }

        // Move the camera, with a small southward bias so the marker sits above the card strip.
        focusMap(on: annotations[index].coordinate, animated: source != .initial)

        // Sync carousel (unless the change came from the carousel itself).
        if source != .collectionScroll {
            scrollCarousel(to: index, animated: source != .initial)
        }

        if source == .collectionScroll {
            haptic.selectionChanged()
        }
    }

    private func scrollCarousel(to index: Int, animated: Bool) {
        isProgrammaticScroll = true
        collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: animated
        )
        if !animated {
            // No animation = no didEndScrollingAnimation callback. Reset flag now.
            DispatchQueue.main.async { self.isProgrammaticScroll = false }
        }
    }

    private func focusMap(on coordinate: CLLocationCoordinate2D, animated: Bool) {
        let span = MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
        // Bias camera south so the marker appears in the upper portion of the visible map.
        let cardBias = 0.22
        let biasedCenter = CLLocationCoordinate2D(
            latitude: coordinate.latitude - span.latitudeDelta * cardBias,
            longitude: coordinate.longitude
        )
        mapView.setRegion(MKCoordinateRegion(center: biasedCenter, span: span), animated: animated)
    }

    private func centeredCardIndex() -> Int? {
        let center = CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)
        if let ip = collectionView.indexPathForItem(at: center) {
            return ip.item
        }
        // Fallback: nearest visible cell by horizontal distance.
        let visible = collectionView.indexPathsForVisibleItems
        guard !visible.isEmpty else { return nil }
        var bestIdx: Int?
        var bestDist: CGFloat = .greatestFiniteMagnitude
        for ip in visible {
            guard let attr = collectionView.layoutAttributesForItem(at: ip) else { continue }
            let dist = abs(attr.center.x - center.x)
            if dist < bestDist { bestDist = dist; bestIdx = ip.item }
        }
        return bestIdx
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let placeAnnotation = annotation as? PlaceAnnotation else { return nil }
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: PlaceMarkerView.reuseIdentifier,
            for: placeAnnotation
        )
        if let marker = view as? PlaceMarkerView {
            marker.setHighlighted(placeAnnotation.index == currentIndex, animated: false)
        }
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }
        // Deselect immediately so the same marker can be re-tapped.
        mapView.deselectAnnotation(placeAnnotation, animated: false)
        selectPlace(at: placeAnnotation.index, source: .mapTap)
    }
}

// MARK: - UICollectionViewDataSource

extension MapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        places.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MapPlaceCardCell.reuseIdentifier,
            for: indexPath
        ) as! MapPlaceCardCell
        cell.configure(with: places[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        selectPlace(at: indexPath.item, source: .cardTap)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isProgrammaticScroll {
            isProgrammaticScroll = false
            return
        }
        if let idx = centeredCardIndex() {
            selectPlace(at: idx, source: .collectionScroll)
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if isProgrammaticScroll {
            isProgrammaticScroll = false
        }
    }
}
