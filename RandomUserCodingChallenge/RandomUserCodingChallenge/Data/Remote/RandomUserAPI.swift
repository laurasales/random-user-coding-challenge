//
//  RandomUserAPI.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

enum RandomUserAPI {
    struct Response: Decodable {
        let results: [UserDTO]
        let info: Info
    }

    struct Info: Decodable {
        let seed: String
        let results: Int
        let page: Int
        let version: String
    }

    struct UserDTO: Decodable {
        let gender: String
        let name: Name
        let location: Location
        let email: String
        let login: Login
        let dob: DateAge
        let registered: DateAge
        let phone: String
        let cell: String
        let id: ExternalID
        let picture: Picture
        let nat: String
    }

    struct Name: Decodable {
        let title: String
        let first: String
        let last: String
    }

    struct Location: Decodable {
        let street: Street
        let city: String
        let state: String
        let country: String
        let postcode: Postcode
        let coordinates: Coordinates
        let timezone: Timezone
    }

    enum Postcode: Decodable {
        case string(String)
        case int(Int)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let intValue = try? container.decode(Int.self) {
                self = .int(intValue)
            } else {
                self = try .string(container.decode(String.self))
            }
        }

        var value: String {
            switch self {
            case let .string(stringValue): stringValue
            case let .int(intValue): String(intValue)
            }
        }
    }

    struct Street: Decodable {
        let number: Int
        let name: String
    }

    struct Coordinates: Decodable {
        let latitude: String
        let longitude: String
    }

    struct Timezone: Decodable {
        let offset: String
        let description: String
    }

    struct Login: Decodable {
        let uuid: String
        let username: String
        let password: String
        let salt: String
        let md5: String
        let sha1: String
        let sha256: String
    }

    struct DateAge: Decodable {
        let date: Date
        let age: Int
    }

    struct ExternalID: Decodable {
        let name: String
        let value: String?
    }

    struct Picture: Decodable {
        let large: URL
        let medium: URL
        let thumbnail: URL
    }
}

extension RandomUserAPI.UserDTO {
    func toDomain(insertedAt: Date) -> User {
        User(
            id: login.uuid,
            firstName: name.first,
            lastName: name.last,
            email: email,
            phone: phone,
            gender: gender,
            street: "\(location.street.number) \(location.street.name)",
            city: location.city,
            state: location.state,
            registeredDate: registered.date,
            thumbnailURL: picture.thumbnail,
            largeImageURL: picture.large,
            insertedAt: insertedAt
        )
    }
}
