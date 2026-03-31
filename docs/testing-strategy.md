# Testing Strategy

## Overview

The project has two test targets: unit tests and UI tests. Together they cover the full vertical slice — from domain logic through to rendered UI — while keeping each layer fast and isolated.

| Target | Tests | Approach | Network | Database |
|---|---|---|---|---|
| `RandomUserCodingChallengeTests` | 31 | Protocol mocks, in-memory state | None | None |
| `RandomUserCodingChallengeUITests` | 16 | Page Object Model, StubAPIClient | None | In-memory SwiftData |

---

## Unit Tests

### Mocking Strategy

All external dependencies (API, repository) are defined as protocols in the Domain layer. Unit tests provide lightweight, in-memory implementations:

**`MockAPIClient`**
- Implements `RandomUserAPIClientProtocol`
- Exposes `usersToReturn: [User]` and `errorToThrow: Error?`
- Zero networking — returns or throws synchronously

**`MockUserRepository`**
- Implements `UserRepositoryProtocol`
- Stores users in a `[User]` array and deleted IDs in a `Set<String>`
- Exposes `errorToThrow: Error?` to simulate persistence failures

This approach means unit tests have no async I/O, no simulator requirement, and no SwiftData setup.

### Test Data

`User+Fixture.swift` provides `User.fixture(...)` — a factory method with all parameters defaulted. Tests only specify the fields that matter for the assertion being made:

```swift
User.fixture(id: "abc", firstName: "Alice")
```

### Test Classes

**`FetchUsersUseCaseTests`** — 8 tests

Covers the core orchestration logic in `FetchUsersUseCase`:

| Test | Verifies |
|---|---|
| `testFetchUsers_savesNewUsersFromAPI` | New users from the API are passed to the repository |
| `testFetchUsers_doesNotSaveDuplicates` | Users already in the store are not re-inserted |
| `testFetchUsers_doesNotSaveSoftDeletedUsers` | API users matching a deleted ID are silently skipped |
| `testFetchUsers_returnsAllStoredUsersAfterSaving` | The use case returns the full stored list, not just the new batch |
| `testFetchUsers_deduplicatesById` | Duplicate IDs within the same API response are collapsed |
| `testFetchUsers_emptyAPIResponseReturnsPreviousUsers` | An empty API page leaves existing data intact |
| `testFetchUsers_emptyStoreAndAPIReturnsEmpty` | Empty store + empty API → empty result |
| `testFetchUsers_propagatesAPIError` | API errors propagate to the caller |

**`DeleteUserUseCaseTests`** — 3 tests

| Test | Verifies |
|---|---|
| `testDeleteUser_marksUserAsDeleted` | Repository receives the correct user ID |
| `testDeleteUser_removesFromFetchedList` | A subsequent fetch no longer includes the deleted user |
| `testDeleteUser_propagatesRepositoryError` | Repository errors propagate to the caller |

**`FilterUsersUseCaseTests`** — 9 tests

| Test | Verifies |
|---|---|
| `testFilter_emptySearchTermReturnsAll` | Empty string → full list |
| `testFilter_whitespaceOnlyTermReturnsAll` | Whitespace-only input is treated as empty |
| `testFilter_matchesFirstName` | Partial case-insensitive match on first name |
| `testFilter_matchesLastName` | Partial case-insensitive match on last name |
| `testFilter_matchesEmail` | Partial case-insensitive match on email |
| `testFilter_isCaseInsensitive` | "ALICE" matches "alice" |
| `testFilter_partialMatchWorks` | "ali" matches "Alice" |
| `testFilter_returnsMultipleMatches` | Multiple matching users are all returned |
| `testFilter_noMatchReturnsEmpty` | Non-matching term → empty array |

**`UserListViewModelTests`** — 11 tests

These test the ViewModel in isolation using mocks for both use cases.

| Test | Verifies |
|---|---|
| `testLoadUsers_populatesUsers` | `users` is populated after `loadUsers()` |
| `testLoadUsers_setsLoadingStateDuringFetch` | `isLoading` is `true` during the async call |
| `testLoadUsers_setsErrorMessageOnFailure` | `errorMessage` is set when the use case throws |
| `testLoadUsers_accumulatesUsersAcrossCalls` | Subsequent loads append to the list |
| `testDeleteUser_removesUserFromList` | The deleted user is no longer in `users` |
| `testDeleteUser_callsDeleteUseCase` | The delete use case receives the correct user |
| `testDeleteUser_doesNotReappearAfterSearchClear` | A deleted user doesn't come back when search is cleared |
| `testSearch_filtersUsersByText` | `users` reflects the filtered result while `allUsers` is unchanged |
| `testSearch_emptyTextRestoresFullList` | Clearing search restores the full list |
| `testLoadUsers_clearsErrorOnSuccess` | A successful load clears a previous error message |
| `testLoadUsers_doesNotShowLoadingIfAlreadyLoading` | Concurrent load calls don't stack |

### Custom Assertion Helper

`XCTAssertThrowsErrorAsync` is provided in `User+Fixture.swift` to cleanly assert that an `async` throwing function throws with a specific error type:

```swift
await XCTAssertThrowsErrorAsync(try await useCase.execute()) { error in
    XCTAssertEqual(error as? MockError, .generic)
}
```

---

## UI Tests

UI tests use the **Page Object Model** to decouple test logic from XCUIElement queries.

### Test Environment

When the `--ui-testing` launch argument is present, `AppDependencies` injects:
- `StubAPIClient` — returns exactly 3 fixed users (Alice Smith, Bob Jones, Carol White)
- An in-memory `ModelContainer` — no state persists between test runs

This ensures UI tests are deterministic, fast, and require no network access.

### Page Objects

**`UserListScreen`**
Wraps the user list view. Provides:
- `waitForUsers()` — waits until at least one user cell appears
- `search(_ text:)` / `cancelSearch()` — drives the search bar
- `nameLabel(at:)`, `emailLabel(at:)`, `phoneLabel(at:)` — access cell content
- `openDetail(at:)` — navigates to the detail view, returns a `UserDetailScreen`
- `deleteUser(at:)` — performs the swipe-to-delete action

**`UserDetailScreen`**
Wraps the user detail view. Provides:
- `label(_ text:)` — checks for a specific text element
- `goBack()` — taps the back button, returns a `UserListScreen`

### UI Test Coverage

| Test | Verifies |
|---|---|
| Navigation bar title visible | App loads with correct title |
| Users appear after load | Stub data renders in the list |
| Email and phone visible in rows | Row layout is correct |
| Search by first name | Search filters correctly |
| Search by last name | Search filters correctly |
| Search by email | Search filters correctly |
| No results empty state | Empty state view appears |
| Clear search restores list | Cancelling search restores full list |
| Navigate to detail | Tapping a row opens detail |
| Detail view content | Name, email, location, registered date are visible |
| Back navigation | Back button returns to list |
| Delete a user | Swipe-to-delete removes the row |
| Deleted user doesn't reappear | After deletion, same user is not re-shown |
| Screenshot | Snapshot captured for visual reference |

---

## What Is Not Tested

- **Network integration** — `RandomUserAPIClient` is not tested against the live API. The contract is validated by the Decodable DTOs, and the behavior is covered by unit tests against `MockAPIClient`.
- **Pagination state** — `PaginationStore` and `UserDefaultsManager` do not have dedicated unit tests. `PaginationStore`'s behavior (seed generation, page increment, persistence across restarts) is exercised indirectly through the full app flow. Dedicated unit tests with a mock `UserDefaults` would be a straightforward addition.
- **SwiftData persistence** — `UserRepository` is not tested with a real `ModelContainer` in unit tests (the mock covers the protocol contract). UI tests exercise the in-memory `ModelContainer` end-to-end.
- **Image loading** — `AsyncImage` behavior is not asserted in UI tests. The stub users reference `example.com` URLs that return no image, but the placeholder renders correctly.
