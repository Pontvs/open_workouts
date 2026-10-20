import XCTest

@MainActor
final class LaunchTests: XCTestCase {
    func testLaunchShowsTabs() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10))
        XCTAssertTrue(tabBar.buttons["Start"].exists)
        XCTAssertTrue(tabBar.buttons["Statistics"].exists)
        XCTAssertTrue(tabBar.buttons["Settings"].exists)
    }
}
