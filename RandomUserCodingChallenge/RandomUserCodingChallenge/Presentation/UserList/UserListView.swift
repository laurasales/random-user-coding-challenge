//
//  UserListView.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import SwiftUI

struct UserListView: View {
    @State private var viewModel: UserListViewModel

    init(viewModel: UserListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.users) { user in
                    NavigationLink(value: user) {
                        UserRowView(user: user)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteUser(user)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .onAppear {
                        if user.id == viewModel.users.last?.id {
                            Task { await viewModel.loadUsers() }
                        }
                    }
                }

                if viewModel.isLoading, !viewModel.users.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(.accent)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Random Users")
            .searchable(text: $viewModel.searchText, prompt: "Search by name, surname or email")
            .overlay { stateOverlay }
            .navigationDestination(for: User.self) { user in
                UserDetailView(user: user)
            }
        }
        .task {
            await viewModel.loadUsers()
        }
    }

    @ViewBuilder
    private var stateOverlay: some View {
        if viewModel.isLoading, viewModel.users.isEmpty {
            ProgressView()
                .tint(.accent)
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView(
                "Something went wrong",
                systemImage: "wifi.exclamationmark",
                description: Text(error)
            )
        } else if !viewModel.searchText.isEmpty, viewModel.users.isEmpty {
            ContentUnavailableView.search(text: viewModel.searchText)
        }
    }
}
