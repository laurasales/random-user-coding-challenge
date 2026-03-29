//
//  UserRepositoryProtocol.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchStoredUsers() throws -> [User]
    func saveUsers(_ users: [User]) throws
    func deleteUser(id: String) throws
    func isDeleted(id: String) throws -> Bool
}
