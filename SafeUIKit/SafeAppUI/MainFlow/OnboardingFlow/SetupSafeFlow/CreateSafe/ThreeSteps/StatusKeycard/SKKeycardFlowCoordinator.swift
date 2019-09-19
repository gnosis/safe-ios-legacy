//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit
import MultisigWalletApplication

// SK prefix for the "Status Keycard"
class SKKeycardFlowCoordinator: FlowCoordinator {

    weak var mainFlowCoordinator: MainFlowCoordinator!
    var getInTouchCommand = GetInTouchCommand()

    var hidesSteps = false
    var removesKeycardOnGoingBack = true

    /// Will be called on background thread upon completion and before exiting the flow.
    /// The parameter is the address of the keycard owner.
    var onSucces: ((String) throws -> Void)?

    override func setUp() {
        super.setUp()
        saveCheckpoint()
        showIntro()
    }

    func showIntro() {
        push(SKIntroViewController.create { [unowned self] in
            self.push(SKPairViewController.create(delegate: self))
        })
    }

    func showSuccess(address: String) {
        var controller: SKPairingSuccessViewController!
        controller = SKPairingSuccessViewController.create(onNext: { [weak self, controller] in

            // set activity indicator
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            let activityItem = UIBarButtonItem(customView: activityIndicator)
            let navigationItem = controller?.navigationItem.rightBarButtonItem
            controller?.navigationItem.setRightBarButton(activityItem, animated: true)

            // start onSuccess
            DispatchQueue.global().async {
                do {
                    try self?.onSucces?(address)
                    DispatchQueue.main.async {
                        guard let `self` = self else { return }
                        controller?.navigationItem.setRightBarButton(navigationItem, animated: true)
                        self.exitFlow()
                    }
                } catch {
                    DispatchQueue.main.async {
                        guard self != nil else { return }
                        controller?.navigationItem.setRightBarButton(navigationItem, animated: true)
                        ErrorHandler.showError(message: error.localizedDescription,
                                               log: error.localizedDescription,
                                               error: nil)
                    }
                }
            }

        }, onRemove: { [unowned self] in
            self.popToLastCheckpoint()
        })
        controller.hidesStepView = hidesSteps
        controller.shouldRemoveOnBack = removesKeycardOnGoingBack
        push(controller)
    }
}

extension SKKeycardFlowCoordinator: SKPairViewControllerDelegate {

    func pairViewControllerDidPairSuccessfully(_ controller: SKPairViewController, address: String) {
        showSuccess(address: address)
    }

    func pairViewControllerNeedsInitialization(_ controller: SKPairViewController) {
        push(SKActivateViewController.create(delegate: self))
    }

    func pairViewControllerNeedsToGetInTouch(_ controller: SKPairViewController) {
        getInTouchCommand.run(mainFlowCoordinator: mainFlowCoordinator)
    }

}

extension SKKeycardFlowCoordinator: SKActivateViewControllerDelegate {

    func activateViewControllerDidActivate(_ controller: SKActivateViewController, address: String) {
        showSuccess(address: address)
    }

}
