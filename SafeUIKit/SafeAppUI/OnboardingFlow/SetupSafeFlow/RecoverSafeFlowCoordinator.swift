//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class RecoverSafeFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        push(GuidelinesViewController.createRecoverSafeGuidelines(delegate: self))
    }

}

extension RecoverSafeFlowCoordinator: GuidelinesViewControllerDelegate {

    func didPressNext() {
        push(AddressInputViewController.create(delegate: self))
    }

}

extension RecoverSafeFlowCoordinator: AddressInputViewControllerDelegate {

    func addressInputViewControllerDidPressNext() {
        push(RecoveryPhraseInputViewController.create(delegate: self))
    }

}

extension RecoverSafeFlowCoordinator: RecoveryPhraseInputViewControllerDelegate {

    func recoveryPhraseInputViewControllerDidPressNext() {
    }

}
