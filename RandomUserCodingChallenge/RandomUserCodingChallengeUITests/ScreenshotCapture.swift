//
//  ScreenshotCapture.swift
//  RandomUserCodingChallengeUITests
//
//  Captures screenshots to docs/screenshots. Run manually to refresh docs imagery.
//

import XCTest

final class ScreenshotCapture: XCTestCase {
    private var app: XCUIApplication!
    private var listScreen: UserListScreen!

    private static let outputDir: String = URL(fileURLWithPath: #file)  // .../UITests/ScreenshotCapture.swift
        .deletingLastPathComponent()                                    // .../UITests/
        .deletingLastPathComponent()                                    // .../RandomUserCodingChallenge/ (Xcode project)
        .deletingLastPathComponent()                                    // .../random-user-coding-challenge/ (repo root)
        .appendingPathComponent("docs/screenshots")
        .path

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

    func test_capture_allScreenshots() throws {
        listScreen.waitForUsers()

        save(name: "01-user-list-stub")

        let detail = listScreen.openDetail(for: "Alice Smith")
        XCTAssertTrue(detail.navigationBar.waitForExistence(timeout: 3))
        save(name: "02-user-detail")

        listScreen = detail.goBack()
        listScreen.waitForUsers()

        listScreen.search("alice")
        save(name: "03-search-results")

        listScreen.cancelSearch()
        listScreen.search("zzznomatch")
        save(name: "04-search-empty")

        listScreen.cancelSearch()
        listScreen.waitForUsers()

        listScreen.revealDeleteButton(named: "Alice Smith")
        save(name: "05-before-delete")

        listScreen.confirmDelete()
        save(name: "06-after-delete")
    }

    private func save(name: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: Self.outputDir).appendingPathComponent("\(name).png")
        try? png.write(to: url)
    }
}
