//
//  AppDependencies.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation
import SwiftData

@MainActor
final class AppDependencies {
    let modelContainer: ModelContainer
    let userRepository: UserRepositoryProtocol
    let apiClient: RandomUserAPIClientProtocol
    let fetchUsersUseCase: FetchUsersUseCase
    let deleteUserUseCase: DeleteUserUseCase
    let filterUsersUseCase: FilterUsersUseCase

    init() {
        let container = Self.makeModelContainer()
        let context = ModelContext(container)

        self.modelContainer = container
        self.userRepository = UserRepository(modelContext: context)
        self.apiClient = RandomUserAPIClient()
        self.fetchUsersUseCase = FetchUsersUseCase(repository: userRepository, apiClient: apiClient)
        self.deleteUserUseCase = DeleteUserUseCase(repository: userRepository)
        self.filterUsersUseCase = FilterUsersUseCase()
    }

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([UserEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
