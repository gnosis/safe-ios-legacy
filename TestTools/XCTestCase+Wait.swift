//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest

extension XCTestCase {

    func waitUntil(_ condition: @autoclosure () -> Bool,
                   timeout: TimeInterval = 1,
                   file: String = #file,
                   line: Int = #line) {
        var time: TimeInterval = 0
        let step: TimeInterval = 0.1
        let loop = RunLoop.current
        var result = condition()
        while !result && time < timeout {
            loop.run(until: Date().addingTimeInterval(step))
            time += step
            result = condition()
        }
        if !result {
            recordFailure(withDescription: "Waiting failed", inFile: file, atLine: line, expected: true)
        }
    }

    func waitUntil(_ element: XCUIElement,
                   timeout: TimeInterval = 15,
                   file: String = #file,
                   line: Int = #line,
                   _ conditions: Predicate ...) {
        let predicate = NSPredicate(format: conditions.map { $0.rawValue }.joined(separator: " AND "))
        let expectation = self.expectation(for: predicate, evaluatedWith: element, handler: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        switch result {
        case .completed:
            return
        default:
            recordFailure(withDescription: "Conditions \(predicate) failed for \(element) after \(timeout) seconds",
                inFile: file, atLine: line, expected: true)
        }
    }

}

func delay(_ delay: TimeInterval = 0.1) {
    RunLoop.current.run(until: Date(timeIntervalSinceNow: delay))
}

enum Predicate: String {
    case exists = "exists == true"
    case doesNotExist = "self.exists == false"
    case selected = "isSelected == true"
    case hittable = "isHittable == true"
    case notHittable = "isHittable == false"
}
