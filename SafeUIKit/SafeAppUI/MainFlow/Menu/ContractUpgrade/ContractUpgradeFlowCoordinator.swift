//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import Common

final class ContractUpgradeFlowCoordinator: FlowCoordinator {

    weak var onboardingController: OnboardingViewController?
    var transactionID: RBETransactionID!
    weak var introVC: RBEIntroViewController!
    var transactionSubmissionHandler = TransactionSubmissionHandler()

    override func setUp() {
        super.setUp()
        showOnboarding()
    }

    func showOnboarding() {
        let vc = OnboardingViewController.create(next: { [weak self] in
            self?.onboardingController?.transitionToNextPage()
            }, finish: { [weak self] in
                Tracker.shared.track(event: ContractUpgradeTrackingEvent.getStarted)
                self?.showUpgradeIntro()
            }, showBlogArticle: showBlogArticle)
        push(vc)
        onboardingController = vc
    }

    func showUpgradeIntro() {
        let controller = RBEIntroViewController.create()
        controller.starter = ApplicationServiceRegistry.contractUpgradeService
        controller.delegate = self
        controller.screenTrackingEvent = ContractUpgradeTrackingEvent.intro
        controller.setContent(.contractUpgrade)
        push(controller)
        introVC = controller
    }

    func showBlogArticle() {
        SupportFlowCoordinator(from: self).openBlogPostForContractUpgrade_1_0_0()
    }

    func showReview() {
        let controller = RBEReviewTransactionViewController(transactionID: transactionID, delegate: self)
        controller.titleString = LocalizedString("contract_upgrade", comment: "Contract Upgrade")
        controller.detailString = String(format: LocalizedString("this_will_upgrade", comment: "Contract Upgrade"),
                                         "Safe")
        controller.screenTrackingEvent = ContractUpgradeTrackingEvent.review
        controller.successTrackingEvent = ContractUpgradeTrackingEvent.success
        controller.showsSubmitInNavigationBar = false
        push(controller)
    }

}

extension ContractUpgradeFlowCoordinator: RBEIntroViewControllerDelegate {

    func rbeIntroViewControllerDidStart() {
        transactionID = introVC.transactionID
        ApplicationServiceRegistry.contractUpgradeService.update(transaction: transactionID)
        showReview()
    }
}

extension ContractUpgradeFlowCoordinator: ReviewTransactionViewControllerDelegate {

    func reviewTransactionViewControllerWantsToSubmitTransaction(_ controller: ReviewTransactionViewController,
                                                                 completion: @escaping (Bool) -> Void) {
        transactionSubmissionHandler.submitTransaction(from: self, completion: completion)
    }

    func reviewTransactionViewControllerDidFinishReview(_ controller: ReviewTransactionViewController) {
        DispatchQueue.global.async {
            ApplicationServiceRegistry.contractUpgradeService.startMonitoring(transaction: self.transactionID)
        }
        push(SuccessViewController.contractUpgrade(action: exitFlow))
    }

}

fileprivate extension SuccessViewController {

    static func contractUpgrade(action: @escaping () -> Void) -> SuccessViewController {
        return .congratulations(text: LocalizedString("contract_upgrade_in_progress", comment: "Explanation text"),
                                image: Asset.ContractUpgrade.contractUpgrade.image,
                                tracking: ContractUpgradeTrackingEvent.success,
                                action: action)
    }

}

fileprivate extension IntroContentView.Content {

    static let contractUpgrade =
        IntroContentView.Content(header: LocalizedString("contract_upgrade", comment: "Contract Upgrade"),
                                 body: String(format: LocalizedString("this_will_upgrade", comment: "Contract Upgrade"),
                                              "Safe"),
                                 icon: Asset.ContractUpgrade.contractUpgrade.image)
}

fileprivate extension OnboardingViewController {

    static func create(next: @escaping () -> Void,
                       finish: @escaping () -> Void,
                       showBlogArticle: @escaping () -> Void) -> OnboardingViewController {
        let nextActionTitle = LocalizedString("next", comment: "Next")
        var steps = [OnboardingStepInfo]()

        let infoText = NSMutableAttributedString(string: LocalizedString("more_info_in_our_blog",
                                                                         comment: "More info in our blog."))
        let blog = LocalizedString("ios_blog", comment: "blog.")
        let textRange = infoText.mutableString.range(of: blog)
        infoText.addAttribute(.foregroundColor, value: ColorName.hold.color, range: textRange)
        steps.append(.init(image: Asset.ContractUpgrade.upgrade1.image,
                           title: LocalizedString("what_is_this_about", comment: "Onboarding 1 title"),
                           description: LocalizedString("we_performed_formal_verification",
                                                        comment: "Onboarding 1 description"),
                           infoButtonText: infoText,
                           infoButtonAction: showBlogArticle,
                           actionTitle: nextActionTitle,
                           trackingEvent: ContractUpgradeTrackingEvent._1_0_0_onboarding1,
                           action: next))

        steps.append(.init(image: Asset.ContractUpgrade.upgrade2.image,
                           title: LocalizedString("why_upgrade", comment: "Onboarding 2 title"),
                           description: LocalizedString("current_version", comment: "Onboarding 2 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent: ContractUpgradeTrackingEvent.onboarding2,
                           action: next))
        steps.append(.init(image: Asset.ContractUpgrade.upgrade3.image,
                           title: LocalizedString("lets_get_started", comment: "Onboarding 3 title"),
                           description: LocalizedString("need_confirm_upgrade", comment: "Onboarding 3 description"),
                           actionTitle: LocalizedString("get_started", comment: "Start button title"),
                           trackingEvent: ContractUpgradeTrackingEvent.onboarding3,
                           action: finish))
        return .create(steps: steps)
    }

}
