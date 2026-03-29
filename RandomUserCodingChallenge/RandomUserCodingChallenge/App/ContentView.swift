//
//  ContentView.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import SwiftUI

struct ContentView: View {
    let dependencies: AppDependencies

    var body: some View {
        UserListView(
            viewModel: UserListViewModel(
                fetchUsersUseCase: dependencies.fetchUsersUseCase,
                deleteUserUseCase: dependencies.deleteUserUseCase,
                filterUsersUseCase: dependencies.filterUsersUseCase
            )
        )
    }
}
