//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import IdentityAccessApplication
import Common

open class MainFlowCoordinator: FlowCoordinator {

    private let manageTokensFlowCoordinator = ManageTokensFlowCoordinator()
    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let sendFlowCoordinator = SendFlowCoordinator()
    let newSafeFlowCoordinator = CreateSafeFlowCoordinator()
    let recoverSafeFlowCoordinator = RecoverSafeFlowCoordinator()
    let incomingTransactionFlowCoordinator = IncomingTransactionFlowCoordinator()

    private var lockedViewController: UIViewController!

    private let transactionSubmissionHandler = TransactionSubmissionHandler()

    private var applicationRootViewController: UIViewController? {
        get { return UIApplication.shared.keyWindow?.rootViewController }
        set { UIApplication.shared.keyWindow?.rootViewController = newValue }
    }

    public init() {
        super.init(rootViewController: CustomNavigationController())
        configureGloabalAppearance()
        newSafeFlowCoordinator.mainFlowCoordinator = self
        recoverSafeFlowCoordinator.mainFlowCoordinator = self
    }

    private func configureGloabalAppearance() {
        UIButton.appearance().tintColor = ColorName.darkSkyBlue.color
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = nil

        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.barTintColor = .white
        navBarAppearance.tintColor = ColorName.darkSkyBlue.color
        navBarAppearance.isTranslucent = false
        navBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navBarAppearance.shadowImage = Asset.shadow.image
    }

    // Entry point to the app
    open override func setUp() {
        super.setUp()
        appDidFinishLaunching()
    }

    func appDidFinishLaunching() {
        if !ApplicationServiceRegistry.authenticationService.isUserRegistered {
            push(OnboardingWelcomeViewController.create(delegate: self))
            applicationRootViewController = rootViewController
            return
        } else if ApplicationServiceRegistry.walletService.isSafeCreationInProgress {
            didSelectNewSafe()
        } else if ApplicationServiceRegistry.recoveryService.isRecoveryInProgress() {
            didSelectRecoverSafe()
        } else {
            switchToRootController()
        }
        requestToUnlockApp()
    }

    func switchToRootController() {
        let nextController: UIViewController
        if ApplicationServiceRegistry.walletService.hasReadyToUseWallet {
            let mainVC = MainViewController.create(delegate: self)
            mainVC.navigationItem.backBarButtonItem = .backButton()
            nextController = mainVC

        } else {
            nextController = OnboardingCreateOrRestoreViewController.create(delegate: self)
        }
        navigationController.setViewControllers([nextController], animated: false)
    }


    func requestToUnlockApp(useUIApplicationRoot: Bool = false) {
        lockedViewController = useUIApplicationRoot ? applicationRootViewController : rootViewController
        applicationRootViewController = UnlockViewController.create { [unowned self] success in
            if !success { return }
            self.applicationRootViewController = self.lockedViewController
        }
    }

    open func appEntersForeground() {
        if ApplicationServiceRegistry.authenticationService.isUserRegistered &&
            !ApplicationServiceRegistry.authenticationService.isUserAuthenticated &&
            !(applicationRootViewController is UnlockViewController) {
            requestToUnlockApp(useUIApplicationRoot: true)
        }
    }

    // iOS: for unknown reason, when alert or activity controller was presented and we
    // set the UIWindow's root to the root controller that presented that alert,
    // then all the views (and controllers) under the presented alert are removed when the app
    // enters foreground.
    // Dismissing such alerts and controllers after minimizing the app helps.
    open func appEnteredBackground() {
        if let presentedVC = applicationRootViewController?.presentedViewController,
            presentedVC is UIAlertController || presentedVC is UIActivityViewController {
            presentedVC.dismiss(animated: false, completion: nil)
        }
    }

    open func receive(message: [AnyHashable: Any]) {
        guard let transactionID = ApplicationServiceRegistry.walletService.receive(message: message) else { return }
        if let vc = navigationController.topViewController as? ReviewTransactionViewController {
            let tx = ApplicationServiceRegistry.walletService.transactionData(transactionID)!
            vc.update(with: tx)
        } else if let tx = ApplicationServiceRegistry.walletService.transactionData(transactionID),
            tx.status != .rejected {
            incomingTransactionFlowCoordinator.transactionID = transactionID
            enterTransactionFlow(incomingTransactionFlowCoordinator)
        }
    }

    // Used for incoming transaction and send flow
    fileprivate func enterTransactionFlow(_ flow: FlowCoordinator) {
        saveCheckpoint()
        enter(flow: flow) {
            DispatchQueue.main.async { [unowned self] in
                self.popToLastCheckpoint()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [unowned self] in
                    self.showTransactionList()
                }
            }
        }
    }

    internal func showTransactionList() {
        if let mainVC = self.navigationController.topViewController as? MainViewController {
            mainVC.showTransactionList()
        }
    }

}

extension MainFlowCoordinator: OnboardingWelcomeViewControllerDelegate {

    func didStart() {
        let controller = OnboardingTermsViewController.create()
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        rootViewController.definesPresentationContext = true
        presentModally(controller)
    }

}

extension MainFlowCoordinator: OnboardingTermsViewControllerDelegate {

    public func wantsToOpenTermsOfUse() {
        SupportFlowCoordinator(from: self).openTermsOfUse()
    }

    public func wantsToOpenPrivacyPolicy() {
        SupportFlowCoordinator(from: self).openPrivacyPolicy()
    }

    public func didDisagree() {
        dismissModal()
    }

    public func didAgree() {
        dismissModal { [unowned self] in
            self.enter(flow: self.masterPasswordFlowCoordinator) {
                self.switchToRootController()
            }
        }
    }

}

extension MainFlowCoordinator: OnboardingCreateOrRestoreViewControllerDelegate {

    func didSelectNewSafe() {
        enter(flow: newSafeFlowCoordinator) { [unowned self] in
            self.switchToRootController()
        }
    }

    func didSelectRecoverSafe() {
        enter(flow: recoverSafeFlowCoordinator) { [unowned self] in
            self.switchToRootController()
        }
    }

}

extension MainFlowCoordinator: MainViewControllerDelegate {

    func mainViewDidAppear() {
        UIApplication.shared.requestRemoteNotificationsRegistration()
        DispatchQueue.global().async {
            do {
                try ApplicationServiceRegistry.walletService.auth()
            } catch let e {
                MultisigWalletApplication.ApplicationServiceRegistry.logger.error("Error in auth(): \(e)")
            }
        }
    }

    func createNewTransaction(token: String) {
        sendFlowCoordinator.token = token
        enterTransactionFlow(sendFlowCoordinator)
    }

    func openMenu() {
        let menuVC = MenuTableViewController.create()
        menuVC.delegate = self
        push(menuVC)
    }

    func manageTokens() {
        enter(flow: manageTokensFlowCoordinator)
    }

    func openAddressDetails() {
        let addressDetailsVC = ReceiveFundsViewController.create()
        push(addressDetailsVC)
    }

}

extension MainFlowCoordinator: TransactionViewViewControllerDelegate {

    public func didSelectTransaction(id: String) {
        let controller = TransactionDetailsViewController.create(transactionID: id)
        controller.delegate = self
        push(controller)
    }

}

extension MainFlowCoordinator: TransactionDetailsViewControllerDelegate {

    public func showTransactionInExternalApp(from controller: TransactionDetailsViewController) {
        SupportFlowCoordinator(from: self).openTransactionBrowser(controller.transactionID!)
    }

}

extension MainFlowCoordinator: MenuTableViewControllerDelegate {

    func didSelectCommand(_ command: MenuCommand) {
        command.run(mainFlowCoordinator: self)
    }

}
