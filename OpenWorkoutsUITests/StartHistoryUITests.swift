import XCTest

@MainActor
final class StartHistoryUITests: XCTestCase {
    private func launch(seedSamples: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"] + (seedSamples ? ["-seedSampleWorkouts"] : [])
        app.launch()
        return app
    }

    func testEmptyStateShown() {
        let app = launch()
        XCTAssertTrue(app.staticTexts["No workouts yet"].waitForExistence(timeout: 10))
    }

    func testSeeAllOpensHistoryAndBackWorks() {
        let app = launch()
        let seeAll = app.buttons["seeAllButton"]
        XCTAssertTrue(seeAll.waitForExistence(timeout: 10))
        seeAll.tap()

        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["No workouts yet"].waitForExistence(timeout: 5))

        app.navigationBars["History"].buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Start"].waitForExistence(timeout: 5))
    }

    func testNewWorkoutNavigatesAway() {
        let app = launch()
        let newWorkout = app.buttons["newWorkoutButton"]
        XCTAssertTrue(newWorkout.waitForExistence(timeout: 10))
        newWorkout.tap()

        // Start's footer button is covered once the workout screen is pushed.
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == false"), object: newWorkout)
        XCTAssertEqual(XCTWaiter().wait(for: [gone], timeout: 5), .completed)
    }

    func testSeededWorkoutsShowFiveOnStartAndAllSixInHistory() {
        let app = launch(seedSamples: true)
        XCTAssertTrue(app.buttons["seeAllButton"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.cells.count, 5)

        app.buttons["seeAllButton"].tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.cells.count, 6)
    }

    func testSwipeDeleteInHistoryRemovesWorkout() {
        let app = launch(seedSamples: true)
        XCTAssertTrue(app.buttons["seeAllButton"].waitForExistence(timeout: 10))
        app.buttons["seeAllButton"].tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.cells.count, 6)

        app.cells.firstMatch.swipeLeft()
        app.buttons["Delete"].firstMatch.tap()
        XCTAssertEqual(app.cells.count, 5)
    }
}
