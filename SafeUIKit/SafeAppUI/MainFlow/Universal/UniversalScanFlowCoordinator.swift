//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import Foundation
import MultisigWalletApplication
import SafeUIKit
import BigInt

class UniversalScanFlowCoordinator: FlowCoordinator {
    public static let shared = UniversalScanFlowCoordinator()
    weak var onboardingController: OnboardingViewController?
    weak var sessionListController: WCSessionListTableViewController?
    var scanHandler = ScanQRCodeHandler()

    override func setUp() {
        super.setUp()
        guard ApplicationServiceRegistry.walletConnectService.isAvaliable else {
            let message = LocalizedString("walletconnect_error_no_safe", comment: "WalletConnect not available")
            presentModally(UIAlertController.operationFailed(message: message))
            return
        }
        scanHandler.delegate = self
        if ApplicationServiceRegistry.walletConnectService.isOnboardingDone() {
            showScan()
        } else {
            showOnboarding()
        }
    }

    func showOnboarding() {
        let vc = OnboardingViewController.create(next: { [weak self] in
            self?.onboardingController?.transitionToNextPage()
        }, finish: { [weak self] in
            self?.finishOnboarding()
        })
        push(vc)
        onboardingController = vc
    }

    func finishOnboarding() {
        ApplicationServiceRegistry.walletConnectService.markOnboardingDone()
        showScan()
        removeViewControllerFromNavigationStack(onboardingController)
    }

    func showScan() {
        scanHandler.scanValidatedConverter = { code in
            guard code.starts(with: "wc:") else { return nil }
            return code
        }
        scanHandler.scan()
    }

    func showSessionList(connectionURL: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let vc = WCSessionListTableViewController(connectionURL: URL(string: connectionURL))
            self.sessionListController = vc
            MainFlowCoordinator.shared.popToLastCheckpoint()
            self.push(self.sessionListController!)
        }
    }
}

extension UniversalScanFlowCoordinator: ScanQRCodeHandlerDelegate {

    func presentController(_ controller: UIViewController) {
        rootViewController.present(controller, animated: true, completion: nil)
    }

    func didScanCode(raw: String, converted: String?) {
        showSessionList(connectionURL: raw)
    }

}

fileprivate extension OnboardingViewController {
    static func create(next: @escaping () -> Void, finish: @escaping () -> Void) -> OnboardingViewController {
        let nextActionTitle = LocalizedString("next", comment: "Next")
        return .create(steps: [
            .init(image: Asset._1.image,
                  title: LocalizedString("welcome_to_walletconnect", comment: "Onboarding 1 title"),
                  description: LocalizedString("walletconnect_is", comment: "Onboarding 1 description"),
                  actionTitle: nextActionTitle,
                  trackingEvent: WCTrackingEvent.onboarding1,
                  action: next),
            .init(image: Asset._2.image,
                  title: LocalizedString("how_does_it_work", comment: "Onboarding 2 title"),
                  description: LocalizedString("you_can_manage_connections", comment: "Onboarding 2 description"),
                  actionTitle: nextActionTitle,
                  trackingEvent: WCTrackingEvent.onboarding2,
                  action: next),
            .init(image: Asset._3.image,
                  title: LocalizedString("lets_get_started", comment: "Onboarding 3 title"),
                  description: LocalizedString("to_connect_to_dapp", comment: "Onboarding 3 description"),
                  actionTitle: LocalizedString("get_started", comment: "Start button title"),
                  trackingEvent: WCTrackingEvent.onboarding3,
                  action: finish)
        ])
    }

}
