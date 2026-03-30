//
//  FilterUsersUseCaseTests.swift
//  RandomUserCodingChallengeTests
//
//  Created by Laura Sales Martínez on 30/3/26.
//

import XCTest
@testable import RandomUserCodingChallenge

final class FilterUsersUseCaseTests: XCTestCase {
    private var sut: FilterUsersUseCase!

    override func setUp() {
        super.setUp()
        sut = FilterUsersUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_execute_emptySearchTerm_returnsAllUsers() {
        let users = [User.fixture(id: "1"), User.fixture(id: "2")]

        let result = sut.execute(users: users, searchTerm: "")

        XCTAssertEqual(result.count, 2)
    }

    func test_execute_whitespaceSearchTerm_returnsAllUsers() {
        let users = [User.fixture(id: "1"), User.fixture(id: "2")]

        let result = sut.execute(users: users, searchTerm: "   ")

        XCTAssertEqual(result.count, 2)
    }

    func test_execute_emptyUsersList_returnsEmpty() {
        let result = sut.execute(users: [], searchTerm: "Alice")

        XCTAssertTrue(result.isEmpty)
    }

    func test_execute_filtersByFirstName() {
        let users = [User.fixture(id: "1", firstName: "Alice"), User.fixture(id: "2", firstName: "Bob")]

        let result = sut.execute(users: users, searchTerm: "Alice")

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }

    func test_execute_filtersByLastName() {
        let users = [User.fixture(id: "1", lastName: "Smith"), User.fixture(id: "2", lastName: "Jones")]

        let result = sut.execute(users: users, searchTerm: "Smith")

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }

    func test_execute_filtersByEmail() {
        let users = [
            User.fixture(id: "1", email: "alice@example.com"),
            User.fixture(id: "2", email: "bob@example.com")
        ]

        let result = sut.execute(users: users, searchTerm: "alice")

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }

    func test_execute_isCaseInsensitive() {
        let users = [User.fixture(id: "1", firstName: "Alice")]

        let result = sut.execute(users: users, searchTerm: "ALICE")

        XCTAssertEqual(result.count, 1)
    }

    func test_execute_partialMatch_returnsMatchingUsers() {
        let users = [User.fixture(id: "1", firstName: "Alice"), User.fixture(id: "2", firstName: "Bob")]

        let result = sut.execute(users: users, searchTerm: "Ali")

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }

    func test_execute_searchTermMatchesMultipleUsers() {
        let users = [
            User.fixture(id: "1", firstName: "Alice"),
            User.fixture(id: "2", firstName: "Alicia"),
            User.fixture(id: "3", firstName: "Bob")
        ]

        let result = sut.execute(users: users, searchTerm: "Ali")

        XCTAssertEqual(result.count, 2)
    }

    func test_execute_noMatch_returnsEmpty() {
        let users = [User.fixture(id: "1", firstName: "Alice")]

        let result = sut.execute(users: users, searchTerm: "xyz")

        XCTAssertTrue(result.isEmpty)
    }
}
