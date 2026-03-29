//
//  UserEntity.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation
import SwiftData

@Model
final class UserEntity {
    @Attribute(.unique) var id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var gender: String
    var street: String
    var city: String
    var state: String
    var registeredDate: Date
    var thumbnailURL: URL
    var largeImageURL: URL
    var insertedAt: Date
    var isDeleted: Bool

    init(
        id: String,
        firstName: String,
        lastName: String,
        email: String,
        phone: String,
        gender: String,
        street: String,
        city: String,
        state: String,
        registeredDate: Date,
        thumbnailURL: URL,
        largeImageURL: URL,
        insertedAt: Date,
        isDeleted: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.gender = gender
        self.street = street
        self.city = city
        self.state = state
        self.registeredDate = registeredDate
        self.thumbnailURL = thumbnailURL
        self.largeImageURL = largeImageURL
        self.insertedAt = insertedAt
        self.isDeleted = isDeleted
    }
}

extension UserEntity {
    func toDomain() -> User {
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

    static func from(_ user: User) -> UserEntity {
        UserEntity(
            id: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phone: user.phone,
            gender: user.gender,
            street: user.street,
            city: user.city,
            state: user.state,
            registeredDate: user.registeredDate,
            thumbnailURL: user.thumbnailURL,
            largeImageURL: user.largeImageURL,
            insertedAt: user.insertedAt
        )
    }
}
