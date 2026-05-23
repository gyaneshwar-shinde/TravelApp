//
//  ExploreCardCell.swift
//  TravelApp
//
//  Created by Laptop X on 23/05/26.
//

import UIKit
import Kingfisher
import Hero

final class ExploreCardCell: UICollectionViewCell {
    static let reuseIdentifier = "ExploreCardCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .secondarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(statsStack)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalToConstant: 140),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            statsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            statsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            statsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    func configure(with list: TravelList) {
        titleLabel.text = list.title
        imageView.hero.id = "\(list.id)cover"
        if let url = URL(string: list.coverPhoto.medium) {
            imageView.kf.setImage(
                with: url,
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        }

        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        statsStack.addArrangedSubview(makeStatView(icon: "mappin.circle.fill", value: list.stats.placeCount))
        statsStack.addArrangedSubview(makeStatView(icon: "eye.fill", value: list.stats.viewCount))
        statsStack.addArrangedSubview(makeStatView(icon: "bookmark.fill", value: list.stats.savedCount))
    }

    private func makeStatView(icon: String, value: Int) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3
        stack.alignment = .center

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = "\(value)"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        return stack
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
    }
}
