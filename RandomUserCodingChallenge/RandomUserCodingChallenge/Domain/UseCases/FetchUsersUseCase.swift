//
//  FetchUsersUseCase.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

final class FetchUsersUseCase {
    private let repository: UserRepositoryProtocol
    private let apiClient: RandomUserAPIClientProtocol

    init(repository: UserRepositoryProtocol, apiClient: RandomUserAPIClientProtocol) {
        self.repository = repository
        self.apiClient = apiClient
    }

    func execute() async throws -> [User] {
        let remoteUsers = try await apiClient.fetchUsers()
        let storedUsers = try repository.fetchStoredUsers()
        let storedIDs = Set(storedUsers.map(\.id))

        let newUsers = try remoteUsers.filter { user in
            guard !storedIDs.contains(user.id) else { return false }
            return try !repository.isDeleted(id: user.id)
        }

        try repository.saveUsers(newUsers)
        return try repository.fetchStoredUsers()
    }
}
