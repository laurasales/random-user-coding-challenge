import Foundation
@testable import RandomUserCodingChallenge

extension User {
    static func fixture(
        id: String = "test-uuid",
        firstName: String = "Laura",
        lastName: String = "Sales",
        email: String = "laura.sales@example.com",
        phone: String = "555-0100",
        gender: String = "female",
        street: String = "123 Main St",
        city: String = "Barcelona",
        state: String = "Spain",
        registeredDate: Date = Date(timeIntervalSince1970: 0),
        thumbnailURL: URL = URL(string: "https://example.com/thumb.jpg")!,
        largeImageURL: URL = URL(string: "https://example.com/large.jpg")!,
        insertedAt: Date = Date(timeIntervalSince1970: 0)
    ) -> User {
        User(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            gender: gender,
            street: street,
            city: city,
            state: state,
            registeredDate: registeredDate,
            thumbnailURL: thumbnailURL,
            largeImageURL: largeImageURL,
            insertedAt: insertedAt
        )
    }
}
