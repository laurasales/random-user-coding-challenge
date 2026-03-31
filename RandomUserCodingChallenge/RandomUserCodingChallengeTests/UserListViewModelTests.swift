//
//  UserListViewModelTests.swift
//  RandomUserCodingChallengeTests
//
//  Created by Laura Sales Martínez on 30/3/26.
//

import XCTest
@testable import RandomUserCodingChallenge

@MainActor
final class UserListViewModelTests: XCTestCase {
    private var repository: MockUserRepository!
    private var apiClient: MockAPIClient!
    private var sut: UserListViewModel!

    override func setUp() {
        super.setUp()
        repository = MockUserRepository()
        apiClient = MockAPIClient()
        sut = UserListViewModel(
            fetchUsersUseCase: FetchUsersUseCase(repository: repository, apiClient: apiClient),
            deleteUserUseCase: DeleteUserUseCase(repository: repository),
            filterUsersUseCase: FilterUsersUseCase()
        )
    }

    override func tearDown() {
        sut = nil
        apiClient = nil
        repository = nil
        super.tearDown()
    }

    func test_loadUsers_populatesUsers() async {
        apiClient.usersToReturn = [User.fixture(id: "1"), User.fixture(id: "2")]

        await sut.loadUsers()

        XCTAssertEqual(sut.users.count, 2)
    }

    func test_loadUsers_isLoadingFalse_afterSuccess() async {
        apiClient.usersToReturn = [User.fixture(id: "1")]

        await sut.loadUsers()

        XCTAssertFalse(sut.isLoading)
    }

    func test_loadUsers_isLoadingFalse_afterFailure() async {
        apiClient.errorToThrow = URLError(.notConnectedToInternet)

        await sut.loadUsers()

        XCTAssertFalse(sut.isLoading)
    }

    func test_loadUsers_setsErrorMessage_onFailure() async {
        apiClient.errorToThrow = URLError(.notConnectedToInternet)

        await sut.loadUsers()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_loadUsers_clearsErrorMessage_onSuccess() async {
        apiClient.errorToThrow = URLError(.notConnectedToInternet)
        await sut.loadUsers()

        apiClient.errorToThrow = nil
        apiClient.usersToReturn = [User.fixture(id: "1")]
        await sut.loadUsers()

        XCTAssertNil(sut.errorMessage)
    }

    func test_loadUsers_accumulatesUsersAcrossCalls() async {
        apiClient.usersToReturn = [User.fixture(id: "1")]
        await sut.loadUsers()

        apiClient.usersToReturn = [User.fixture(id: "2")]
        await sut.loadUsers()

        XCTAssertEqual(sut.users.count, 2)
    }

    func test_deleteUser_removesUserFromList() async {
        let user = User.fixture(id: "1")
        apiClient.usersToReturn = [user]
        await sut.loadUsers()

        sut.deleteUser(user)

        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_deleteUser_onlyRemovesTargetUser() async {
        let userToDelete = User.fixture(id: "1")
        let userToKeep = User.fixture(id: "2")
        apiClient.usersToReturn = [userToDelete, userToKeep]
        await sut.loadUsers()

        sut.deleteUser(userToDelete)

        XCTAssertEqual(sut.users.count, 1)
        XCTAssertEqual(sut.users.first?.id, "2")
    }

    func test_deleteUser_marksUserAsDeleted_inRepository() async {
        let user = User.fixture(id: "1")
        apiClient.usersToReturn = [user]
        await sut.loadUsers()

        sut.deleteUser(user)

        XCTAssertTrue(repository.deletedIDs.contains("1"))
    }

    func test_deleteUser_doesNotReappear_afterClearingSearch() async {
        let user = User.fixture(id: "1", firstName: "Alice")
        apiClient.usersToReturn = [user]
        await sut.loadUsers()
        sut.searchText = "Alice"

        sut.deleteUser(user)
        sut.searchText = ""

        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_searchText_filtersUsers() async {
        apiClient.usersToReturn = [
            User.fixture(id: "1", firstName: "Alice"),
            User.fixture(id: "2", firstName: "Bob")
        ]
        await sut.loadUsers()

        sut.searchText = "Alice"

        XCTAssertEqual(sut.users.count, 1)
        XCTAssertEqual(sut.users.first?.id, "1")
    }

    func test_searchText_empty_showsAllUsers() async {
        apiClient.usersToReturn = [
            User.fixture(id: "1", firstName: "Alice"),
            User.fixture(id: "2", firstName: "Bob")
        ]
        await sut.loadUsers()
        sut.searchText = "Alice"

        sut.searchText = ""

        XCTAssertEqual(sut.users.count, 2)
    }
}
