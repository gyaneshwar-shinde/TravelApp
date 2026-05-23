//
//  ExploreViewController.swift
//  TravelApp
//
//  Created by Laptop X on 23/05/26.
//

import UIKit

final class ExploreViewController: UIViewController {

    private var lists: [TravelList] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2, height: 220)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(ExploreCardCell.self, forCellWithReuseIdentifier: ExploreCardCell.reuseIdentifier)
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Explore"

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        loadLists()
    }

    private func loadLists() {
        guard let url = Bundle.main.url(forResource: "lists", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ explore_lists.json not found in bundle")
            return
        }
        do {
            lists = try JSONDecoder().decode([TravelList].self, from: data)
            collectionView.reloadData()
        } catch {
            print("⚠️ Decode error: \(error)")
        }
    }
}

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCardCell.reuseIdentifier, for: indexPath) as! ExploreCardCell
        cell.configure(with: lists[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = ListDetailViewController(list: lists[indexPath.item])
        navigationController?.pushViewController(detailVC, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
