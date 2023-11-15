import XCTest

final class SwiftUINavControllerExampleUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPushPop() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))

        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(app, ["/", "/route1(autoPop: false)", "/"])
    }

    func testPushPopBeforeDidShow() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        app.buttons["Push 1 (auto pop)"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(app, ["/", "/route1(autoPop: true)", "/"])

        // check that navigation still works after auto pop

        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))

        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(app, ["/", "/route1(autoPop: true)", "/", "/route1(autoPop: false)", "/"])
    }

    func testPushPopPath() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))

        app.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(app, ["/", "/route1(autoPop: false)", "/"])

        // check that navigation still works after back button tap

        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))

        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(app, ["/", "/route1(autoPop: false)", "/", "/route1(autoPop: false)", "/"])
    }

    func testReplacePathEmpty() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        app.buttons["Replace 3, 4"].tap()
        XCTAssertTrue(app.staticTexts["Route 4"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route3",
                "/route3/route4",
            ])

        // check that navigation still works

        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Route 3"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))
        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route3",
                "/route3/route4",
                "/route3",
                "/",
                "/route1(autoPop: false)",
                "/",
            ])
    }

    func testReplaceRoutesEmpty() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))

        app.buttons["Push 2"].tap()
        XCTAssertTrue(app.staticTexts["Route 2"].waitForExistence(timeout: 5))

        app.buttons["Replace 3, 4"].tap()
        XCTAssertTrue(app.staticTexts["Route 4"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route2",
                "/route1(autoPop: false)",
                "/",
                "/route3",
                "/route3/route4",
            ])

        // check that navigation still works

        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Route 3"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))
        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route2",
                "/route1(autoPop: false)",
                "/",
                "/route3",
                "/route3/route4",
                "/route3",
                "/",
                "/route1(autoPop: false)",
                "/",
            ])
    }

    func testReplaceRoutesNoChange() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))

        app.buttons["Push 2"].tap()
        XCTAssertTrue(app.staticTexts["Route 2"].waitForExistence(timeout: 5))

        app.buttons["Replace 1, 2"].tap()
        sleep(2)
        XCTAssertTrue(app.staticTexts["Route 2"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route2",
            ])

        // check that navigation still works

        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))
        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route2",
                "/route1(autoPop: false)",
                "/",
                "/route1(autoPop: false)",
                "/",
            ])
    }

    func testReplaceRoutesChangeLast() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))

        app.buttons["Push 2"].tap()
        XCTAssertTrue(app.staticTexts["Route 2"].waitForExistence(timeout: 5))

        app.buttons["Replace 1, 3"].tap()
        XCTAssertTrue(app.staticTexts["Route 3"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route2",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route3",
            ])

        // check that navigation still works

        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))
        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route2",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route3",
                "/route1(autoPop: false)",
                "/",
                "/route1(autoPop: false)",
                "/",
            ])
    }

    func testPushMultiWaitForDidShow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["push1push2"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Route 2"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route2",
            ])

        // check that navigation still works

        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))
        app.buttons["Push 1"].tap()
        XCTAssertTrue(app.staticTexts["Route 1"].waitForExistence(timeout: 5))
        app.buttons["Pop"].tap()
        XCTAssertTrue(app.staticTexts["Root"].waitForExistence(timeout: 5))

        assertHistory(
            app,
            [
                "/",
                "/route1(autoPop: false)",
                "/route1(autoPop: false)/route2",
                "/route1(autoPop: false)",
                "/",
                "/route1(autoPop: false)",
                "/",
            ])
    }

    private func assertHistory(
        _ app: XCUIApplication, _ entries: [String], file: StaticString = #file, line: UInt = #line
    ) {
        let expectedText = "History:\n" + entries.joined(separator: "\n")

        let element = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH 'History:'"))
            .element

        XCTAssertTrue(element.waitForExistence(timeout: 5), file: file, line: line)

        let _ = waitFor { element.label == expectedText }

        XCTAssertEqual(element.label, expectedText, file: file, line: line)
    }

    private func waitFor(
        _ check: () -> Bool, intervalSeconds: Double = 0.01, timeoutSeconds: Double = 5
    ) -> Bool {
        var waitedSeconds: Double = 0

        while waitedSeconds < timeoutSeconds {
            if check() {
                return true
            }

            usleep(UInt32(intervalSeconds / 1_000_000))

            waitedSeconds += intervalSeconds
        }

        return false
    }
}
