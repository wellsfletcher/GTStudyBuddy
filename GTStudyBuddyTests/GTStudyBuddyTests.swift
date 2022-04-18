//
//  GTStudyBuddyTests.swift
//  GTStudyBuddyTests
//
//  Created by Fletcher Wells on 3/8/22.
//

import XCTest
@testable import GTStudyBuddy

class GTStudyBuddyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testArraySubtract() throws {
        // both have Ringo and Paul
        let names1 = ["John", "Paul", "Ringo"]
        let names2 = ["George", "Paul", "Ringo"]// ["Ringo", "Paul", "George"]
        var difference = names1.subtract(from: names2) // should return John
        XCTAssertEqual(difference, ["John"]) // these are basically the that were both added and removed combineed together
        
        difference = names2.subtract(from: names1) // should return George
        XCTAssertEqual(difference, ["George"])
    }
}
