//
//  PlaceMarkerView.swift
//  TravelApp
//
//  Created by Laptop X on 24/05/26.
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

    // Side pill containing: name (top), rating (middle), highlight tag (bottom, very light).
    private let pillView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.72)
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        v.isUserInteractionEnabled = false
        v.alpha = 0
        return v
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.82)
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private let highlightLabel: UILabel = {
        let l = UILabel()
        l.font = .italicSystemFont(ofSize: 9.5)
        l.textColor = UIColor.white.withAlphaComponent(0.55)  // very light
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private var isMarkerHighlighted = false

    override var annotation: MKAnnotation? {
        didSet { configureForAnnotation() }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        canShowCallout = false
        clipsToBounds = false
        frame = CGRect(x: 0, y: 0, width: selectedDiameter, height: selectedDiameter)
        addSubview(circleView)
        addSubview(pillView)
        pillView.addSubview(nameLabel)
        pillView.addSubview(ratingLabel)
        pillView.addSubview(highlightLabel)
        circleView.addSubview(iconImageView)
        configureForAnnotation()
        applyState(animated: false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        isMarkerHighlighted = false
        pillView.alpha = 0
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

        guard let placeAnnotation = annotation as? PlaceAnnotation else {
            nameLabel.text = nil
            ratingLabel.text = nil
            highlightLabel.text = nil
            layoutPill()
            return
        }
        let place = placeAnnotation.place
        nameLabel.text = place.name
        ratingLabel.attributedText = formatRating(rating: place.rating, count: place.reviewCount)
        highlightLabel.text = placeAnnotation.highlight.displayText
        layoutPill()
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

            self.pillView.alpha = self.isMarkerHighlighted ? 1 : 0
            self.layoutPill()
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

    private func layoutPill() {
        let maxTextWidth: CGFloat = 180
        let horizontalPadding: CGFloat = 10
        let verticalPadding: CGFloat = 6
        let lineSpacing: CGFloat = 2

        let nameSize = sizeFor(nameLabel, maxWidth: maxTextWidth)
        let ratingSize = sizeFor(ratingLabel, maxWidth: maxTextWidth)
        let highlightSize = sizeFor(highlightLabel, maxWidth: maxTextWidth)

        let visibleSizes = [nameSize, ratingSize, highlightSize].filter { $0.height > 0 }
        guard !visibleSizes.isEmpty else {
            pillView.frame = .zero
            return
        }

        let contentWidth = visibleSizes.map(\.width).max() ?? 0
        let contentHeight = visibleSizes.map(\.height).reduce(0, +)
            + CGFloat(visibleSizes.count - 1) * lineSpacing
        let pillWidth = ceil(contentWidth + horizontalPadding * 2)
        let pillHeight = ceil(contentHeight + verticalPadding * 2)

        let circleRadius = (isMarkerHighlighted ? selectedDiameter : defaultDiameter) / 2
        let gap: CGFloat = 6
        pillView.frame = CGRect(
            x: bounds.midX + circleRadius + gap,
            y: bounds.midY - pillHeight / 2,
            width: pillWidth,
            height: pillHeight
        )

        // Stack labels vertically inside the pill (pill's local coordinate space).
        var currentY: CGFloat = verticalPadding
        placeLabel(nameLabel, size: nameSize, x: horizontalPadding,
                   y: &currentY, contentWidth: contentWidth, spacing: lineSpacing)
        placeLabel(ratingLabel, size: ratingSize, x: horizontalPadding,
                   y: &currentY, contentWidth: contentWidth, spacing: lineSpacing)
        placeLabel(highlightLabel, size: highlightSize, x: horizontalPadding,
                   y: &currentY, contentWidth: contentWidth, spacing: lineSpacing)
    }

    private func placeLabel(_ label: UILabel,
                            size: CGSize,
                            x: CGFloat,
                            y: inout CGFloat,
                            contentWidth: CGFloat,
                            spacing: CGFloat) {
        guard size.height > 0 else {
            label.frame = .zero
            return
        }
        label.frame = CGRect(x: x, y: y, width: contentWidth, height: size.height)
        y += size.height + spacing
    }

    private func sizeFor(_ label: UILabel, maxWidth: CGFloat) -> CGSize {
        guard let text = label.text, !text.isEmpty else { return .zero }
        let fitted = label.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: min(ceil(fitted.width), maxWidth), height: ceil(fitted.height))
    }

    private func formatRating(rating: Double, count: Int) -> NSAttributedString {
        let countText: String
        if count >= 1000 {
            countText = String(format: "%.1fk reviews", Double(count) / 1000.0)
        } else {
            countText = "\(count) reviews"
        }
        let result = NSMutableAttributedString(
            string: "★ ",
            attributes: [.foregroundColor: UIColor.systemYellow]
        )
        result.append(NSAttributedString(
            string: "\(String(format: "%.1f", rating)) · \(countText)",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.82)]
        ))
        return result
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
