//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import SafeUIKit

protocol SeedFlowControllerDelegate: class {

    func seedFlowControllerDidFinish(_ controller: SeedFlowController)

}

class SeedFlowController: FlowController, ShowSeedViewControllerDelegate, EnterSeedViewControllerDelegate {

    weak var delegate: SeedFlowControllerDelegate?
    var isPaired: Bool = false

    override var rootViewController: UIViewController? {
        let pairingState = isPaired ? ThreeStepsView.State.backup_paired : .backup_notPaired
        return SeedIntroViewController.create(state: pairingState) { [weak self] in
            self?.pushShowSeedController()
        }
    }

    func pushShowSeedController() {
        let vc = ShowSeedViewController.create(delegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: ShowSeedViewControllerDelegate

    func showSeedViewControllerDidPressContinue(_ controller: ShowSeedViewController) {
        guard !ApplicationServiceRegistry.walletService.isOwnerExists(.paperWallet) else {
            showSuccess()
            return
        }
        let enterSeedVC = EnterSeedViewController.create(delegate: self, account: controller.account!)
        navigationController?.pushViewController(enterSeedVC, animated: true)
    }

    // MARK: EnterSeedViewControllerDelegate

    func enterSeedViewControllerDidSubmit(_ vc: EnterSeedViewController) {
        showSuccess()
    }

    // MARK: Success

    func showSuccess() {
        let pairingState = isPaired ? ThreeStepsView.State.backupDone_paired : .backupDone_notPaired
        let controller = SeedSuccessViewController.create(state: pairingState) { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.seedFlowControllerDidFinish(self)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

}
