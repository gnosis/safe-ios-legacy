//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit

// SK prefix for the "Status Keycard"
class SKKeycardFlowCoordinator: FlowCoordinator {

    weak var mainFlowCoordinator: MainFlowCoordinator!
    var getInTouchCommand = GetInTouchCommand()

    override func setUp() {
        super.setUp()
        saveCheckpoint()
        push(SKPairViewController.create(delegate: self))
    }

    func showSuccess() {
        push(SKPairingSuccessViewController.create(onNext: { [unowned self] in
            self.exitFlow()
        }, onRemove: { [unowned self] in
            self.popToLastCheckpoint()
        }))
    }
}

extension SKKeycardFlowCoordinator: SKPairViewControllerDelegate {

    func pairViewControllerDidPairSuccessfully(_ controller: SKPairViewController) {
        showSuccess()
    }

    func pairViewControllerNeedsInitialization(_ controller: SKPairViewController) {
        push(SKActivateViewController.create(delegate: self))
    }

    func pairViewControllerNeedsToGetInTouch(_ controller: SKPairViewController) {
        getInTouchCommand.run(mainFlowCoordinator: mainFlowCoordinator)
    }

}

extension SKKeycardFlowCoordinator: SKActivateViewControllerDelegate {

    func activateViewControllerDidActivate(_ controller: SKActivateViewController) {
        showSuccess()
    }

}
