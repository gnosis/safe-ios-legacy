//
//  Copyright © 2020 Gnosis Ltd. All rights reserved.
//

import Foundation

final class LoadMultisigFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        let controller = LoadMultisigIntroViewController.create()
        push(controller)
    }

}
