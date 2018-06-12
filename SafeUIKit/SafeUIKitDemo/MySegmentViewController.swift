//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI

class MySegmentViewController: SegmentBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let oneSeg = MySegment()
        oneSeg.segmentItem = SegmentBarItem(title: "Hello")
        let twoSeg = MySegment()
        
        twoSeg.segmentItem = SegmentBarItem(title: "Bye")
        viewControllers = [oneSeg, twoSeg]
        selectedViewController = oneSeg
    }

}

class MySegment: UIViewController, SegmentController {
    var segmentItem = SegmentBarItem(title: "hello")
}
