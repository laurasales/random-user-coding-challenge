//
//  StubAPIClient.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 30/3/26.
//

import Foundation

final class StubAPIClient: RandomUserAPIClientProtocol {
    func fetchUsers() async throws -> [User] {
        StubAPIClient.users
    }

    static let users: [User] = [
        User(
            id: "stub-1",
            firstName: "Alice",
            lastName: "Smith",
            email: "alice.smith@example.com",
            phone: "555-0101",
            gender: "female",
            street: "1 Test Street",
            city: "Barcelona",
            state: "Catalonia",
            registeredDate: Date(timeIntervalSince1970: 0),
            thumbnailURL: URL(string: "https://example.com/thumb.jpg")!,
            largeImageURL: URL(string: "https://example.com/large.jpg")!,
            insertedAt: Date(timeIntervalSince1970: 0)
        ),
        User(
            id: "stub-2",
            firstName: "Bob",
            lastName: "Jones",
            email: "bob.jones@example.com",
            phone: "555-0102",
            gender: "male",
            street: "2 Test Street",
            city: "Madrid",
            state: "Madrid",
            registeredDate: Date(timeIntervalSince1970: 0),
            thumbnailURL: URL(string: "https://example.com/thumb.jpg")!,
            largeImageURL: URL(string: "https://example.com/large.jpg")!,
            insertedAt: Date(timeIntervalSince1970: 0)
        ),
        User(
            id: "stub-3",
            firstName: "Carol",
            lastName: "White",
            email: "carol.white@example.com",
            phone: "555-0103",
            gender: "female",
            street: "3 Test Street",
            city: "Valencia",
            state: "Valencia",
            registeredDate: Date(timeIntervalSince1970: 0),
            thumbnailURL: URL(string: "https://example.com/thumb.jpg")!,
            largeImageURL: URL(string: "https://example.com/large.jpg")!,
            insertedAt: Date(timeIntervalSince1970: 0)
        ),
    ]
}
