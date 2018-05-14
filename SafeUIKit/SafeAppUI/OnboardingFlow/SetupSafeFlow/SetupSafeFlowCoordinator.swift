//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class SetupSafeFlowCoordinator: FlowCoordinator {

    private let newSafeFlowCoordinator = NewSafeFlowCoordinator()

    override func setUp() {
        super.setUp()
        pushController(SetupSafeOptionsViewController.create(delegate: self))
    }
}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {
        transition(to: newSafeFlowCoordinator)
    }

}
