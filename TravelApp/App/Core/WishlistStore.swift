//
//  WishlistStore.swift
//  TravelApp
//
//  Created by Laptop X on 24/05/26.
//


//
//  WishlistStore.swift
//  TravelApp
//

import Foundation

extension Notification.Name {
    static let wishlistDidChange = Notification.Name("WishlistStoreDidChange")
}

/// In-memory + UserDefaults-backed store of wishlisted `TravelList`s.
/// Posts `.wishlistDidChange` on every mutation so any visible cell or list updates live.
final class WishlistStore {
    static let shared = WishlistStore()

    private let storageKey = "wishlist.travelLists.v1"
    private(set) var lists: [TravelList] = []

    private init() {
        load()
    }

    // MARK: - Queries

    func isWishlisted(id: String) -> Bool {
        lists.contains(where: { $0.id == id })
    }

    // MARK: - Mutations

    /// Toggles the list's wishlisted state. Returns the new state (`true` = now saved).
    @discardableResult
    func toggle(_ list: TravelList) -> Bool {
        if isWishlisted(id: list.id) {
            lists.removeAll { $0.id == list.id }
            persistAndNotify()
            return false
        } else {
            lists.insert(list, at: 0)   // newest at top
            persistAndNotify()
            return true
        }
    }

    func remove(id: String) {
        guard isWishlisted(id: id) else { return }
        lists.removeAll { $0.id == id }
        persistAndNotify()
    }

    // MARK: - Persistence

    private func persistAndNotify() {
        save()
        NotificationCenter.default.post(name: .wishlistDidChange, object: nil)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(lists)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("⚠️ WishlistStore encode failed: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            lists = try JSONDecoder().decode([TravelList].self, from: data)
        } catch {
            print("⚠️ WishlistStore decode failed: \(error)")
            lists = []
        }
    }
}