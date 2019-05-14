//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import IdentityAccessApplication
import Common

open class MainFlowCoordinator: FlowCoordinator {

    private let manageTokensFlowCoordinator = ManageTokensFlowCoordinator()
    private let connectExtensionFlowCoordinator = ConnectBrowserExtensionFlowCoordinator()
    let masterPasswordFlowCoordinator = MasterPasswordFlowCoordinator()
    let setupSafeFlowCoordinator = SetupSafeFlowCoordinator()

    private var lockedViewController: UIViewController!
    var replaceRecoveryController: ReplaceRecoveryPhraseViewController!

    private let transactionSubmissionHandler = TransactionSubmissionHandler()

    private var walletService: WalletApplicationService {
        return MultisigWalletApplication.ApplicationServiceRegistry.walletService
    }

    private var authenticationService: AuthenticationApplicationService {
        return IdentityAccessApplication.ApplicationServiceRegistry.authenticationService
    }

    private var shouldLockWhenAppActive: Bool {
        return authenticationService.isUserRegistered  && !authenticationService.isUserAuthenticated
    }

    private var applicationRootViewController: UIViewController? {
        get { return UIApplication.shared.keyWindow?.rootViewController }
        set { UIApplication.shared.keyWindow?.rootViewController = newValue }
    }

    public init() {
        super.init(rootViewController: UINavigationController())
        configureGloabalAppearance()
    }

    private func configureGloabalAppearance() {
        let barButtonAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        barButtonAppearance.tintColor = ColorName.aquaBlue.color

        let buttonAppearance = UIButton.appearance()
        buttonAppearance.tintColor = ColorName.aquaBlue.color

        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.barTintColor = .white
        navBarAppearance.isTranslucent = false
        navBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navBarAppearance.shadowImage = Asset.shadow.image
    }

    open override func setUp() {
        super.setUp()
        if walletService.hasReadyToUseWallet {
            showMainScreen()
        } else {
            showOnboarding()
        }
        lockedViewController = rootViewController

        if authenticationService.isUserRegistered {
            applicationRootViewController = UnlockViewController.create { [unowned self] success in
                if !success { return }
                self.applicationRootViewController = self.lockedViewController
            }
        } else {
            applicationRootViewController = lockedViewController
        }
    }

    func showMainScreen() {
        let mainVC = MainViewController.create(delegate: self)
        mainVC.navigationItem.backBarButtonItem = backButton()
        push(mainVC)
    }

    func showOnboarding() {
        if authenticationService.isUserRegistered {
            enterSetupSafeFlow()
        } else {
            push(StartViewController.create(delegate: self))
        }
    }

    open func appEntersForeground() {
        guard let rootVC = applicationRootViewController,
            !(rootVC is UnlockViewController) && shouldLockWhenAppActive else {
                return
        }
        lockedViewController = rootVC
        applicationRootViewController = UnlockViewController.create { [unowned self] success in
            guard success else { return }
            self.applicationRootViewController = self.lockedViewController
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
        guard let transactionID = walletService.receive(message: message) else { return }
        if let vc = navigationController.topViewController as? ReviewTransactionViewController {
            let tx = ApplicationServiceRegistry.walletService.transactionData(transactionID)!
            vc.update(with: tx)
        } else if let tx = walletService.transactionData(transactionID), tx.status != .rejected {
            openTransactionReviewScreen(transactionID)
        }
    }

    fileprivate func openTransactionReviewScreen(_ id: String) {
        let reviewVC = SendReviewViewController(transactionID: id, delegate: self)
        push(reviewVC)
    }

    fileprivate func backButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: LocalizedString("back", comment: "Back"),
                               style: .plain,
                               target: nil,
                               action: nil)
    }

    fileprivate func enterSetupSafeFlow() {
        enter(flow: setupSafeFlowCoordinator) { [unowned self] in
            self.clearNavigationStack()
            self.showMainScreen()
        }
    }

}

extension MainFlowCoordinator: StartViewControllerDelegate {

    func didStart() {
        let controller = TermsAndConditionsViewController.create()
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        rootViewController.definesPresentationContext = true
        presentModally(controller)
    }

}

extension MainFlowCoordinator: TermsAndConditionsViewControllerDelegate {

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
                self.clearNavigationStack()
                self.enterSetupSafeFlow()
            }
        }
    }

}

extension MainFlowCoordinator: MainViewControllerDelegate {

    func mainViewDidAppear() {
        UIApplication.shared.requestRemoteNotificationsRegistration()
        DispatchQueue.global().async {
            do {
                try self.walletService.auth()
            } catch let e {
                MultisigWalletApplication.ApplicationServiceRegistry.logger.error("Error in auth(): \(e)")
            }
        }
    }

    func createNewTransaction(token: String) {
        saveCheckpoint()
        let transactionVC = SendInputViewController.create(tokenID: BaseID(token))
        transactionVC.delegate = self
        transactionVC.navigationItem.backBarButtonItem = backButton()
        push(transactionVC) {
            transactionVC.willBeRemoved()
        }
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
        let addressDetailsVC = SafeAddressViewController.create()
        push(addressDetailsVC)
    }

}

extension MainFlowCoordinator: TransactionsTableViewControllerDelegate {

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

extension MainFlowCoordinator: SendInputViewControllerDelegate {

    func didCreateDraftTransaction(id: String) {
        openTransactionReviewScreen(id)
    }

}

extension MainFlowCoordinator: ReviewTransactionViewControllerDelegate {

    public func wantsToSubmitTransaction(_ completion: @escaping (Bool) -> Void) {
        transactionSubmissionHandler.submitTransaction(from: self, completion: completion)
    }

    public func didFinishReview() {
        let popAction = { [unowned self] in
            self.popToLastCheckpoint()
            self.showTransactionList()
        }
        if let reviewVC = navigationController.topViewController as? SendReviewViewController {
            push(SuccessViewController.createSendSuccess(token: reviewVC.tx.amountTokenData, action: popAction))
        } else {
            popAction()
        }
    }

    internal func showTransactionList() {
        if let mainVC = self.navigationController.topViewController as? MainViewController {
            mainVC.showTransactionList()
        }
    }

}

extension MainFlowCoordinator: MenuTableViewControllerDelegate {

    func didSelectCommand(_ command: MenuCommand) {
        command.run(mainFlowCoordinator: self)
    }

}

/// Replace phrase screens
extension MainFlowCoordinator {

    func mnemonicIntroViewController() -> ReplaceRecoveryPhraseViewController {
        return ReplaceRecoveryPhraseViewController.create(delegate: self)
    }

    func saveMnemonicViewController() -> SaveMnemonicViewController {
        let controller = SaveMnemonicViewController.create(delegate: self, isRecoveryMode: true)
        controller.screenTrackingEvent = ReplaceRecoveryPhraseTrackingEvent.showSeed
        return controller
    }

    func confirmMnemonicViewController(_ vc: SaveMnemonicViewController) -> ConfirmMnemonicViewController {
        let controller = ConfirmMnemonicViewController.create(delegate: self,
                                                              account: vc.account,
                                                              isRecoveryMode: true)
        controller.screenTrackingEvent = ReplaceRecoveryPhraseTrackingEvent.enterSeed
        return controller
    }

}

extension MainFlowCoordinator: ReplaceRecoveryPhraseViewControllerDelegate {

    func replaceRecoveryPhraseViewControllerDidStart() {
        let controller = saveMnemonicViewController()
        push(controller) {
            controller.willBeDismissed()
        }
    }

}

extension MainFlowCoordinator: SaveMnemonicDelegate {

    func saveMnemonicViewControllerDidPressContinue(_ vc: SaveMnemonicViewController) {
        push(confirmMnemonicViewController(vc))
    }

}

extension MainFlowCoordinator: ConfirmMnemonicDelegate {

    func confirmMnemonicViewControllerDidConfirm(_ vc: ConfirmMnemonicViewController) {
        let txID = replaceRecoveryController.transaction!.id
        let address = vc.account.address
        ApplicationServiceRegistry.settingsService.updateRecoveryPhraseTransaction(txID, with: address)
        let reviewVC = ReplaceRecoveryPhraseReviewTransactionViewController(transactionID: txID, delegate: self)
        self.replaceRecoveryController = nil
        push(reviewVC) { [unowned self] in
            DispatchQueue.main.async {
                self.popToLastCheckpoint()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    self.showTransactionList()
                }
            }
            DispatchQueue.global().async {
                ApplicationServiceRegistry.settingsService.cancelPhraseRecovery()
                ApplicationServiceRegistry.ethereumService.removeExternallyOwnedAccount(address: address)
            }
        }
    }

}
