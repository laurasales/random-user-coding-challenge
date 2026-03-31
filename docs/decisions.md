# Design Decisions

This document records the significant design choices made during development, the reasoning behind each, and the trade-offs accepted.

---

## ADR-001: Clean Architecture with Protocol-based Seams

**Decision:** Separate the app into Domain, Data, and Presentation layers. Define all cross-layer contracts as protocols in the Domain layer.

**Reasoning:** The Domain layer is the core of the app. Keeping it free of framework dependencies means use cases and models can be tested with plain Swift, without a simulator or any framework setup. The two key protocols (`UserRepositoryProtocol`, `RandomUserAPIClientProtocol`) act as seams — they allow the production implementations, unit test mocks, and UI test stubs to be swapped without changing the use cases or ViewModel.

**Trade-off:** Some boilerplate — each data operation requires a protocol method, a real implementation, and a mock. For an app of this size, that cost is low relative to the testability benefit.

---

## ADR-002: SwiftData for Persistence

**Decision:** Use SwiftData (`@Model`, `ModelContext`, `ModelContainer`) over Core Data or a custom persistence layer.

**Reasoning:** SwiftData is the modern, native persistence framework for Swift and integrates natively with `async/await`. For a new project targeting iOS 18.5+, it removes the need for NSManagedObject subclasses, XML model files, and `NSFetchRequest` boilerplate. The `@Model` macro and `#Predicate` DSL keep persistence code concise and type-safe.

**Trade-off:** SwiftData requires iOS 17+. The `ModelContext` is not `Sendable`, so the entire DI container (`AppDependencies`) must be `@MainActor`-confined. This is acceptable at this scale, but a larger app with background sync would need a more deliberate actor boundary design.

---

## ADR-003: Soft Delete

**Decision:** Deleted users are flagged with `isDeleted = true` on `UserEntity` rather than being removed from the database.

**Reasoning:** Hard-deleting a user from the local store means the app has no record that the user was ever seen. On the next API fetch, the same user could be returned and re-inserted into the list — effectively undoing the deletion. Soft delete preserves the deletion intent. `FetchUsersUseCase` checks `isDeleted` before saving any user returned by the API, so deleted users never reappear.

**Trade-off:** The database accumulates rows for deleted users indefinitely. For this use case (a demo app with a bounded user set), this is fine. In production, a compaction job or a TTL-based cleanup would be appropriate.

---

## ADR-004: Deduplication by `login.uuid`

**Decision:** Before saving a batch of API users, each is checked against the local store by its `login.uuid`. Existing users are skipped rather than updated.

**Reasoning:** Using `login.uuid` as the canonical identity aligns with the API's own identifier scheme and ensures the list never grows with duplicate entries. With seed-based pagination in place (see ADR-011), cross-page duplicates are prevented structurally — deduplication now serves as a safety net for edge cases such as app data being cleared mid-session, causing the seed and page counter to reset and page 1 to be re-fetched.

**Trade-off:** User data is never updated once saved. If the API returns an updated email or phone for a previously stored user, it will be silently ignored. For a read-only display app, this is acceptable.

---

## ADR-005: `insertedAt` for Stable Sort Order

**Decision:** Each `UserEntity` stores an `insertedAt: Date` timestamp, set at insertion time. All `UserRepository` queries sort by this field.

**Reasoning:** SwiftData does not guarantee storage order. Without an explicit sort key, the list order could change between launches. Sorting by `insertedAt` ensures users always appear in the order they were first fetched, which matches user expectation for a paginated list.

**Trade-off:** The sort key is set by the app, not the API. If two batches arrive very close together, their relative order within the batch depends on the order they appear in the API response, not any semantic ordering (e.g. registration date).

---

## ADR-006: `@Observable` Instead of `ObservableObject`

**Decision:** `UserListViewModel` uses the `@Observable` macro (iOS 17 Observation framework) rather than `ObservableObject` + `@Published`.

**Reasoning:** `@Observable` enables fine-grained dependency tracking — SwiftUI re-renders only views that access a changed property, rather than the entire view observing the object. It also removes the need for `@StateObject` / `@ObservedObject` distinctions at the call site; a plain `var` or `let` in the view body is sufficient.

**Trade-off:** Requires iOS 17+. Not backwards-compatible. Given this app targets iOS 18.5+ for SwiftData anyway, this is a non-issue.

---

## ADR-007: Search Debounce via `Task` + `Task.sleep`

**Decision:** The 500 ms search debounce in `UserListViewModel` is implemented by creating a new `Task` for each `searchText` change, cancelling any previous task before starting the new one, and sleeping at the start of each task.

**Reasoning:** This is the idiomatic `async/await` approach on iOS 17+. It requires no Combine, no timers, and no GCD. The cooperative cancellation model means the sleep returns early if the task is cancelled — there is no "leaked" filter operation running after the user has already typed more characters.

**Trade-off:** The debounce logic is implicit — it relies on understanding Swift's structured concurrency task cancellation model. A dedicated `Debouncer` type could make it more explicit, but introduces unnecessary complexity for a single use site.

---

## ADR-008: No Third-Party Dependencies

**Decision:** The app uses only Apple frameworks. No Alamofire, Kingfisher, Combine-based reactive libraries, or other packages.

**Reasoning:** Modern Swift (`async/await`, `URLSession`, `AsyncImage`) covers all the networking and image-loading needs of this app without third-party help. Keeping the dependency graph minimal reduces build time, eliminates supply-chain risk, and demonstrates fluency with the platform's native capabilities — which is directly relevant for a senior iOS role.

**Trade-off:** Some functionality that would be trivial with a library (e.g. sophisticated image caching, retry logic) requires more code if needed in the future. For this project's scope, the native tools are sufficient.

---

## ADR-009: Page Object Model for UI Tests

**Decision:** UI test interactions are encapsulated in `UserListScreen` and `UserDetailScreen` page objects rather than writing XCUIElement queries inline in each test.

**Reasoning:** Page objects decouple what a test is asserting from how the UI is queried. When a UI element's accessibility identifier changes, the fix is in one place (the page object) rather than spread across 16 test methods. They also make the test body read like a user scenario, which improves readability.

**Trade-off:** Minor overhead in maintaining the page objects. The benefit compounds as the number of tests grows.

---

## ADR-011: Seed-Based Pagination

**Decision:** `RandomUserAPIClient` generates a random seed on first launch, persists it to `UserDefaults`, and increments a page counter with each successful fetch. Every API request uses `?results=40&seed={seed}&page={n}`.

**Reasoning:** Without a fixed seed, each API call returns a random set of users independently, and consecutive fetches can overlap. Deduplication (ADR-004) masked this at the cost of making overlap-prevention a correction rather than a guarantee. Using a fixed seed makes the API return a deterministic sequence, eliminating cross-page overlap by design.

The seed and page counter are persisted to `UserDefaults` so that pagination survives app restarts. On relaunch, the app resumes from where it left off rather than re-fetching from page 1.

Pagination state is encapsulated in `PaginationStore` (`Data/Remote/`), which delegates all storage reads and writes to `UserDefaultsManager` (`Data/`). This layering keeps each class focused: `RandomUserAPIClient` handles networking only, `PaginationStore` owns pagination logic, `UserDefaultsManager` owns storage mechanics.

**Trade-off:** The seed is fixed for the lifetime of the app install, so users always see the same universe of random users in the same order. This is intentional — it ensures list stability across sessions. Clearing app data resets the seed and starts a fresh sequence. A truly random experience on every launch would require dropping pagination guarantees.

---

## ADR-010: Single `ModelContext` on `@MainActor`

**Decision:** A single `ModelContext` is created in `AppDependencies` and used by `UserRepository` for all reads and writes. There is no background context.

**Reasoning:** SwiftData's `ModelContext` must be used on a single actor. For an app without background sync, one main-actor context is the simplest correct design. All data operations in this app are triggered by user interaction, so they naturally occur on the main actor. Adding a background context would introduce merge complexity with no benefit.

**Trade-off:** All database operations block the main thread momentarily. For the volume of data in this app (hundreds of users at most), this is imperceptible. A high-volume app with large write batches would need background context support.
