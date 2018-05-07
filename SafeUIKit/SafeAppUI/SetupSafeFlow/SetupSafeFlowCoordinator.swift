//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class SetupSafeFlowCoordinator: FlowCoordinator {

    private let newSafeFlowCoordinator = NewSafeFlowCoordinator()

    public override init() {}

    public override func flowStartController() -> UIViewController {
        return SetupSafeOptionsViewController.create(delegate: self)
    }

}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {
        let startVC = newSafeFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(startVC, animated: true)
    }

}
