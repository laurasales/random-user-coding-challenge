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
        let isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
        let container = Self.makeModelContainer(inMemory: isUITesting)
        let context = ModelContext(container)

        modelContainer = container
        userRepository = UserRepository(modelContext: context)
        apiClient = isUITesting ? StubAPIClient() : RandomUserAPIClient()
        fetchUsersUseCase = FetchUsersUseCase(repository: userRepository, apiClient: apiClient)
        deleteUserUseCase = DeleteUserUseCase(repository: userRepository)
        filterUsersUseCase = FilterUsersUseCase()
    }

    private static func makeModelContainer(inMemory: Bool) -> ModelContainer {
        let schema = Schema([UserEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
