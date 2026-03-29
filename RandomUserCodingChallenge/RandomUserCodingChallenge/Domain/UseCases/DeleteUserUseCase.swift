//
//  DeleteUserUseCase.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

final class DeleteUserUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userID: String) throws {
        try repository.deleteUser(id: userID)
    }
}
