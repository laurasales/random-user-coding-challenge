//
//  UserDetailScreen.swift
//  RandomUserCodingChallengeUITests
//
//  Created by Laura Sales Martínez on 31/3/26.
//

import XCTest

struct UserDetailScreen {
    private let app: XCUIApplication
    let userName: String

    init(app: XCUIApplication, userName: String) {
        self.app = app
        self.userName = userName
    }

    var navigationBar: XCUIElement { app.navigationBars[userName] }

    func label(_ text: String) -> XCUIElement { app.staticTexts[text] }

    func goBack() -> UserListScreen {
        app.navigationBars.buttons.firstMatch.tap()
        return UserListScreen(app: app)
    }
}
