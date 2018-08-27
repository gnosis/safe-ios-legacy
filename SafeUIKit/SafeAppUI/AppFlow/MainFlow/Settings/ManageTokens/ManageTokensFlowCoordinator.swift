//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ManageTokensFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        let manageTokensVC = ManageTokensTableViewController()
        push(manageTokensVC)
    }

}
