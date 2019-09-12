//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import MultisigWalletApplication

class SKPairingSuccessViewController: NewSafeThreeStepsBaseController {

    let pairSuccessView = SKPairSuccessView()
    var backButtonItem: UIBarButtonItem!

    private var onRemove: (() -> Void)!

    static func create(onNext: @escaping () -> Void, onRemove: @escaping () -> Void) -> SKPairingSuccessViewController {
        let controller = SKPairingSuccessViewController(nibName: String(describing: CardViewController.self),
                                                        bundle: Bundle(for: CardViewController.self))
        controller.onNext = onNext
        controller.onRemove = onRemove
        controller.backButtonItem = UIBarButtonItem.backButton(target: self, action: #selector(back))
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = LocalizedString("pair_2fa_device", comment: "Pair 2FA device")

        embed(view: pairSuccessView, inCardSubview: cardHeaderView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingTrackingEvent.pairSuccess)
    }

    override func willMove(toParent parent: UIViewController?) {
        setCustomBackButton(backButtonItem)
    }

    @objc func back() {
        let alert = UIAlertController.create(title: LocalizedString("remove_paired", comment: "Remove?"),
                                             message: LocalizedString("paired_will_be_lost", comment: "You'll remove"))
            .withCloseAction()
            .withDestructiveAction(title: LocalizedString("remove", comment: "Remove")) { [unowned self] in
                ApplicationServiceRegistry.keycardService.removeKeycard()
                self.onRemove()
        }
        present(alert, animated: true)
    }

}

extension SKPairingSuccessViewController: InteractivePopGestureResponder {

    func interactivePopGestureShouldBegin() -> Bool {
        return false
    }

}
