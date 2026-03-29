//
//  UserRowView.swift
//  RandomUserCodingChallenge
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import SwiftUI

struct UserRowView: View {
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: user.thumbnailURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.secondary.opacity(0.2)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(user.phone)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
