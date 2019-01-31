//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI

class MyError: Error {}

class RBEIntroViewControllerBaseTestCase: XCTestCase {

    let vc = RBEIntroViewController.create()

    override func setUp() {
        super.setUp()
        vc.loadViewIfNeeded()
    }

}
