//
//  UserListScreen.swift
//  RandomUserCodingChallengeUITests
//
//  Created by Laura Sales Martínez on 31/3/26.
//

import XCTest

struct UserListScreen {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    var navigationBar: XCUIElement { app.navigationBars["Random Users"] }
    var searchField: XCUIElement { app.searchFields.firstMatch }
    var firstCell: XCUIElement { app.cells.firstMatch }

    func nameLabel(_ name: String) -> XCUIElement { app.staticTexts[name] }
    func emailLabel(_ email: String) -> XCUIElement { app.staticTexts[email] }
    func phoneLabel(_ phone: String) -> XCUIElement { app.staticTexts[phone] }

    func emptyStateLabel(containing text: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", text)).firstMatch
    }

    @discardableResult
    func waitForUsers(timeout: TimeInterval = 3) -> Self {
        XCTAssertTrue(firstCell.waitForExistence(timeout: timeout))
        return self
    }

    @discardableResult
    func search(_ text: String) -> Self {
        searchField.tap()
        searchField.typeText(text)
        return self
    }

    @discardableResult
    func cancelSearch() -> Self {
        app.buttons["Cancel"].tap()
        return self
    }

    func openDetail(for name: String) -> UserDetailScreen {
        app.staticTexts[name].tap()
        return UserDetailScreen(app: app, userName: name)
    }

    @discardableResult
    func deleteUser(named name: String) -> Self {
        app.cells.containing(.staticText, identifier: name).firstMatch.swipeLeft()
        app.buttons["Delete"].tap()
        return self
    }
}
