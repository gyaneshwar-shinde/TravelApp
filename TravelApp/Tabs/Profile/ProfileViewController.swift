//
//  ProfileViewController.swift
//  TravelApp
//
//  Created by Laptop X on 23/05/26.
//

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Dummy Data

    private let profile = ProfileData(
        name: "Gyaneshwar Shinde",
        handle: "@gyaneshwar_shinde",
        bio: "iOS Mobile Engineer. Always chasing the next horizon. ✈️",
        avatarSymbol: "person.crop.circle.fill",
        stats: [
            .init(value: "24",  label: "Trips"),
            .init(value: "17",  label: "Countries"),
            .init(value: "138", label: "Saved")
        ],
        menuItems: [
            .init(icon: "bookmark.fill",            title: "Saved Places",    tint: .systemOrange),
            .init(icon: "map.fill",                 title: "Travel History",  tint: .systemBlue),
            .init(icon: "heart.fill",               title: "Wishlist",        tint: .systemPink),
            .init(icon: "person.2.fill",            title: "Travel Buddies",  tint: .systemPurple),
            .init(icon: "bell.fill",                title: "Notifications",   tint: .systemRed),
            .init(icon: "gearshape.fill",           title: "Settings",        tint: .systemGray),
            .init(icon: "questionmark.circle.fill", title: "Help & Support",  tint: .systemTeal)
        ]
    )

    // MARK: - Views

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 24
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 32, right: 20)
        return s
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(handleEditTap)
        )

        setupLayout()
        buildHeader()
        buildStats()
        buildMenu()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    // MARK: - Header

    private func buildHeader() {
        let avatar = UIImageView(image: UIImage(systemName: profile.avatarSymbol))
        avatar.tintColor = .tertiaryLabel
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.backgroundColor = .secondarySystemBackground
        avatar.layer.cornerRadius = 48
        avatar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 96),
            avatar.heightAnchor.constraint(equalToConstant: 96)
        ])

        let nameLabel = UILabel()
        nameLabel.text = profile.name
        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textAlignment = .center

        let handleLabel = UILabel()
        handleLabel.text = profile.handle
        handleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        handleLabel.textColor = .secondaryLabel
        handleLabel.textAlignment = .center

        let bioLabel = UILabel()
        bioLabel.text = profile.bio
        bioLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bioLabel.textColor = .label
        bioLabel.numberOfLines = 0
        bioLabel.textAlignment = .center

        let editButton = UIButton(configuration: {
            var c = UIButton.Configuration.tinted()
            c.title = "Edit Profile"
            c.cornerStyle = .capsule
            c.baseForegroundColor = .label
            c.baseBackgroundColor = .secondarySystemBackground
            c.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
            return c
        }())
        editButton.addTarget(self, action: #selector(handleEditTap), for: .touchUpInside)

        let headerStack = UIStackView(arrangedSubviews: [avatar, nameLabel, handleLabel, bioLabel, editButton])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 8
        headerStack.setCustomSpacing(16, after: avatar)
        headerStack.setCustomSpacing(12, after: bioLabel)

        contentStack.addArrangedSubview(headerStack)
    }

    // MARK: - Stats

    private func buildStats() {
        let statsRow = UIStackView()
        statsRow.axis = .horizontal
        statsRow.distribution = .fillEqually
        statsRow.backgroundColor = .secondarySystemBackground
        statsRow.layer.cornerRadius = 16
        statsRow.layer.cornerCurve = .continuous
        statsRow.isLayoutMarginsRelativeArrangement = true
        statsRow.layoutMargins = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)

        for stat in profile.stats {
            let valueLabel = UILabel()
            valueLabel.text = stat.value
            valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
            valueLabel.textAlignment = .center

            let labelLabel = UILabel()
            labelLabel.text = stat.label
            labelLabel.font = .systemFont(ofSize: 13, weight: .medium)
            labelLabel.textColor = .secondaryLabel
            labelLabel.textAlignment = .center

            let col = UIStackView(arrangedSubviews: [valueLabel, labelLabel])
            col.axis = .vertical
            col.alignment = .center
            col.spacing = 4

            statsRow.addArrangedSubview(col)
        }

        contentStack.addArrangedSubview(statsRow)
    }

    // MARK: - Menu

    private func buildMenu() {
        let menuContainer = UIStackView()
        menuContainer.axis = .vertical
        menuContainer.spacing = 0
        menuContainer.backgroundColor = .secondarySystemBackground
        menuContainer.layer.cornerRadius = 16
        menuContainer.layer.cornerCurve = .continuous
        menuContainer.clipsToBounds = true

        for (idx, item) in profile.menuItems.enumerated() {
            menuContainer.addArrangedSubview(makeMenuRow(item: item))

            if idx < profile.menuItems.count - 1 {
                menuContainer.addArrangedSubview(makeSeparator(insetLeading: 56))
            }
        }

        contentStack.addArrangedSubview(menuContainer)

        let signOutButton = UIButton(configuration: {
            var c = UIButton.Configuration.plain()
            c.title = "Sign Out"
            c.baseForegroundColor = .systemRed
            return c
        }())
        signOutButton.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        contentStack.addArrangedSubview(signOutButton)
    }

    private func makeMenuRow(item: MenuItem) -> UIControl {
        let row = MenuRowControl()
        row.translatesAutoresizingMaskIntoConstraints = false

        let iconBg = UIView()
        iconBg.backgroundColor = item.tint.withAlphaComponent(0.15)
        iconBg.layer.cornerRadius = 8
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: item.icon))
        icon.tintColor = item.tint
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(icon)

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(iconBg)
        row.addSubview(titleLabel)
        row.addSubview(chevron)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 52),

            iconBg.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            iconBg.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 28),
            iconBg.heightAnchor.constraint(equalToConstant: 28),

            icon.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 10),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])

        row.menuTitle = item.title
        row.addTarget(self, action: #selector(handleMenuTap(_:)), for: .touchUpInside)
        return row
    }

    private func makeSeparator(insetLeading: CGFloat) -> UIView {
        let wrap = UIView()
        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(line)
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: insetLeading),
            line.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
            line.topAnchor.constraint(equalTo: wrap.topAnchor),
            line.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        return wrap
    }

    // MARK: - Actions

    @objc private func handleEditTap() {
        print("Edit profile tapped")
    }

    @objc private func handleMenuTap(_ sender: MenuRowControl) {
        print("Tapped: \(sender.menuTitle ?? "")")
    }

    @objc private func handleSignOut() {
        print("Sign out tapped")
    }
}

// MARK: - Models

private struct ProfileData {
    let name: String
    let handle: String
    let bio: String
    let avatarSymbol: String
    let stats: [Stat]
    let menuItems: [MenuItem]
}

private struct Stat {
    let value: String
    let label: String
}

private struct MenuItem {
    let icon: String
    let title: String
    let tint: UIColor
}

// MARK: - MenuRowControl

private final class MenuRowControl: UIControl {
    var menuTitle: String?

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.backgroundColor = self.isHighlighted ? .tertiarySystemFill : .clear
            }
        }
    }
}
