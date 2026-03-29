//
//  RandomUserAPIClientProtocol.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

protocol RandomUserAPIClientProtocol {
    func fetchUsers() async throws -> [User]
}
