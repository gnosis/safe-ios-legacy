//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
@testable import SafeAppUI

class TestFlowCoordinator: FlowCoordinator {

    init() {
        super.init(rootViewController: UINavigationController())
    }

    var topViewController: UIViewController? {
        return navigationController.topViewController
    }
}
