//
//  FilterUsersUseCase.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

final class FilterUsersUseCase {
    func execute(users: [User], searchTerm: String) -> [User] {
        guard !searchTerm.trimmingCharacters(in: .whitespaces).isEmpty else {
            return users
        }
        let term = searchTerm.lowercased()
        return users.filter { user in
            user.firstName.lowercased().contains(term)
                || user.lastName.lowercased().contains(term)
                || user.email.lowercased().contains(term)
        }
    }
}
