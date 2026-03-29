//
//  RandomUserResponseDTO.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

struct RandomUserResponseDTO: Decodable {
    let results: [RandomUserDTO]
    let info: InfoDTO
}

struct InfoDTO: Decodable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

struct RandomUserDTO: Decodable {
    let gender: String
    let name: NameDTO
    let location: LocationDTO
    let email: String
    let login: LoginDTO
    let dob: AgeDTO
    let registered: AgeDTO
    let phone: String
    let cell: String
    let id: ExternalIDDTO
    let picture: PictureDTO
    let nat: String
}

struct NameDTO: Decodable {
    let title: String
    let first: String
    let last: String
}

struct LocationDTO: Decodable {
    let street: StreetDTO
    let city: String
    let state: String
    let country: String
    let postcode: PostcodeDTO
    let coordinates: CoordinatesDTO
    let timezone: TimezoneDTO
}

enum PostcodeDTO: Decodable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    var value: String {
        switch self {
        case .string(let s): return s
        case .int(let i): return String(i)
        }
    }
}

struct StreetDTO: Decodable {
    let number: Int
    let name: String
}

struct CoordinatesDTO: Decodable {
    let latitude: String
    let longitude: String
}

struct TimezoneDTO: Decodable {
    let offset: String
    let description: String
}

struct LoginDTO: Decodable {
    let uuid: String
    let username: String
    let password: String
    let salt: String
    let md5: String
    let sha1: String
    let sha256: String
}

struct AgeDTO: Decodable {
    let date: Date
    let age: Int
}

struct ExternalIDDTO: Decodable {
    let name: String
    let value: String?
}

struct PictureDTO: Decodable {
    let large: URL
    let medium: URL
    let thumbnail: URL
}

extension RandomUserDTO {
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
