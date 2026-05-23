//
//  ListDetailHeaderView.swift
//  TravelApp
//

import UIKit
import Kingfisher
import Hero

final class ListDetailHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "ListDetailHeaderView"

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Creator row
    private let creatorAvatarView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 18
        iv.backgroundColor = .tertiarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let creatorUsernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var creatorRow: UIStackView = {
        let textStack = UIStackView(arrangedSubviews: [creatorNameLabel, creatorUsernameLabel])
        textStack.axis = .vertical
        textStack.spacing = 1
        textStack.alignment = .leading

        let row = UIStackView(arrangedSubviews: [creatorAvatarView, textStack])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }()

    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupViews() {
        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(creatorRow)
        addSubview(descriptionLabel)
        addSubview(statsStack)

        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310),

            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            creatorRow.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            creatorRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            creatorRow.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),

            creatorAvatarView.widthAnchor.constraint(equalToConstant: 36),
            creatorAvatarView.heightAnchor.constraint(equalToConstant: 36),

            descriptionLabel.topAnchor.constraint(equalTo: creatorRow.bottomAnchor, constant: 14),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            statsStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 14),
            statsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    func configure(with list: TravelList) {
        titleLabel.text = list.title
        subtitleLabel.text = list.shortDescription
        subtitleLabel.isHidden = (list.shortDescription?.isEmpty ?? true)

        descriptionLabel.text = list.longDescription
        descriptionLabel.isHidden = (list.longDescription?.isEmpty ?? true)

        coverImageView.hero.id = "\(list.id)cover"
        if let url = URL(string: list.coverPhoto.medium) {
            coverImageView.kf.setImage(
                with: url,
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        }

        // Creator
        creatorNameLabel.text = list.creator.fullName
        creatorUsernameLabel.text = "@\(list.creator.username)"
        if let urlString = list.creator.profilePhoto, let url = URL(string: urlString) {
            creatorAvatarView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.circle.fill"),
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        } else {
            creatorAvatarView.image = UIImage(systemName: "person.circle.fill")
            creatorAvatarView.tintColor = .tertiaryLabel
        }

        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        statsStack.addArrangedSubview(makeStatView(icon: "mappin.circle.fill", value: list.stats.placeCount))
        statsStack.addArrangedSubview(makeStatView(icon: "eye.fill", value: list.stats.viewCount))
        statsStack.addArrangedSubview(makeStatView(icon: "bookmark.fill", value: list.stats.savedCount))
        statsStack.addArrangedSubview(makeStatView(icon: "bubble.left.fill", value: list.stats.commentCount))
    }

    private func makeStatView(icon: String, value: Int) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 5
        stack.alignment = .center

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .secondaryLabel
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = "\(value)"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        return stack
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        creatorAvatarView.kf.cancelDownloadTask()
        coverImageView.image = nil
        creatorAvatarView.image = nil
    }
}
