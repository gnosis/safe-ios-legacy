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

    enum Strings {
        static let qrScannerHeader = LocalizedString("scan_wallet_connect", comment: "Scan WalletConnect QR code")
    }

    override func setUp() {
        super.setUp()
        guard ApplicationServiceRegistry.walletConnectService.isAvaliable else {
            let message = LocalizedString("walletconnect_error_no_safe", comment: "WalletConnect not available")
            presentModally(UIAlertController.operationFailed(message: message))
            return
        }
        scanHandler.delegate = self
        scanHandler.header = Strings.qrScannerHeader
        if ApplicationServiceRegistry.walletConnectService.isOnboardingDone() {
            showScan()
        } else {
            showOnboarding()
        }
    }

    func showOnboarding() {
        let vc = OnboardingViewController.createWalletConnectOnboarding(next: { [weak self] in
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
            code.starts(with: "wc:") ? code : nil
        }
        scanHandler.scan()
    }

    func showSessionList(connectionURL: String) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
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
