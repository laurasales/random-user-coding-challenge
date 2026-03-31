//
//  UserDefaultsManager.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 31/3/26.
//

import Foundation

final class UserDefaultsManager {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func string(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    func integer(forKey key: String) -> Int? {
        let value = defaults.integer(forKey: key)
        return value > 0 ? value : nil
    }

    func set(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func set(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
