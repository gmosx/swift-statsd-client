import XCTest

import StatsdClientTests

var tests = [XCTestCaseEntry]()
tests += StatsdClientTests.allTests()
XCTMain(tests)