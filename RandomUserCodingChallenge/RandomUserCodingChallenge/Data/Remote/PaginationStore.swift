//
//  PaginationStore.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 31/3/26.
//

import Foundation

final class PaginationStore {
    private let userDefaultsManager: UserDefaultsManager

    private static let seedKey = "randomuser.seed"
    private static let pageKey = "randomuser.page"

    private(set) var seed: String
    private(set) var currentPage: Int

    init(userDefaultsManager: UserDefaultsManager = UserDefaultsManager()) {
        self.userDefaultsManager = userDefaultsManager

        if let savedSeed = userDefaultsManager.string(forKey: Self.seedKey) {
            seed = savedSeed
            currentPage = userDefaultsManager.integer(forKey: Self.pageKey) ?? 1
        } else {
            let newSeed = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
            seed = newSeed
            currentPage = 1
            userDefaultsManager.set(newSeed, forKey: Self.seedKey)
            userDefaultsManager.set(1, forKey: Self.pageKey)
        }
    }

    func advance() {
        currentPage += 1
        userDefaultsManager.set(currentPage, forKey: Self.pageKey)
    }
}
