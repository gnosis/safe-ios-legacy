//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class WCFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        push(WCSessionListViewController())
    }

}
