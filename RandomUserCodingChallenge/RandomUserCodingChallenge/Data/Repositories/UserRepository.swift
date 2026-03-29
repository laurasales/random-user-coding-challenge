//
//  UserRepository.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation
import SwiftData

final class UserRepository: UserRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchStoredUsers() throws -> [User] {
        let descriptor = FetchDescriptor<UserEntity>(
            predicate: #Predicate { !$0.isDeleted },
            sortBy: [SortDescriptor(\.insertedAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func saveUsers(_ users: [User]) throws {
        for user in users {
            let entity = UserEntity.from(user)
            modelContext.insert(entity)
        }
        try modelContext.save()
    }

    func deleteUser(id: String) throws {
        let descriptor = FetchDescriptor<UserEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard let entity = try modelContext.fetch(descriptor).first else { return }
        entity.isDeleted = true
        try modelContext.save()
    }

    func isDeleted(id: String) throws -> Bool {
        let descriptor = FetchDescriptor<UserEntity>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first?.isDeleted ?? false
    }
}
