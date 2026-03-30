import Foundation
@testable import RandomUserCodingChallenge

final class MockAPIClient: RandomUserAPIClientProtocol {
    var usersToReturn: [User] = []
    var errorToThrow: Error?

    func fetchUsers() async throws -> [User] {
        if let error = errorToThrow {
            throw error
        }
        return usersToReturn
    }
}
