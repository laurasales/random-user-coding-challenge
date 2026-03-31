//
//  RandomUserAPIClient.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

final class RandomUserAPIClient: RandomUserAPIClientProtocol {
    private let session: URLSession

    private static let baseURL = URL(string: "https://api.randomuser.me")!
    private static let resultsPerPage = 40

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date format: \(dateString)"
                )
            }
            return date
        }
        return decoder
    }()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchUsers() async throws -> [User] {
        let url = try makeURL()
        let (data, response) = try await session.data(from: url)
        try validate(response)
        let dto = try Self.decoder.decode(RandomUserAPI.Response.self, from: data)
        return dto.results.map { $0.toDomain(insertedAt: Date()) }
    }

    private func makeURL() throws -> URL {
        var components = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "results", value: String(Self.resultsPerPage))]
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        return url
    }

    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badStatusCode(0)
        }
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
    }
}
