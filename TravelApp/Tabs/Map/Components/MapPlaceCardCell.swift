//
//  PlaceCardCell.swift
//  TravelApp
//
//  Created by Laptop X on 24/05/26.
//


//
//  PlaceCardCell.swift
//  TravelApp
//

import UIKit

final class MapPlaceCardCell: UICollectionViewCell {
    static let reuseIdentifier = "MapPlaceCardCell"

    // MARK: - Subviews

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let categoryBadge: PaddingLabel = {
        let l = PaddingLabel()
        l.font = .systemFont(ofSize: 10, weight: .bold)
        l.textColor = .white
        l.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        l.layer.cornerRadius = 8
        l.layer.masksToBounds = true
        l.textInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let ratingStar: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "star.fill")
        iv.tintColor = .systemYellow
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()

    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let hoursLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = .tertiaryLabel
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var imageTask: URLSessionDataTask?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        imageView.image = nil
        nameLabel.text = nil
        ratingLabel.text = nil
        descriptionLabel.text = nil
        hoursLabel.text = nil
        categoryBadge.text = nil
    }

    // MARK: - Layout

    private func setupViews() {
        contentView.backgroundColor = .clear

        // Shadow lives on contentView (no masksToBounds), corner-clipped content lives on cardView.
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.10
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false

        contentView.addSubview(cardView)
        cardView.addSubview(imageView)
        cardView.addSubview(categoryBadge)
        cardView.addSubview(nameLabel)
        cardView.addSubview(ratingStar)
        cardView.addSubview(ratingLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(hoursLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 110),

            categoryBadge.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            categoryBadge.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: ratingStar.leadingAnchor, constant: -8),

            ratingStar.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            ratingStar.trailingAnchor.constraint(equalTo: ratingLabel.leadingAnchor, constant: -3),
            ratingStar.widthAnchor.constraint(equalToConstant: 11),
            ratingStar.heightAnchor.constraint(equalToConstant: 11),

            ratingLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            hoursLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            hoursLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            hoursLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            hoursLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -10),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Shadow path for perf
        contentView.layer.shadowPath = UIBezierPath(
            roundedRect: contentView.bounds,
            cornerRadius: 16
        ).cgPath
    }

    // MARK: - Configure

    func configure(with place: MapPlace) {
        nameLabel.text = place.name
        ratingLabel.text = String(format: "%.1f (%d)", place.rating, place.reviewCount)
        categoryBadge.text = place.primaryCategoryName.uppercased()
        descriptionLabel.text = place.description
        hoursLabel.text = place.openHoursText

        imageTask?.cancel()
        imageTask = ImageLoader.shared.loadImage(from: place.coverMedia.medium) { [weak self] image in
            self?.imageView.image = image
        }
    }
}

// MARK: - PaddingLabel

final class PaddingLabel: UILabel {
    var textInsets: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}
