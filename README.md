# random-user-coding-challenge
An iOS application that fetches and displays random users from the [RandomUser API](https://randomuser.me).

## Features

- Browse a list of random users with name, surname, email, picture, and phone
- Load more users with infinite scroll
- Delete users — deleted users never reappear even after new fetches
- Filter users by name, surname, or email with debounced search
- Tap a user to see full details: gender, location, registered date
- Persistent data and stable list order across app launches

## Architecture

The app follows **Clean Architecture** with an **MVVM** presentation layer:

**Presentation** (Views/ViewModels) → **Domain** (Use Cases/Models) ← **Data** (API/SwiftData)

- **Domain layer:** pure Swift. No framework dependencies. Contains `User` model, `UserRepositoryProtocol`, `RandomUserAPIClientProtocol`, and
 three use cases.
- **Data layer:** SwiftData persistence (`UserEntity`) and a `URLSession` based API client. Both implement domain protocols.
- **Presentation layer:** SwiftUI views backed by `@Observable` ViewModels that depend only on use cases.

## Tech Stack

- Swift, SwiftUI, SwiftData
- `URLSession` with `async/await`, no third-party networking libraries
- XCTest for testing

## Key Decisions

- **Deduplication:** users are identified by `login.uuid` from the API. Duplicates are silently ignored on save.
- **Soft delete:** deleted users are flagged with `isDeleted = true` in the local store and filtered out from all queries, including future
API responses.
- **Stable order:** users are stored with an `insertedAt` timestamp and always sorted by insertion time, guaranteeing the same order across
sessions.
- **Search debounce** — the filter updates 500ms after the user stops typing, implemented in the ViewModel using `Task` + `try await
Task.sleep`.
