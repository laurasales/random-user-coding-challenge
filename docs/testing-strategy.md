# Testing Strategy

## Overview

The project has two test targets: unit tests and UI tests. Together they cover the full vertical slice — from domain logic through to rendered UI — while keeping each layer fast and isolated.

| Target | Tests | Approach | Network | Database |
|---|---|---|---|---|
| `RandomUserCodingChallengeTests` | 34 | Protocol mocks, in-memory state | None | None |
| `RandomUserCodingChallengeUITests` | 17 | Page Object Model, StubAPIClient | None | In-memory SwiftData |

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

**`FetchUsersUseCaseTests`** — 9 tests

Covers the core orchestration logic in `FetchUsersUseCase`:

| Test | Verifies |
|---|---|
| `test_execute_savesNewUsersFromAPI` | New users from the API are passed to the repository |
| `test_execute_doesNotSaveDuplicateUsers` | Users already in the store are not re-inserted |
| `test_execute_doesNotSaveDeletedUsers` | API users matching a deleted ID are silently skipped |
| `test_execute_returnsAllStoredUsersAfterSaving` | The use case returns the full stored list, not just the new batch |
| `test_execute_savesOnlyNewUsersWhenMixedWithDuplicates` | Duplicate IDs within the same API response are collapsed |
| `test_execute_emptyAPIResponse_returnsExistingStoredUsers` | An empty API page leaves existing data intact |
| `test_execute_emptyStoreAndEmptyAPI_returnsEmpty` | Empty store + empty API → empty result |
| `test_execute_propagatesAPIError` | API errors propagate to the caller |
| `test_execute_skipsAllDeletedUsersFromMultipleBatches` | All deleted IDs in a multi-user batch are skipped; only non-deleted users are saved |

**`DeleteUserUseCaseTests`** — 3 tests

| Test | Verifies |
|---|---|
| `test_execute_marksUserAsDeletedInRepository` | Repository receives the correct user ID |
| `test_execute_removesUserFromStoredUsers` | The deleted user is removed from stored users |
| `test_execute_propagatesRepositoryError` | Repository errors propagate to the caller |

**`FilterUsersUseCaseTests`** — 10 tests

| Test | Verifies |
|---|---|
| `test_execute_emptySearchTerm_returnsAllUsers` | Empty string → full list |
| `test_execute_whitespaceSearchTerm_returnsAllUsers` | Whitespace-only input is treated as empty |
| `test_execute_emptyUsersList_returnsEmpty` | Empty user list with any search term → empty result |
| `test_execute_filtersByFirstName` | Partial case-insensitive match on first name |
| `test_execute_filtersByLastName` | Partial case-insensitive match on last name |
| `test_execute_filtersByEmail` | Partial case-insensitive match on email |
| `test_execute_isCaseInsensitive` | "ALICE" matches "alice" |
| `test_execute_partialMatch_returnsMatchingUsers` | "ali" matches "Alice" |
| `test_execute_searchTermMatchesMultipleUsers` | Multiple matching users are all returned |
| `test_execute_noMatch_returnsEmpty` | Non-matching term → empty array |

**`UserListViewModelTests`** — 12 tests

These test the ViewModel in isolation using real use case instances backed by mocks.

| Test | Verifies |
|---|---|
| `test_loadUsers_populatesUsers` | `users` is populated after `loadUsers()` |
| `test_loadUsers_isLoadingFalse_afterSuccess` | `isLoading` is `false` after a successful load |
| `test_loadUsers_isLoadingFalse_afterFailure` | `isLoading` is `false` after a failed load |
| `test_loadUsers_setsErrorMessage_onFailure` | `errorMessage` is set when the use case throws |
| `test_loadUsers_clearsErrorMessage_onSuccess` | A successful load clears a previous error message |
| `test_loadUsers_accumulatesUsersAcrossCalls` | Subsequent loads append to the list |
| `test_deleteUser_removesUserFromList` | The deleted user is no longer in `users` |
| `test_deleteUser_onlyRemovesTargetUser` | Only the specified user is removed; others remain |
| `test_deleteUser_marksUserAsDeleted_inRepository` | The repository receives the deleted user ID |
| `test_deleteUser_doesNotReappear_afterClearingSearch` | A deleted user doesn't come back when search is cleared |
| `test_searchText_filtersUsers` | Setting `searchText` filters `users` immediately |
| `test_searchText_empty_showsAllUsers` | Clearing `searchText` restores the full list |

### Custom Assertion Helper

`XCTAssertThrowsErrorAsync` is defined as a free function at the bottom of `FetchUsersUseCaseTests.swift` to cleanly assert that an `async` throwing function throws:

```swift
await XCTAssertThrowsErrorAsync(try await useCase.execute())
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
| `test_userList_displaysNavigationTitle` | App loads with correct title |
| `test_userList_displaysUsers_afterLoading` | Stub data renders in the list |
| `test_userList_displaysEmailInRow` | Email is visible in list rows |
| `test_userList_displaysPhoneInRow` | Phone is visible in list rows |
| `test_search_filtersByFirstName` | Search filters by first name |
| `test_search_filtersByLastName` | Search filters by last name |
| `test_search_filtersByEmail` | Search filters by email |
| `test_search_showsEmptyState_whenNoResults` | Empty state view appears for no matches |
| `test_search_clearingText_restoresFullList` | Cancelling search restores full list |
| `test_navigation_tappingUser_opensDetailView` | Tapping a row opens detail |
| `test_navigation_detailView_displaysEmail` | Email is visible in detail view |
| `test_navigation_detailView_displaysGender` | Gender is visible in detail view |
| `test_navigation_detailView_displaysLocation` | Location is visible in detail view |
| `test_navigation_backButton_returnsToList` | Back button returns to list |
| `test_deleteUser_removesFromList` | Swipe-to-delete removes the row |
| `test_deleteUser_multipleUsers` | Deleting several users in sequence works correctly |
| `test_launch_screenshot` | Snapshot captured for visual reference |

---

## What Is Not Tested

- **Network integration** — `RandomUserAPIClient` is not tested against the live API. The contract is validated by the Decodable DTOs, and the behavior is covered by unit tests against `MockAPIClient`.
- **Pagination state** — `PaginationStore` and `UserDefaultsManager` do not have dedicated unit tests. `PaginationStore`'s behavior (seed generation, page increment, persistence across restarts) is exercised indirectly through the full app flow. Dedicated unit tests with a mock `UserDefaults` would be a straightforward addition.
- **SwiftData persistence** — `UserRepository` is not tested with a real `ModelContainer` in unit tests (the mock covers the protocol contract). UI tests exercise the in-memory `ModelContainer` end-to-end.
- **Image loading** — `AsyncImage` behavior is not asserted in UI tests. The stub users reference `example.com` URLs that return no image, but the placeholder renders correctly.
