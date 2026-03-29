//
//  RandomUserCodingChallengeApp.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import SwiftUI
import SwiftData

@main
struct RandomUserCodingChallengeApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(dependencies.modelContainer)
    }
}
