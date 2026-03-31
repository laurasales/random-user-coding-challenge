//
//  RandomUserCodingChallengeApp.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import SwiftData
import SwiftUI

@main
struct RandomUserCodingChallengeApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
        }
        .modelContainer(dependencies.modelContainer)
    }
}
