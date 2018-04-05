//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class SetupSafeFlowCoordinator: FlowCoordinator {

    override func flowStartController() -> UIViewController {
        let vc = SetupSafeOptionsViewController()
        vc.view.backgroundColor = ColorName.green.color
        return vc
    }

}
