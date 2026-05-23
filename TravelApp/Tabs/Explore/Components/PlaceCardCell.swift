//
//  PlaceCardCell.swift
//  TravelApp
//
//  Created by Laptop X on 23/05/26.
//

import UIKit
import Kingfisher

final class PlaceCardCell: UICollectionViewCell {
    static let reuseIdentifier = "PlaceCardCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let placeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.layer.cornerCurve = .continuous
        iv.backgroundColor = .tertiarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ratingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let starIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = .systemOrange
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()

    private let reviewCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews() {
        contentView.addSubview(cardView)

        let textStack = UIStackView(arrangedSubviews: [categoryLabel, nameLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false

        ratingStack.addArrangedSubview(starIcon)
        ratingStack.addArrangedSubview(ratingLabel)
        ratingStack.addArrangedSubview(reviewCountLabel)

        cardView.addSubview(placeImageView)
        cardView.addSubview(textStack)
        cardView.addSubview(ratingStack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            placeImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            placeImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            placeImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            placeImageView.widthAnchor.constraint(equalTo: placeImageView.heightAnchor),

            textStack.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            textStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),

            ratingStack.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 12),
            ratingStack.topAnchor.constraint(greaterThanOrEqualTo: textStack.bottomAnchor, constant: 6)
        ])
    }

    func configure(with place: Place) {
        nameLabel.text = place.name
        categoryLabel.text = place.primaryCategoryName?.uppercased()
        descriptionLabel.text = place.description

        if let rating = place.rating {
            ratingLabel.text = String(format: "%.1f", rating)
        } else {
            ratingLabel.text = "—"
        }

        if let count = place.reviewCount {
            reviewCountLabel.text = "(\(count))"
        } else {
            reviewCountLabel.text = nil
        }

        if let urlString = place.coverMedia?.small, let url = URL(string: urlString) {
            placeImageView.kf.setImage(
                with: url,
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        } else {
            placeImageView.image = nil
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        placeImageView.kf.cancelDownloadTask()
        placeImageView.image = nil
    }
}
