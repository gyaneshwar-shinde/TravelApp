//
//  WishlistRowCell.swift
//  TravelApp
//
//  Created by Laptop X on 24/05/26.
//


//
//  WishlistRowCell.swift
//  TravelApp
//

import UIKit
import Kingfisher

final class WishlistRowCell: UICollectionViewCell {
    static let reuseIdentifier = "WishlistRowCell"

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 14
        v.layer.cornerCurve = .continuous
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.layer.cornerCurve = .continuous
        iv.backgroundColor = .tertiarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 10
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private lazy var heartButton: UIButton = {
        let b = UIButton(type: .custom)
        b.tintColor = .systemPink
        b.setImage(UIImage(
            systemName: "heart.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        ), for: .normal)
        b.adjustsImageWhenHighlighted = false
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleRemoveTap), for: .touchUpInside)
        return b
    }()

    private var list: TravelList?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews() {
        contentView.addSubview(cardView)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, statsStack])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.setCustomSpacing(6, after: descriptionLabel)

        cardView.addSubview(coverImageView)
        cardView.addSubview(textStack)
        cardView.addSubview(heartButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            coverImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            coverImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            coverImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            coverImageView.widthAnchor.constraint(equalTo: coverImageView.heightAnchor),

            textStack.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: heartButton.leadingAnchor, constant: -8),
            textStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            heartButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            heartButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 32),
            heartButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func configure(with list: TravelList) {
        self.list = list
        titleLabel.text = list.title
        let desc = list.shortDescription ?? ""
        descriptionLabel.text = desc
        descriptionLabel.isHidden = desc.isEmpty

        if let url = URL(string: list.coverPhoto.medium) {
            coverImageView.kf.setImage(
                with: url,
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        }

        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        statsStack.addArrangedSubview(makeStatView(icon: "mappin.circle.fill", value: list.stats.placeCount))
        statsStack.addArrangedSubview(makeStatView(icon: "eye.fill", value: list.stats.viewCount))
    }

    private func makeStatView(icon: String, value: Int) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3
        stack.alignment = .center

        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = .secondaryLabel
        iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        iv.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = "\(value)"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel

        stack.addArrangedSubview(iv)
        stack.addArrangedSubview(label)
        return stack
    }

    @objc private func handleRemoveTap() {
        guard let list = list else { return }
        // Quick pop, then remove. The notification triggers WishlistVC reload.
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.heartButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.heartButton.transform = .identity
            }
        } completion: { _ in
            WishlistStore.shared.toggle(list)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        coverImageView.image = nil
        list = nil
        heartButton.transform = .identity
    }
}