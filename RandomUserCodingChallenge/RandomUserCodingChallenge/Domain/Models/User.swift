//
//  User.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

struct User: Identifiable, Equatable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let gender: String
    let street: String
    let city: String
    let state: String
    let registeredDate: Date
    let thumbnailURL: URL
    let largeImageURL: URL
    let insertedAt: Date

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
