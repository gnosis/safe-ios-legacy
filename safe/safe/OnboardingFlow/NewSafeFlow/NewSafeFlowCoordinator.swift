//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class NewSafeFlowCoordinator: FlowCoordinator {

    override func flowStartController() -> UIViewController {
        return PairWithChromeExtensionViewController()
    }

}
