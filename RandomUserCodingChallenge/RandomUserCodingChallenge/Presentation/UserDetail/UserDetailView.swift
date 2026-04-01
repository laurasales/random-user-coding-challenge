//
//  UserDetailView.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import SwiftUI

struct UserDetailView: View {
    let user: User

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                userHeader
                Divider()
                infoSection
            }
            .padding()
        }
        .navigationTitle(user.fullName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var userHeader: some View {
        VStack(spacing: 12) {
            AsyncImage(url: user.largeImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.secondary.opacity(0.2)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())

            Text(user.fullName)
                .font(.title2)
                .fontWeight(.semibold)

            Text(user.gender.capitalized)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailRow(
                icon: "envelope",
                label: "Email",
                value: user.email
            )
            DetailRow(
                icon: "mappin.and.ellipse",
                label: "Location",
                value: "\(user.street), \(user.city), \(user.state)"
            )
            DetailRow(
                icon: "calendar",
                label: "Registered",
                value: user.registeredDate.formatted(date: .long, time: .omitted)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}
