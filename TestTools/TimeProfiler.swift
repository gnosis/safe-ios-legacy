//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

class TimeProfiler {

    typealias Point = (line: UInt, time: Date)
    typealias Diff = (current: Point, next: Point, diff: TimeInterval)
    let timeFormatter = NumberFormatter()
    var points = [Point]()

    init() {
        timeFormatter.numberStyle = .decimal
    }

    func checkpoint(line: UInt = #line) {
        points.append((line, Date()))
    }

    func summary() -> String {
        let diffs = (0..<points.count - 1).map { index -> Diff in
            let next = points[index + 1]
            let current = points[index]
            let diff = next.time.timeIntervalSinceReferenceDate - current.time.timeIntervalSinceReferenceDate
            return (current, next, diff)
            }.sorted { a, b -> Bool in
                a.diff > b.diff
            }.map { diff -> String in
                "\(diff.next.line)-\(diff.current.line): \(timeFormatter.string(from: NSNumber(value: diff.diff))!)"
        }
        return diffs.joined(separator: "\n")
    }
}
