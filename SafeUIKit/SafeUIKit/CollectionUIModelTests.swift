//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class TableViewModelTests: XCTestCase {

    let sectionIndex = 0
    let itemIndex = 0
    let sectionOutOfBounds = 9
    let itemOutOfBounds = 3
    let anyItemIndex = 999
    let oneElement = CollectionUIModel<[String]>([["one"]])
    let empty = CollectionUIModel<[String]>()

    func test_getSection() {
        XCTAssertEqual(oneElement[sectionIndex], ["one"])
        XCTAssertEqual(oneElement[section: IndexPath(row: itemIndex, section: sectionIndex)], ["one"])
    }

    func test_getItem() {
        XCTAssertEqual(oneElement[sectionIndex, itemIndex], "one")
        XCTAssertEqual(oneElement[IndexPath(row: itemIndex, section: sectionIndex)], "one")
        XCTAssertEqual(oneElement[IndexPath(item: itemIndex, section: sectionIndex)], "one")
    }

    func test_getSection_outOfBounds() {
        XCTAssertEqual(oneElement[sectionOutOfBounds], nil)
        XCTAssertEqual(oneElement[section: IndexPath(row: anyItemIndex, section: sectionOutOfBounds)], nil)
    }

    func test_getItem_outOfBounds() {
        XCTAssertEqual(oneElement[sectionIndex, itemOutOfBounds], nil)
        XCTAssertEqual(oneElement[sectionOutOfBounds, itemIndex], nil)

        XCTAssertEqual(oneElement[IndexPath(row: itemOutOfBounds, section: sectionIndex)], nil)
        XCTAssertEqual(oneElement[IndexPath(row: itemIndex, section: sectionOutOfBounds)], nil)

        XCTAssertEqual(oneElement[IndexPath(item: itemOutOfBounds, section: sectionIndex)], nil)
        XCTAssertEqual(oneElement[IndexPath(item: itemIndex, section: sectionOutOfBounds)], nil)
    }

    func test_count() {
        XCTAssertFalse(oneElement.isEmpty)
        XCTAssertTrue(empty.isEmpty)
        XCTAssertEqual(oneElement.sectionCount, 1)
        XCTAssertEqual(oneElement.itemCount(section: sectionIndex), 1)
        XCTAssertEqual(oneElement.itemCount(section: sectionOutOfBounds), NSNotFound)
        XCTAssertEqual(oneElement.itemCount(indexPath: IndexPath(row: anyItemIndex, section: sectionIndex)), 1)
        XCTAssertEqual(oneElement.itemCount(indexPath: IndexPath(item: anyItemIndex, section: sectionIndex)), 1)
        XCTAssertEqual(oneElement.itemCount(indexPath: IndexPath(row: anyItemIndex, section: sectionOutOfBounds)),
                       NSNotFound)
        XCTAssertEqual(oneElement.itemCount(indexPath: IndexPath(item: anyItemIndex, section: sectionOutOfBounds)),
                       NSNotFound)
    }

}
