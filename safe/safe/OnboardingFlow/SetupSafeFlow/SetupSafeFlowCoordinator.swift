//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit

final class SetupSafeFlowCoordinator {

    func startViewController() -> UIViewController {
        let vc = SetupSafeViewController()
        vc.view.backgroundColor = ColorName.green.color
        return vc
    }

}
