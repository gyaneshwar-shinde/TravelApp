//
//  PlaceMarkerView.swift
//  TravelApp
//
//  Created by Laptop X on 24/05/26.
//


//
//  PlaceMarkerView.swift
//  TravelApp
//

import MapKit

final class PlaceMarkerView: MKAnnotationView {
    static let reuseIdentifier = "PlaceMarkerView"

    private let defaultDiameter: CGFloat = 32
    private let selectedDiameter: CGFloat = 46

    private let circleView: UIView = {
        let v = UIView()
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 2
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.25
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 3
        v.isUserInteractionEnabled = false
        return v
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private var isMarkerHighlighted = false

    override var annotation: MKAnnotation? {
        didSet { configureForAnnotation() }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        canShowCallout = false
        frame = CGRect(x: 0, y: 0, width: selectedDiameter, height: selectedDiameter)
        addSubview(circleView)
        circleView.addSubview(iconImageView)
        configureForAnnotation()
        applyState(animated: false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        isMarkerHighlighted = false
        applyState(animated: false)
    }

    func setHighlighted(_ highlighted: Bool, animated: Bool = true) {
        guard isMarkerHighlighted != highlighted else { return }
        isMarkerHighlighted = highlighted
        if highlighted { superview?.bringSubviewToFront(self) }
        applyState(animated: animated)
    }

    private func configureForAnnotation() {
        iconImageView.image = categoryIcon()
        circleView.backgroundColor = categoryColor()
    }

    private func applyState(animated: Bool) {
        let diameter = isMarkerHighlighted ? selectedDiameter : defaultDiameter

        let block = {
            self.circleView.bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            self.circleView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            self.circleView.layer.cornerRadius = diameter / 2
            self.circleView.layer.borderWidth = self.isMarkerHighlighted ? 3 : 2
            self.iconImageView.frame = self.circleView.bounds.insetBy(
                dx: diameter * 0.26,
                dy: diameter * 0.26
            )
            self.iconImageView.tintColor = .white
        }

        if animated {
            UIView.animate(
                withDuration: 0.28,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.6,
                options: [.beginFromCurrentState],
                animations: block
            )
        } else {
            block()
        }
    }

    private func categoryColor() -> UIColor {
        let name = (annotation as? PlaceAnnotation)?.place.primaryCategoryName.lowercased() ?? ""
        switch name {
        case "culture":  return UIColor(red: 0.82, green: 0.45, blue: 0.20, alpha: 1)  // warm amber
        case "food":     return .systemOrange
        case "nature":   return .systemGreen
        case "shopping": return .systemPurple
        case "nightlife": return .systemIndigo
        default:         return .systemBlue
        }
    }

    private func categoryIcon() -> UIImage? {
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let name = (annotation as? PlaceAnnotation)?.place.primaryCategoryName.lowercased() ?? ""
        let symbol: String
        switch name {
        case "culture":  symbol = "building.columns.fill"
        case "food":     symbol = "fork.knife"
        case "nature":   symbol = "leaf.fill"
        case "shopping": symbol = "bag.fill"
        case "nightlife": symbol = "wineglass.fill"
        default:         symbol = "mappin"
        }
        return UIImage(systemName: symbol, withConfiguration: cfg)
    }
}