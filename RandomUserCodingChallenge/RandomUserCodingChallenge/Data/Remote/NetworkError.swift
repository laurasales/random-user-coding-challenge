//
//  NetworkError.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case badStatusCode(Int)
}
