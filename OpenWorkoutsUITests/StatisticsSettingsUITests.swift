import XCTest

@MainActor
final class StatisticsSettingsUITests: XCTestCase {
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        return app
    }

    private func replaceText(_ element: XCUIElement, with text: String) {
        element.tap()
        let current = element.value as? String ?? ""
        element.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        element.typeText(text)
    }

    func testStatisticsEmptyStateAndSincePicker() {
        let app = launch()
        app.tabBars.buttons["Statistics"].tap()

        XCTAssertTrue(app.staticTexts["No workouts yet"].waitForExistence(timeout: 5))

        let picker = app.descendants(matching: .any)["sincePicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.tap()
        app.buttons["6 months"].tap()
        XCTAssertEqual(picker.value as? String, "6 months")
    }

    func testProfileValuesKeptAfterReturning() {
        let app = launch()
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Profile"].tap()

        let weight = app.textFields["weightField"]
        XCTAssertTrue(weight.waitForExistence(timeout: 5))
        replaceText(weight, with: "81")

        let goal = app.descendants(matching: .any)["goalField"]
        replaceText(goal, with: "Build strength")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["Profile"].tap()

        XCTAssertEqual(app.textFields["weightField"].value as? String, "81")
        XCTAssertEqual(app.descendants(matching: .any)["goalField"].value as? String, "Build strength")
    }

    func testExerciseAddEditDelete() {
        let app = launch()
        app.tabBars.buttons["Settings"].tap()
        app.buttons["Exercises"].tap()

        app.buttons["addExerciseToolbarButton"].tap()
        app.textFields["exerciseNameField"].tap()
        app.textFields["exerciseNameField"].typeText("Test Curl")
        app.switches["Enter per side"].tap()
        app.buttons["saveExerciseButton"].tap()

        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("Test Curl")
        XCTAssertTrue(app.staticTexts["Test Curl"].waitForExistence(timeout: 5))

        app.staticTexts["Test Curl"].tap()
        replaceText(app.textFields["exerciseNameField"], with: "Test Curl 2")
        app.buttons["saveExerciseButton"].tap()
        XCTAssertTrue(app.staticTexts["Test Curl 2"].waitForExistence(timeout: 5))

        let row = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "Test Curl 2")).firstMatch
        row.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.staticTexts["Test Curl 2"].waitForExistence(timeout: 2))
    }
}
