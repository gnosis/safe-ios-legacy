//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import CommonTestSupport

class SegmentBarTests: XCTestCase {

    let item = SegmentBarItem(title: "some")
    var bar = SegmentBar()
    var didReceiveTap = false

    func test_whenAddingItem_thenCanGetIt() {
        bar.items = [item]
        XCTAssertEqual(bar.items.first, item)
    }

    func test_whenSelectingItem_thenRetainsSelection() {
        bar.items = [item]
        bar.selectedItem = item
        XCTAssertEqual(bar.selectedItem, item)
    }

    func test_whenCreatingWithFrame_thenSetsUpViewContents() {
        bar = SegmentBar(frame: CGRect.zero)
        XCTAssertFalse(bar.subviews.isEmpty)
    }

    func test_whenCreatingWithCoder_thenSetsUpViewContents() {
        let bundle = Bundle(for: SegmentBarTests.self)
        bar = bundle.loadNibNamed("TestSegmentBarNib", owner: nil, options: nil)!.first as! SegmentBar
        XCTAssertFalse(bar.subviews.isEmpty)
    }

    func test_whenInitWithCoder_thenDoesNotCrash() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(self.bar, forKey: "bar")
        let bar = SegmentBar(coder: NSKeyedUnarchiver(forReadingWith: data as Data))
        XCTAssertNotNil(bar)
    }
    
    func test_whenTapsOnAButton_thenRecievesAction() {
        bar.items = [item, SegmentBarItem(title: "other")]
        bar.addTarget(self, action: #selector(didTap), for: .valueChanged)
        bar.buttons.first?.sendActions(for: .touchUpInside)
        delay()
        XCTAssertTrue(didReceiveTap)
        XCTAssertEqual(bar.selectedItem, bar.items.first)
    }

    func test_whenRemovingSelection_thenStaysUnselected() {
        bar.items = [item]
        bar.selectedItem = item
        bar.selectedItem = nil
        XCTAssertNil(bar.selectedItem)
    }

    func test_whenReplacingItems_thenReplacesContents() {
        bar.items = [item]
        let buttons = bar.buttons
        bar.items = [SegmentBarItem(title: "other")]
        let otherButtons = bar.buttons
        XCTAssertNotEqual(buttons, otherButtons)
    }

    @objc func didTap(sender: Any) {
        didReceiveTap = true
    }

}
