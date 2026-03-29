//
//  UserListViewModel.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

@Observable
final class UserListViewModel {
    private(set) var users: [User] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil

    var searchText: String = "" {
        didSet { applyFilter() }
    }

    private var allUsers: [User] = []
    private let fetchUsersUseCase: FetchUsersUseCase
    private let deleteUserUseCase: DeleteUserUseCase
    private let filterUsersUseCase: FilterUsersUseCase

    init(
        fetchUsersUseCase: FetchUsersUseCase,
        deleteUserUseCase: DeleteUserUseCase,
        filterUsersUseCase: FilterUsersUseCase
    ) {
        self.fetchUsersUseCase = fetchUsersUseCase
        self.deleteUserUseCase = deleteUserUseCase
        self.filterUsersUseCase = filterUsersUseCase
    }

    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            allUsers = try await fetchUsersUseCase.execute()
            applyFilter()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteUser(_ user: User) {
        do {
            try deleteUserUseCase.execute(userID: user.id)
            allUsers.removeAll { $0.id == user.id }
            applyFilter()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func applyFilter() {
        users = filterUsersUseCase.execute(users: allUsers, searchTerm: searchText)
    }
}
