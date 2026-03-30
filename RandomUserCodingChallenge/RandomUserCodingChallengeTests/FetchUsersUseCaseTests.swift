//
//  FetchUsersUseCaseTests.swift
//  RandomUserCodingChallengeTests
//
//  Created by Laura Sales Martínez on 30/3/26.
//

import XCTest
@testable import RandomUserCodingChallenge

final class FetchUsersUseCaseTests: XCTestCase {
    private var repository: MockUserRepository!
    private var apiClient: MockAPIClient!
    private var sut: FetchUsersUseCase!

    override func setUp() {
        super.setUp()
        repository = MockUserRepository()
        apiClient = MockAPIClient()
        sut = FetchUsersUseCase(repository: repository, apiClient: apiClient)
    }

    override func tearDown() {
        sut = nil
        apiClient = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_savesNewUsersFromAPI() async throws {
        let user = User.fixture(id: "1")
        apiClient.usersToReturn = [user]

        _ = try await sut.execute()

        XCTAssertEqual(repository.storedUsers.count, 1)
        XCTAssertEqual(repository.storedUsers.first?.id, "1")
    }

    func test_execute_doesNotSaveDuplicateUsers() async throws {
        let user = User.fixture(id: "1")
        repository.storedUsers = [user]
        apiClient.usersToReturn = [user]

        _ = try await sut.execute()

        XCTAssertEqual(repository.storedUsers.count, 1)
    }

    func test_execute_doesNotSaveDeletedUsers() async throws {
        let user = User.fixture(id: "1")
        repository.deletedIDs = ["1"]
        apiClient.usersToReturn = [user]

        _ = try await sut.execute()

        XCTAssertTrue(repository.storedUsers.isEmpty)
    }

    func test_execute_returnsAllStoredUsersAfterSaving() async throws {
        let existing = User.fixture(id: "1")
        let new = User.fixture(id: "2")
        repository.storedUsers = [existing]
        apiClient.usersToReturn = [new]

        let result = try await sut.execute()

        XCTAssertEqual(result.count, 2)
    }

    func test_execute_savesOnlyNewUsersWhenMixedWithDuplicates() async throws {
        let existing = User.fixture(id: "1")
        let new = User.fixture(id: "2")
        repository.storedUsers = [existing]
        apiClient.usersToReturn = [existing, new]

        _ = try await sut.execute()

        XCTAssertEqual(repository.storedUsers.count, 2)
    }

    func test_execute_emptyAPIResponse_returnsExistingStoredUsers() async throws {
        repository.storedUsers = [User.fixture(id: "1")]
        apiClient.usersToReturn = []

        let result = try await sut.execute()

        XCTAssertEqual(result.count, 1)
    }

    func test_execute_emptyStoreAndEmptyAPI_returnsEmpty() async throws {
        apiClient.usersToReturn = []

        let result = try await sut.execute()

        XCTAssertTrue(result.isEmpty)
    }

    func test_execute_propagatesAPIError() async {
        apiClient.errorToThrow = URLError(.notConnectedToInternet)

        await XCTAssertThrowsErrorAsync(try await sut.execute())
    }

    func test_execute_skipsAllDeletedUsersFromMultipleBatches() async throws {
        repository.deletedIDs = ["1", "2"]
        apiClient.usersToReturn = [User.fixture(id: "1"), User.fixture(id: "2"), User.fixture(id: "3")]

        _ = try await sut.execute()

        XCTAssertEqual(repository.storedUsers.count, 1)
        XCTAssertEqual(repository.storedUsers.first?.id, "3")
    }
}

func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error to be thrown", file: file, line: line)
    } catch {}
}
