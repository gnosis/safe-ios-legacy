//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import ReplaceBrowserExtensionUI

class RBEIntroViewControllerErrorStateTests: RBEIntroViewControllerBaseTestCase {

    func test_whenError_thenShowsAlert() {
        vc.transition(to: RBEIntroViewController.ErrorState(error: FeeCalculationError.insufficientBalance))
    }

}
