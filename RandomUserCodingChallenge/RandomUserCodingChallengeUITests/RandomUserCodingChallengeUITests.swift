//
//  RandomUserCodingChallengeUITests.swift
//  RandomUserCodingChallengeUITests
//
//  Created by Laura Sales Martínez on 29/3/26.
//

import XCTest

final class RandomUserCodingChallengeUITests: XCTestCase {
    private var app: XCUIApplication!
    private var listScreen: UserListScreen!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        listScreen = UserListScreen(app: app)
    }

    override func tearDownWithError() throws {
        app = nil
        listScreen = nil
        try super.tearDownWithError()
    }

    // MARK: - User List

    func test_userList_displaysNavigationTitle() {
        XCTAssertTrue(listScreen.navigationBar.exists)
    }

    func test_userList_displaysUsers_afterLoading() {
        listScreen.waitForUsers()

        XCTAssertTrue(listScreen.nameLabel("Alice Smith").exists)
        XCTAssertTrue(listScreen.nameLabel("Bob Jones").exists)
        XCTAssertTrue(listScreen.nameLabel("Carol White").exists)
    }

    func test_userList_displaysEmailInRow() {
        listScreen.waitForUsers()

        XCTAssertTrue(listScreen.emailLabel("alice.smith@example.com").exists)
    }

    func test_userList_displaysPhoneInRow() {
        listScreen.waitForUsers()

        XCTAssertTrue(listScreen.phoneLabel("555-0101").exists)
    }

    // MARK: - Search

    func test_search_filtersByFirstName() {
        listScreen.waitForUsers()
        listScreen.search("Alice")

        XCTAssertTrue(listScreen.nameLabel("Alice Smith").exists)
        XCTAssertFalse(listScreen.nameLabel("Bob Jones").exists)
        XCTAssertFalse(listScreen.nameLabel("Carol White").exists)
    }

    func test_search_filtersByLastName() {
        listScreen.waitForUsers()
        listScreen.search("Jones")

        XCTAssertTrue(listScreen.nameLabel("Bob Jones").exists)
        XCTAssertFalse(listScreen.nameLabel("Alice Smith").exists)
        XCTAssertFalse(listScreen.nameLabel("Carol White").exists)
    }

    func test_search_filtersByEmail() {
        listScreen.waitForUsers()
        listScreen.search("carol.white")

        XCTAssertTrue(listScreen.nameLabel("Carol White").exists)
        XCTAssertFalse(listScreen.nameLabel("Alice Smith").exists)
        XCTAssertFalse(listScreen.nameLabel("Bob Jones").exists)
    }

    func test_search_showsEmptyState_whenNoResults() {
        listScreen.waitForUsers()
        listScreen.search("zzznomatch")

        XCTAssertTrue(listScreen.emptyStateLabel(containing: "No results for").waitForExistence(timeout: 2))
        XCTAssertFalse(listScreen.nameLabel("Alice Smith").exists)
    }

    func test_search_clearingText_restoresFullList() {
        listScreen.waitForUsers()
        listScreen.search("Alice")
        listScreen.cancelSearch()

        XCTAssertTrue(listScreen.firstCell.waitForExistence(timeout: 2))
        XCTAssertTrue(listScreen.nameLabel("Bob Jones").exists)
        XCTAssertTrue(listScreen.nameLabel("Carol White").exists)
    }

    // MARK: - Detail

    func test_navigation_tappingUser_opensDetailView() {
        listScreen.waitForUsers()
        let detailScreen = listScreen.openDetail(for: "Alice Smith")

        XCTAssertTrue(detailScreen.navigationBar.waitForExistence(timeout: 2))
    }

    func test_navigation_detailView_displaysEmail() {
        listScreen.waitForUsers()
        let detailScreen = listScreen.openDetail(for: "Alice Smith")

        XCTAssertTrue(detailScreen.label("alice.smith@example.com").waitForExistence(timeout: 2))
    }

    func test_navigation_detailView_displaysGender() {
        listScreen.waitForUsers()
        let detailScreen = listScreen.openDetail(for: "Alice Smith")

        XCTAssertTrue(detailScreen.label("Female").waitForExistence(timeout: 2))
    }

    func test_navigation_detailView_displaysLocation() {
        listScreen.waitForUsers()
        let detailScreen = listScreen.openDetail(for: "Alice Smith")

        XCTAssertTrue(detailScreen.label("1 Test Street, Barcelona, Catalonia").waitForExistence(timeout: 2))
    }

    func test_navigation_backButton_returnsToList() {
        listScreen.waitForUsers()
        let detailScreen = listScreen.openDetail(for: "Alice Smith")
        XCTAssertTrue(detailScreen.navigationBar.waitForExistence(timeout: 2))

        let returnedListScreen = detailScreen.goBack()

        XCTAssertTrue(returnedListScreen.navigationBar.waitForExistence(timeout: 2))
        XCTAssertTrue(returnedListScreen.nameLabel("Alice Smith").exists)
    }

    // MARK: - Delete

    func test_deleteUser_removesFromList() {
        listScreen.waitForUsers()
        listScreen.deleteUser(named: "Alice Smith")

        XCTAssertFalse(listScreen.nameLabel("Alice Smith").waitForExistence(timeout: 2))
        XCTAssertTrue(listScreen.nameLabel("Bob Jones").exists)
    }

    func test_deleteUser_multipleUsers() {
        listScreen.waitForUsers()
        listScreen.deleteUser(named: "Alice Smith")
        XCTAssertTrue(listScreen.nameLabel("Bob Jones").waitForExistence(timeout: 2))

        listScreen.deleteUser(named: "Bob Jones")

        XCTAssertFalse(listScreen.nameLabel("Alice Smith").waitForExistence(timeout: 2))
        XCTAssertFalse(listScreen.nameLabel("Bob Jones").exists)
        XCTAssertTrue(listScreen.nameLabel("Carol White").exists)
    }

    // MARK: - Screenshots

    func test_launch_screenshot() {
        listScreen.waitForUsers()

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Launch Screen"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
