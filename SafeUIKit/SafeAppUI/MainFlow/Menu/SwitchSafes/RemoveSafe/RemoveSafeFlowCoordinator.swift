//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class RemoveSafeFlowCoordinator: FlowCoordinator {

    var safeAddress: String!

    override func setUp() {
        super.setUp()
        push(removeSafeIntro())
    }

    private func removeSafeIntro() -> UIViewController {
        return RemoveSafeIntroViewController.create(address: safeAddress) { [unowned self] in
            self.push(self.confirmSafeEnterSeed())
        }
    }

    private func confirmSafeEnterSeed() -> UIViewController {
        return UIViewController()
    }

}
