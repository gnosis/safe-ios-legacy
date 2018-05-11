//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class SetupSafeFlowCoordinator: FlowCoordinator {

    private let newSafeFlowCoordinator = NewSafeFlowCoordinator()

    public override init() {}

    public override func flowStartController() -> UIViewController {
        //      if not selected any safe - show setup screen
        //      else if selected is restore - show restore flow flow
        //      else if selected is new - show new safe flow
        let optionsVC = SetupSafeOptionsViewController.create(delegate: self)
    }

    public override func startViewController(parent: UINavigationController?) -> UIViewController {
        
    }

}

extension SetupSafeFlowCoordinator: SetupSafeOptionsDelegate {

    func didSelectNewSafe() {
        let startVC = newSafeFlowCoordinator.startViewController(parent: rootVC)
        rootVC.pushViewController(startVC, animated: true)
    }

}
