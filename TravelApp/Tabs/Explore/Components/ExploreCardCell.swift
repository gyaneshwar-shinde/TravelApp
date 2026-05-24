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

    private lazy var heartButton: UIButton = {
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 16
        b.layer.masksToBounds = true
        b.adjustsImageWhenHighlighted = false
        b.addTarget(self, action: #selector(handleHeartTap), for: .touchUpInside)
        return b
    }()

    private var list: TravelList?
    private var isWishlisted: Bool = false
    private var wishlistObserver: NSObjectProtocol?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        observeWishlistChanges()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    deinit {
        if let observer = wishlistObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Layout

    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(statsStack)
        contentView.addSubview(heartButton)   // overlay on top of imageView

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
            statsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8),

            heartButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            heartButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            heartButton.widthAnchor.constraint(equalToConstant: 32),
            heartButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    // MARK: - Configure

    func configure(with list: TravelList) {
        self.list = list
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

        isWishlisted = WishlistStore.shared.isWishlisted(id: list.id)
        updateHeartAppearance()
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

    // MARK: - Heart

    private func updateHeartAppearance() {
        let symbol = isWishlisted ? "heart.fill" : "heart"
        let image = UIImage(
            systemName: symbol,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        )
        heartButton.setImage(image, for: .normal)
        heartButton.tintColor = isWishlisted ? .systemPink : .white
    }

    @objc private func handleHeartTap() {
        guard let list = list else { return }
        let nowWishlisted = WishlistStore.shared.toggle(list)
        isWishlisted = nowWishlisted
        updateHeartAppearance()
        animateHeartPop(burst: nowWishlisted)
    }

    private func animateHeartPop(burst: Bool) {
        // Squash → overshoot → settle on the heart button itself.
        heartButton.transform = .identity
        UIView.animateKeyframes(withDuration: 0.55, delay: 0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0,    relativeDuration: 0.18) {
                self.heartButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.18, relativeDuration: 0.42) {
                self.heartButton.transform = CGAffineTransform(scaleX: 1.28, y: 1.28)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.60, relativeDuration: 0.40) {
                self.heartButton.transform = .identity
            }
        }

        guard burst else { return }

        // Burst overlay: a copy of the heart on contentView (not inside the button,
        // which is masksToBounds). It scales up and fades out.
        let burstImage = UIImageView(image: UIImage(
            systemName: "heart.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        ))
        burstImage.tintColor = .systemPink
        burstImage.contentMode = .scaleAspectFit
        burstImage.isUserInteractionEnabled = false
        burstImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(burstImage)
        NSLayoutConstraint.activate([
            burstImage.centerXAnchor.constraint(equalTo: heartButton.centerXAnchor),
            burstImage.centerYAnchor.constraint(equalTo: heartButton.centerYAnchor),
            burstImage.widthAnchor.constraint(equalToConstant: 22),
            burstImage.heightAnchor.constraint(equalToConstant: 22)
        ])
        contentView.layoutIfNeeded()

        UIView.animate(
            withDuration: 0.65,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                burstImage.transform = CGAffineTransform(scaleX: 2.6, y: 2.6)
                burstImage.alpha = 0
            },
            completion: { _ in burstImage.removeFromSuperview() }
        )
    }

    private func observeWishlistChanges() {
        wishlistObserver = NotificationCenter.default.addObserver(
            forName: .wishlistDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, let list = self.list else { return }
            let newState = WishlistStore.shared.isWishlisted(id: list.id)
            guard newState != self.isWishlisted else { return }
            self.isWishlisted = newState
            self.updateHeartAppearance()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
        list = nil
        heartButton.transform = .identity
    }
}
