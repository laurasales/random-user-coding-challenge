//
//  MockUserRepository.swift
//  RandomUserCodingChallengeTests
//
//  Created by Laura Sales Martínez on 30/3/26.
//

import Foundation
@testable import RandomUserCodingChallenge

final class MockUserRepository: UserRepositoryProtocol {
    var storedUsers: [User] = []
    var deletedIDs: Set<String> = []
    var errorToThrow: Error?

    func fetchStoredUsers() throws -> [User] {
        storedUsers
    }

    func saveUsers(_ users: [User]) throws {
        storedUsers.append(contentsOf: users)
    }

    func deleteUser(id: String) throws {
        if let error = errorToThrow { throw error }
        deletedIDs.insert(id)
        storedUsers.removeAll { $0.id == id }
    }

    func isDeleted(id: String) throws -> Bool {
        deletedIDs.contains(id)
    }
}
