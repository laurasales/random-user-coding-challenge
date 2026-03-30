import XCTest
@testable import RandomUserCodingChallenge

final class DeleteUserUseCaseTests: XCTestCase {
    private var repository: MockUserRepository!
    private var sut: DeleteUserUseCase!

    override func setUp() {
        super.setUp()
        repository = MockUserRepository()
        sut = DeleteUserUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_marksUserAsDeletedInRepository() throws {
        try sut.execute(userID: "1")

        XCTAssertTrue(repository.deletedIDs.contains("1"))
    }

    func test_execute_removesUserFromStoredUsers() throws {
        repository.storedUsers = [User.fixture(id: "1"), User.fixture(id: "2")]

        try sut.execute(userID: "1")

        XCTAssertFalse(repository.storedUsers.contains { $0.id == "1" })
        XCTAssertEqual(repository.storedUsers.count, 1)
    }

    func test_execute_propagatesRepositoryError() {
        repository.errorToThrow = URLError(.badServerResponse)

        XCTAssertThrowsError(try sut.execute(userID: "1"))
    }
}
