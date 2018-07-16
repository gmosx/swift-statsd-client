import XCTest
@testable import StatsdClient

final class StatsdClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(StatsdClient().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
