//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
@testable import ReplaceBrowserExtensionUI

class TestableRBEIntroViewController: RBEIntroViewController {

    var spy_presentedViewController: UIViewController?
    var spy_back_invoked: Bool = false
    var spy_start_invoked: Bool = false
    var spy_retry_invoked: Bool = false

    static func createTestable() -> TestableRBEIntroViewController {
        return TestableRBEIntroViewController(nibName: "\(RBEIntroViewController.self)", bundle: Bundle(for: RBEIntroViewController.self))
    }

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        spy_presentedViewController = viewControllerToPresent
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    override func back() {
        spy_back_invoked = true
        super.back()
    }

    override func start() {
        spy_start_invoked = true
        super.start()
    }

    override func retry() {
        spy_retry_invoked = true
        super.retry()
    }
    
}
